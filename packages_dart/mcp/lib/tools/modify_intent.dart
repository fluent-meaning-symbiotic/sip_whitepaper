import 'dart:io';

import 'package:path/path.dart' as path;

import '../llm/llm_provider.dart';
import '../server.dart';

/// MCP tool for modifying existing semantic intents
class ModifyIntentTool extends McpTool {
  /// Creates a new instance of [ModifyIntentTool]
  const ModifyIntentTool({required this.llmProvider});

  /// The LLM provider to use
  final LlmProvider llmProvider;

  @override
  String get name => 'modify_intent';

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

    final changes = parameters['changes'] as String?;
    if (changes == null) {
      throw Exception('Missing required parameter: changes');
    }

    // Get full path and verify file exists
    final fullPath = path.join(context.workspaceRoot, intentPath);
    final file = File(fullPath);
    if (!file.existsSync()) {
      throw Exception('Intent file not found: $intentPath');
    }

    // Read current content
    final currentYaml = file.readAsStringSync();

    // Generate modified YAML
    final response = await llmProvider.processMessage(
      '''Modify this semantic intent YAML according to these changes: $changes

Current YAML:
$currentYaml

Follow these rules:
1. Keep the same structure and formatting
2. Preserve any fields not affected by the changes
3. Update version if semantic meaning changes
4. Add/update semantic validations if needed
5. Update llm_prompts if needed''',
      [], // Empty history for now
    );

    if (response.hasError) {
      throw Exception('Failed to modify YAML: ${response.error}');
    }

    final modifiedYaml = response.content;
    if (modifiedYaml == null || modifiedYaml.isEmpty) {
      throw Exception('LLM returned empty YAML content');
    }

    // Create backup
    final backupPath = '$fullPath.bak';
    file.copySync(backupPath);

    try {
      // Write modified content
      file.writeAsStringSync(modifiedYaml);

      // Delete backup on success
      final backup = File(backupPath);
      if (backup.existsSync()) {
        backup.deleteSync();
      }

      return {'yaml': modifiedYaml};
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
