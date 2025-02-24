import 'package:path/path.dart' as path;
import 'package:universal_io/io.dart';
import 'package:yaml/yaml.dart';

import '../llm/llm_provider.dart';
import '../server.dart';

/// MCP tool for generating implementation artifacts from intents
class GenerateArtifactsTool extends McpTool {
  /// Creates a new instance of [GenerateArtifactsTool]
  const GenerateArtifactsTool({required this.llmProvider});

  /// The LLM provider to use
  final LlmProvider llmProvider;

  @override
  String get name => 'generate_artifacts';

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

    final type = parameters['type'] as String?;

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

    // Get output artifacts and prompts
    final artifacts = intent['output_artifacts'] as YamlList?;
    final prompts = intent['llm_prompts'] as YamlMap?;
    if (artifacts == null || artifacts.isEmpty) {
      throw Exception('Intent has no output artifacts defined');
    }

    // Filter artifacts by type if specified
    final targetArtifacts =
        type != null
            ? artifacts
                .where(
                  (final a) =>
                      a.toString().toLowerCase().contains(type.toLowerCase()),
                )
                .toList()
            : artifacts.toList();

    if (targetArtifacts.isEmpty) {
      throw Exception('No matching artifacts found for type: $type');
    }

    // Generate each artifact
    final generatedArtifacts = <String, String>{};
    for (final artifact in targetArtifacts) {
      final artifactPath = artifact.toString();
      final artifactType = _inferArtifactType(artifactPath);
      final promptSection = prompts?[artifactType] as YamlMap?;
      final prompt = promptSection?['context'] as String? ?? '';

      final response = await llmProvider.processMessage(
        '''Generate ${artifactType.replaceAll('_', ' ')} for semantic intent:
$yamlContent

${prompt.isNotEmpty ? '\nGeneration context:\n$prompt' : ''}

Follow these rules:
1. Use proper file structure and imports
2. Follow project conventions
3. Implement all required functionality
4. Add proper documentation
5. Handle errors appropriately
6. Add necessary tests if generating test files''',
        [], // Empty history for now
      );

      if (response.hasError) {
        throw Exception(
          'Failed to generate artifact $artifactPath: ${response.error}',
        );
      }

      final content = response.content;
      if (content == null || content.isEmpty) {
        throw Exception('LLM returned empty content for $artifactPath');
      }

      // Create directory if needed
      final fullArtifactPath = path.join(context.workspaceRoot, artifactPath);
      final artifactDir = path.dirname(fullArtifactPath);
      Directory(artifactDir).createSync(recursive: true);

      // Write artifact
      File(fullArtifactPath).writeAsStringSync(content);
      generatedArtifacts[artifactPath] = fullArtifactPath;
    }

    return {'artifacts': generatedArtifacts};
  }

  String _inferArtifactType(final String artifactPath) {
    final lower = artifactPath.toLowerCase();
    if (lower.endsWith('_test.dart')) return 'test';
    if (lower.endsWith('.dart')) return 'code';
    if (lower.contains('assets/')) return 'asset';
    if (lower.contains('ui/')) return 'ui';
    return 'code';
  }
}
