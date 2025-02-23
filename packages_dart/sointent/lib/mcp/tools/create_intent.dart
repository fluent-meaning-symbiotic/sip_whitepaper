import 'package:path/path.dart' as path;
import 'package:sointent/common_imports.dart';
import 'package:sointent/mcp/server.dart';

/// MCP tool for creating new semantic intents
class CreateIntentTool extends McpTool {
  /// Creates a new instance of [CreateIntentTool]
  const CreateIntentTool({required this.llmClient});

  final AiClient llmClient;

  @override
  String get name => 'create_intent';

  @override
  Future<Map<String, dynamic>> execute(
    final Map<String, dynamic> parameters,
    final McpContext context,
  ) async {
    // Validate parameters
    final description = parameters['description'] as String?;
    if (description == null) {
      throw Exception('Missing required parameter: description');
    }

    final providedPath = parameters['path'] as String?;
    final initialYaml = parameters['initial_yaml'] as String?;

    // Generate path if not provided
    final intentPath = providedPath ?? _generatePath(description, context);
    final fullPath = path.join(context.workspaceRoot, intentPath);

    // Ensure directory exists
    final dir = Directory(path.dirname(fullPath));
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    // Check if file already exists
    final file = File(fullPath);
    if (file.existsSync()) {
      throw Exception('Intent file already exists: $intentPath');
    }

    // Generate YAML content
    final yaml = initialYaml ?? await _generateYaml(description);

    // Write file
    file.writeAsStringSync(yaml);

    return {'path': intentPath, 'yaml': yaml};
  }

  String _generatePath(final String description, final McpContext context) {
    // Convert description to snake_case filename
    final name = description
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '_');

    return 'lib/intents/${name}_intent.yaml';
  }

  Future<String> _generateYaml(final String description) async {
    // Use LLM to generate initial YAML
    final response = await llmClient.processMessage(
      '''Generate a semantic intent YAML for: $description
      
Follow this structure:
semantic_intent:
  version: 1
  name: [PascalCase name]
  type: [Intent type]
  meaning: [Clear, concise meaning]
  description: [Detailed description]
  semantic_properties: [Relevant properties]
  semantic_validations: [Validation rules]
  output_artifacts: [Generated files]
  llm_prompts: [Generation prompts]''',
      [], // Empty history for now
    );

    throw Exception('Failed to generate YAML: ${response.error}');

    final content = response.message.content;
    if (content.isEmpty) {
      throw Exception('LLM returned empty YAML content');
    }

    return content;
  }
}
