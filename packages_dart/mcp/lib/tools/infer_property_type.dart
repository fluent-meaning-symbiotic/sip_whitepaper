import '../llm/llm_provider.dart';
import '../server.dart';

/// MCP tool for inferring property types using AI
class InferPropertyTypeTool extends McpTool {
  /// Creates a new instance of [InferPropertyTypeTool]
  const InferPropertyTypeTool({required this.llmProvider});

  /// The LLM provider to use
  final LlmProvider llmProvider;

  @override
  String get name => 'infer_property_type';

  @override
  Future<Map<String, dynamic>> execute(
    final Map<String, dynamic> parameters,
    final McpContext context,
  ) async {
    // Validate parameters
    final propertyName = parameters['property_name'] as String?;
    if (propertyName == null) {
      throw Exception('Missing required parameter: property_name');
    }

    final description = parameters['description'] as String?;
    final context = parameters['context'] as String?;

    // Generate prompt
    final prompt =
        StringBuffer()
          ..writeln('Infer the semantic type for a property with:')
          ..writeln('Property name: $propertyName')
          ..writeln('Description: ${description ?? "Not provided"}')
          ..writeln('Context: ${context ?? "Not provided"}')
          ..writeln()
          ..writeln('Rules for type inference:')
          ..writeln('1. Return one of: string, int, double, bool')
          ..writeln('2. Consider property name conventions')
          ..writeln('3. Consider surrounding context if provided')
          ..writeln('4. Consider domain-specific patterns')
          ..writeln('5. Default to string if uncertain');

    // Get type inference from LLM
    final response = await llmProvider.processMessage(
      prompt.toString(),
      [], // Empty history for now
    );

    if (response.hasError) {
      throw Exception('Failed to infer type: ${response.error}');
    }

    final inferredType = response.content?.trim().toLowerCase() ?? 'string';

    // Validate inferred type
    if (!['string', 'int', 'double', 'bool'].contains(inferredType)) {
      return {'type': 'string'}; // Default to string for invalid responses
    }

    return {'type': inferredType};
  }
}
