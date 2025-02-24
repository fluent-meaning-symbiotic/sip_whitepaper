import '../common_imports.dart';

/// Tool for generating artifact paths based on semantic context
class GenerateArtifactPathsTool extends McpTool {
  /// Creates a new [GenerateArtifactPathsTool]
  const GenerateArtifactPathsTool({required this.llmProvider});

  /// The LLM provider to use
  final LlmProvider llmProvider;

  @override
  String get name => 'generate_artifact_paths';

  @override
  String get description => '''
Analyzes the project structure and semantic context to determine the most appropriate
locations for artifact files. This tool considers:

1. The semantic intent's location and relationships
2. Similar intents and their implementations
3. Project-specific conventions and structure
4. Semantic cohesion within the codebase

The tool helps maintain a logical and maintainable project structure by placing
artifacts where they make the most sense semantically, rather than following
rigid directory conventions.''';

  @override
  Map<String, dynamic> get parameters => {
    'type': {
      'type': 'string',
      'description': 'The type of semantic intent (e.g., SemanticTypeIntent)',
    },
    'name': {
      'type': 'string',
      'description': 'The name of the semantic intent',
    },
    'intent_path': {
      'type': 'string',
      'description': 'The path to the semantic intent YAML file',
    },
    'file_names': {
      'type': 'array',
      'items': {'type': 'string'},
      'description': 'List of file names to generate paths for',
    },
  };

  @override
  Future<Map<String, dynamic>> execute(
    final Map<String, dynamic> parameters,
    final McpContext context,
  ) async {
    final type = parameters['type'] as String;
    final name = parameters['name'] as String;
    final intentPath = parameters['intent_path'] as String;
    final fileNames = parameters['file_names'] as List<String>;

    // Instructions for the AI agent:
    // 1. Analyze the project structure around the intent_path
    // 2. Look for similar intents and their implementations
    // 3. Consider project conventions
    // 4. Generate paths that maintain semantic cohesion
    //
    // For example, if we have:
    // - lib/game/player/player_state.yaml (intent)
    // - lib/game/player/player_commands.yaml (related intent)
    // Then a new player-related intent should go in lib/game/player/
    //
    // The AI agent should:
    // 1. Extract the directory from intent_path
    // 2. Look for similar files in that directory
    // 3. Check for project conventions in nearby directories
    // 4. Generate full paths by combining the appropriate directory with file_names

    return {
      'paths': <String>[],
      'reasoning': '''
The paths should be determined by analyzing:
1. The location of the semantic intent file: $intentPath
2. Related semantic intents nearby
3. Existing implementation patterns
4. Project-specific conventions

File names to place: ${fileNames.join(', ')}
''',
    };
  }
}
