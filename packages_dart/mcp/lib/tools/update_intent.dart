import 'package:path/path.dart' as path;
import 'package:universal_io/io.dart';
import 'package:yaml/yaml.dart';

import '../llm/llm_provider.dart';
import '../server.dart';

/// MCP tool for updating intents based on implementation changes
class UpdateIntentFromImplementationTool extends McpTool {
  /// Creates a new instance of [UpdateIntentFromImplementationTool]
  const UpdateIntentFromImplementationTool({required this.llmProvider});

  /// The LLM provider to use
  final LlmProvider llmProvider;

  @override
  String get name => 'update_intent_from_implementation';

  @override
  Future<Map<String, dynamic>> execute(
    final Map<String, dynamic> parameters,
    final McpContext context,
  ) async {
    // Validate parameters
    final intentPath = parameters['path'] as String?;
    if (intentPath == null) {
      throw Exception('Missing required parameter: path');
    }

    final code = parameters['code'] as String?;
    if (code == null) {
      throw Exception('Missing required parameter: code');
    }

    // Get full path and verify file exists
    final fullPath = path.join(context.workspaceRoot, intentPath);
    final file = File(fullPath);
    if (!file.existsSync()) {
      throw Exception('Intent file not found: $intentPath');
    }

    // Read and parse YAML
    final yamlContent = file.readAsStringSync();
    final yaml = loadYaml(yamlContent) as YamlMap;
    final intent = yaml['semantic_intent'] as YamlMap?;
    if (intent == null) {
      throw Exception('Invalid intent YAML: missing semantic_intent section');
    }

    // Generate updated YAML
    final response = await llmProvider.processMessage(
      '''Update this semantic intent YAML based on the implementation code:

Current YAML:
$yamlContent

Implementation Code:
$code

Follow these rules:
1. Keep the same structure and formatting
2. Update semantic properties to match implementation
3. Update semantic validations if needed
4. Update version if semantic meaning changes
5. Update llm_prompts if needed
6. Preserve any custom fields or comments
7. Only update what has actually changed
8. Add new validations for any new functionality
9. Update output artifacts if new files are referenced''',
      [], // Empty history for now
    );

    if (response.hasError) {
      throw Exception('Failed to update YAML: ${response.error}');
    }

    final updatedYaml = response.content;
    if (updatedYaml == null || updatedYaml.isEmpty) {
      throw Exception('LLM returned empty YAML content');
    }

    // Create backup
    final backupPath = '$fullPath.bak';
    file.copySync(backupPath);

    try {
      // Write updated content
      file.writeAsStringSync(updatedYaml);

      // Delete backup on success
      final backup = File(backupPath);
      if (backup.existsSync()) {
        backup.deleteSync();
      }

      return {'yaml': updatedYaml};
    } catch (e) {
      // Restore from backup
      final backup = File(backupPath);
      if (backup.existsSync()) {
        backup.copySync(fullPath);
        backup.deleteSync();
      }
      rethrow;
    }
  }
}
