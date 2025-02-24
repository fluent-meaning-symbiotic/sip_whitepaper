import 'package:yaml/yaml.dart';

import '../server.dart';
import '../tools/infer_property_type.dart';
import 'ai_client.dart';

/// Response from an LLM provider
class LlmResponse {
  /// Creates a new [LlmResponse]
  const LlmResponse({this.content, this.error});

  /// The response content
  final String? content;

  /// Any error that occurred
  final String? error;

  /// Whether the response contains an error
  bool get hasError => error != null;
}

/// Base class for LLM providers
abstract class LlmProvider {
  /// Creates a new [LlmProvider]
  const LlmProvider();

  /// Processes a message and returns a response
  Future<LlmResponse> processMessage(
    final String message,
    final List<String> history,
  );
}

/// Local LLM provider that uses predefined templates
class LocalLlmProvider extends LlmProvider {
  /// Creates a new [LocalLlmProvider]
  LocalLlmProvider();

  /// The tool for inferring property types
  late final inferPropertyTypeTool = InferPropertyTypeTool(llmProvider: this);

  Future<String> _inferPropertyType(final String word) async {
    try {
      final result = await inferPropertyTypeTool.execute(
        {'property_name': word},
        const McpContext(), // Empty context
      );
      return result['type'] as String;
    } catch (e) {
      // Fallback to string on error
      return 'string';
    }
  }

  @override
  Future<LlmResponse> processMessage(
    final String message,
    final List<String> history,
  ) async {
    // Handle intent creation
    if (message.contains('Generate a semantic intent YAML')) {
      final description =
          message.split('Generate a semantic intent YAML for:').last;
      final type = _inferType(description);
      final properties =
          type == 'SemanticTypeIntent'
              ? await _inferTypeProperties(description)
              : <String, String>{};

      return LlmResponse(
        content: '''semantic_intent:
  version: 1
  name: ${_generateName(description)}
  type: $type
  meaning: "${description.trim()}"
  description: |
    ${description.trim()}
    
  semantic_properties: ${_formatProperties(properties)}
  semantic_validations: ${_generateValidations(type, properties)}
  output_artifacts: ${_generateArtifactFileNames(type, _generateName(description))}
  llm_prompts: {}''',
      );
    }

    // Handle intent modification
    if (message.contains('Modify this semantic intent YAML')) {
      final changes =
          message.split('according to these changes:')[1].split('\n')[0].trim();
      final currentYaml = _extractYaml(message);
      if (currentYaml == null) {
        return const LlmResponse(error: 'Could not extract current YAML');
      }

      return _modifyIntent(currentYaml, changes);
    }

    // Handle intent refactoring
    if (message.contains('Refactor these semantic intent YAMLs')) {
      final changes =
          message.split('according to these changes:')[1].split('\n')[0].trim();
      final yamls = _extractMultipleYamls(message);
      if (yamls.isEmpty) {
        return const LlmResponse(error: 'Could not extract YAMLs to refactor');
      }

      return _refactorIntents(yamls, changes);
    }

    // Handle artifact generation
    if (message.contains('Generate') &&
        message.contains('for semantic intent:')) {
      final type =
          message.split('Generate')[1].split('for semantic intent:')[0].trim();
      final yaml = _extractYaml(message);
      if (yaml == null) {
        return const LlmResponse(error: 'Could not extract intent YAML');
      }

      return _generateArtifact(yaml, type);
    }

    // Handle intent update from implementation
    if (message.contains(
      'Update this semantic intent YAML based on the implementation code',
    )) {
      final yaml = _extractYaml(message);
      final code = _extractCode(message);
      if (yaml == null || code == null) {
        return const LlmResponse(error: 'Could not extract YAML or code');
      }

      return _updateFromImplementation(yaml, code);
    }

    return const LlmResponse(
      error: 'Unsupported message type for local LLM provider',
    );
  }

  String _generateName(final String description) {
    final normalized = description.trim().replaceAll(
      RegExp(r'\b(a|an|the)\s+'),
      '',
    ); // Remove articles

    // First try to find a direct type name
    final typeMatch = RegExp(
      r'\b([A-Za-z]+(?:\s+[A-Za-z]+)*)\s+type\b',
    ).firstMatch(normalized);
    if (typeMatch != null) {
      final typeName =
          typeMatch
              .group(1)!
              .split(RegExp(r'\s+'))
              .map(
                (final word) =>
                    word.substring(0, 1).toUpperCase() +
                    word.substring(1).toLowerCase(),
              )
              .join();
      return '${typeName}TypeIntent';
    }

    // Otherwise, build from significant words
    final words =
        normalized
            .split(RegExp(r'\s+'))
            .where(
              (final word) =>
                  ![
                    'with',
                    'and',
                    'x',
                    'y',
                    'z',
                    'type',
                    'data',
                    'for',
                    'of',
                  ].contains(word.toLowerCase()),
            )
            .map(
              (final word) =>
                  word.substring(0, 1).toUpperCase() +
                  word.substring(1).toLowerCase(),
            )
            .where((final word) => word.isNotEmpty)
            .take(2) // Take fewer words to avoid long names
            .toList();

    // Add 'Type' suffix if not present
    if (!words.any((final w) => w.toLowerCase().contains('type'))) {
      words.add('Type');
    }

    return '${words.join()}Intent';
  }

  String _inferType(final String description) {
    final lower = description.toLowerCase();
    if (lower.contains('command') || lower.contains('action')) {
      return 'SemanticCommandIntent';
    }
    if (lower.contains('type') ||
        lower.contains('data structure') ||
        lower.contains('model')) {
      return 'SemanticTypeIntent';
    }
    if (lower.contains('ui') ||
        lower.contains('widget') ||
        lower.contains('screen')) {
      return 'SemanticUiIntent';
    }
    if (lower.contains('test')) {
      return 'SemanticTestIntent';
    }
    if (lower.contains('api') || lower.contains('service')) {
      return 'SemanticApiIntent';
    }
    return 'SemanticIntent';
  }

  String? _extractYaml(final String message) {
    final match = RegExp(
      r'Current YAML:\n(.*?)(?=\n\n|\Z)',
      dotAll: true,
    ).firstMatch(message);
    return match?.group(1)?.trim();
  }

  List<MapEntry<String, String>> _extractMultipleYamls(final String message) {
    final yamls = <MapEntry<String, String>>[];
    final matches = RegExp(
      r'File (.*?):\n(.*?)(?=\nFile|\Z)',
      dotAll: true,
    ).allMatches(message);

    for (final match in matches) {
      final path = match.group(1)?.trim();
      final yaml = match.group(2)?.trim();
      if (path != null && yaml != null) {
        yamls.add(MapEntry(path, yaml));
      }
    }
    return yamls;
  }

  String? _extractCode(final String message) {
    final match = RegExp(
      r'Implementation Code:\n(.*?)(?=\n\n|\Z)',
      dotAll: true,
    ).firstMatch(message);
    return match?.group(1)?.trim();
  }

  LlmResponse _modifyIntent(final String yaml, final String changes) {
    try {
      final doc = loadYaml(yaml) as YamlMap;
      final intent = doc['semantic_intent'] as YamlMap?;
      if (intent == null)
        return const LlmResponse(error: 'Invalid YAML structure');

      // Simple modification based on common patterns
      final lower = changes.toLowerCase();
      final modified = {...doc};
      final modifiedIntent = {...intent};

      // Update version for semantic changes
      if (lower.contains('add') ||
          lower.contains('remove') ||
          lower.contains('change')) {
        modifiedIntent['version'] = (intent['version'] as int? ?? 1) + 1;
      }

      // Add properties if mentioned
      if (lower.contains('property') || lower.contains('field')) {
        modifiedIntent['semantic_properties'] = {
          ...(intent['semantic_properties'] as Map? ?? {}),
          'new_property': 'string',
        };
      }

      // Add validation if mentioned
      if (lower.contains('validation') || lower.contains('rule')) {
        final validations = [
          ...(intent['semantic_validations'] as List? ?? []),
        ];
        validations.add('New validation from changes: $changes');
        modifiedIntent['semantic_validations'] = validations;
      }

      modified['semantic_intent'] = modifiedIntent;
      return LlmResponse(content: _yamlToString(modified));
    } catch (e) {
      return LlmResponse(error: 'Failed to modify YAML: $e');
    }
  }

  LlmResponse _refactorIntents(
    final List<MapEntry<String, String>> yamls,
    final String changes,
  ) {
    try {
      final result = StringBuffer();
      for (final entry in yamls) {
        result.writeln('File: ${entry.key}');
        result.writeln(_modifyIntent(entry.value, changes).content);
        result.writeln();
      }
      return LlmResponse(content: result.toString());
    } catch (e) {
      return LlmResponse(error: 'Failed to refactor YAMLs: $e');
    }
  }

  LlmResponse _generateArtifact(final String yaml, final String type) {
    try {
      final doc = loadYaml(yaml) as YamlMap;
      final intent = doc['semantic_intent'] as YamlMap?;
      if (intent == null) {
        return const LlmResponse(error: 'Invalid YAML structure');
      }

      final name = intent['name'] as String? ?? 'Unknown';
      final meaning = intent['meaning'] as String? ?? '';
      final intentType = intent['type'] as String? ?? '';
      final properties = intent['semantic_properties'] as YamlMap? ?? {};

      switch (type.toLowerCase()) {
        case 'code':
          if (intentType == 'SemanticTypeIntent') {
            if (properties.isEmpty) {
              return const LlmResponse(
                error: 'No properties defined for type intent',
              );
            }

            return LlmResponse(
              content: '''import 'common_imports.dart';

/// Type definition for $name
/// $meaning
class ${name.replaceAll('Intent', 'Type')} {
  /// Creates a new instance of [${name.replaceAll('Intent', 'Type')}]
  const ${name.replaceAll('Intent', 'Type')}({
    ${_generateTypeProperties(intent)}
  });

  ${_generateTypeFields(intent)}

  @override
  String toString() => '${name.replaceAll('Intent', 'Type')}('
      '${_generateToString(intent)}'
      ')';
      
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ${name.replaceAll('Intent', 'Type')} &&
          ${_generateEquality(intent)};

  @override
  int get hashCode => Object.hash(${_generateHashCode(intent)});
}''',
            );
          }
          return LlmResponse(
            content: '''import 'common_imports.dart';

/// Implementation of $name
/// $meaning
class ${name.replaceAll('Intent', '')} {
  /// Creates a new instance of [${name.replaceAll('Intent', '')}]
  const ${name.replaceAll('Intent', '')}();

  // TODO: Implement functionality
}''',
          );

        case 'test':
          return LlmResponse(
            content: '''import 'package:test/test.dart';

void main() {
  group('${name.replaceAll('Intent', '')}', () {
    test('should work correctly', () {
      // TODO: Implement test
    });
  });
}''',
          );

        case 'ui':
          return LlmResponse(
            content: '''import 'package:flutter/material.dart';

/// UI implementation of $name
/// $meaning
class ${name.replaceAll('Intent', 'Widget')} extends StatelessWidget {
  /// Creates a new instance of [${name.replaceAll('Intent', 'Widget')}]
  const ${name.replaceAll('Intent', 'Widget')}({super.key});

  @override
  Widget build(final BuildContext context) {
    return Container(
      // TODO: Implement UI
    );
  }
}''',
          );

        default:
          return const LlmResponse(error: 'Unsupported artifact type');
      }
    } catch (e) {
      return LlmResponse(error: 'Failed to generate artifact: $e');
    }
  }

  LlmResponse _updateFromImplementation(final String yaml, final String code) {
    try {
      final doc = loadYaml(yaml) as YamlMap;
      final intent = doc['semantic_intent'] as YamlMap?;
      if (intent == null)
        return const LlmResponse(error: 'Invalid YAML structure');

      final modified = {...doc};
      final modifiedIntent = {...intent};

      // Update version
      modifiedIntent['version'] = (intent['version'] as int? ?? 1) + 1;

      // Extract class/function names from code
      final classMatch = RegExp(r'class\s+(\w+)').firstMatch(code);
      if (classMatch != null) {
        final className = classMatch.group(1);
        modifiedIntent['name'] = '${className}Intent';
      }

      // Extract comments for meaning/description
      final comments = RegExp(r'///\s*([^\n]+)').allMatches(code);
      if (comments.isNotEmpty) {
        modifiedIntent['description'] = comments
            .map((final m) => m.group(1))
            .where((final c) => c != null)
            .join('\n');
      }

      modified['semantic_intent'] = modifiedIntent;
      return LlmResponse(content: _yamlToString(modified));
    } catch (e) {
      return LlmResponse(error: 'Failed to update from implementation: $e');
    }
  }

  String _yamlToString(final Map doc) {
    final result = StringBuffer();
    _writeYamlNode(doc, result, 0);
    return result.toString();
  }

  void _writeYamlNode(final node, final StringBuffer buffer, final int indent) {
    final prefix = ' ' * indent;
    if (node is Map) {
      for (final entry in node.entries) {
        buffer.write('$prefix${entry.key}:');
        if (entry.value is Map || entry.value is List) {
          buffer.writeln();
          _writeYamlNode(entry.value, buffer, indent + 2);
        } else {
          buffer.write(' ${entry.value}\n');
        }
      }
    } else if (node is List) {
      for (final item in node) {
        buffer.write('$prefix- ');
        if (item is Map || item is List) {
          buffer.writeln();
          _writeYamlNode(item, buffer, indent + 2);
        } else {
          buffer.writeln(item);
        }
      }
    }
  }

  String _generateTypeProperties(final YamlMap intent) {
    final properties = intent['semantic_properties'] as YamlMap? ?? {};
    return properties.entries
        .map((final e) => '''required this.${e.key},''')
        .join('\n    ');
  }

  String _generateTypeFields(final YamlMap intent) {
    final properties = intent['semantic_properties'] as YamlMap? ?? {};
    return properties.entries
        .map(
          (final e) => '''/// The ${e.key} of the type
  final ${_inferDartType(e.value)} ${e.key};''',
        )
        .join('\n\n  ');
  }

  String _generateToString(final YamlMap intent) {
    final properties = intent['semantic_properties'] as YamlMap? ?? {};
    return properties.entries
        .map((final e) => '${e.key}: \$${e.key}')
        .join(', ');
  }

  String _generateEquality(final YamlMap intent) {
    final properties = intent['semantic_properties'] as YamlMap? ?? {};
    return properties.entries
        .map((final e) => '${e.key} == other.${e.key}')
        .join(' && ');
  }

  String _generateHashCode(final YamlMap intent) {
    final properties = intent['semantic_properties'] as YamlMap? ?? {};
    return properties.keys.join(', ');
  }

  String _inferDartType(final value) {
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'string') return 'String';
      if (lower == 'int' || lower == 'integer') return 'int';
      if (lower == 'double' || lower == 'float' || lower == 'number')
        return 'double';
      if (lower == 'bool' || lower == 'boolean') return 'bool';
      if (lower.startsWith('list<') || lower.endsWith('[]'))
        return 'List<dynamic>';
      if (lower.startsWith('map<') || lower.contains('{'))
        return 'Map<String, dynamic>';
      return 'dynamic';
    }
    return 'dynamic';
  }

  Future<Map<String, String>> _inferTypeProperties(
    final String description,
  ) async {
    final properties = <String, String>{};

    // First pass: Find camelCase properties
    final camelCaseProps =
        RegExp(
          r'\b[a-z]+[A-Z][a-zA-Z]*\b',
        ).allMatches(description).map((final m) => m.group(0)!).toList();

    // Add camelCase properties first
    for (final prop in camelCaseProps) {
      properties[prop] = await _inferPropertyType(prop.toLowerCase());
    }

    // Second pass: Find remaining properties
    final words =
        description
            .replaceAll(RegExp(r'[,\.]'), ' ')
            .split(RegExp(r'\s+'))
            .where(
              (final word) =>
                  ![
                    'a',
                    'an',
                    'the',
                    'with',
                    'and',
                    'or',
                    'type',
                    'data',
                    'for',
                    'of',
                  ].contains(word.toLowerCase()),
            )
            .where(
              (final word) => !camelCaseProps.contains(word),
            ) // Skip already processed
            .toList();

    // Find property names and types
    for (var i = 0; i < words.length; i++) {
      final word = words[i];
      final lower = word.toLowerCase();

      // Look for type hints
      if (i < words.length - 1) {
        final nextWord = words[i + 1].toLowerCase();
        if (_isTypeHint(nextWord)) {
          if (_looksLikeProperty(lower)) {
            properties[word] = _mapTypeHint(nextWord);
          }
          i++; // Skip the type hint
          continue;
        }
      }

      // Handle coordinate properties
      if (lower == 'x' || lower == 'y' || lower == 'z') {
        properties[lower] = 'double';
        continue;
      }

      // Infer type from property name
      if (_looksLikeProperty(lower)) {
        properties[word] = await _inferPropertyType(lower);
      }
    }

    return properties;
  }

  bool _isTypeHint(final String word) => [
    'string',
    'text',
    'number',
    'int',
    'integer',
    'float',
    'double',
    'bool',
    'boolean',
    'flag',
    'status',
  ].contains(word);

  String _mapTypeHint(final String hint) {
    switch (hint) {
      case 'string':
      case 'text':
        return 'string';
      case 'number':
      case 'float':
      case 'double':
        return 'double';
      case 'int':
      case 'integer':
        return 'int';
      case 'bool':
      case 'boolean':
      case 'flag':
      case 'status':
        return 'bool';
      default:
        return 'string';
    }
  }

  bool _looksLikeProperty(final String word) {
    // Skip common words and verbs
    if ([
      'has',
      'is',
      'can',
      'will',
      'should',
      'must',
      'may',
      'might',
      'would',
      'could',
      'point',
      'user',
      'data',
      'type',
      'object',
      'value',
      'item',
      'coordinate',
      'coordinates',
    ].contains(word)) {
      return false;
    }

    return word.length > 1;
  }

  String _formatProperties(final Map<String, String> properties) {
    if (properties.isEmpty) return '{}';

    final buffer = StringBuffer('{\n');
    for (final entry in properties.entries) {
      buffer.writeln('    ${entry.key}: ${entry.value}');
    }
    buffer.write('  }');
    return buffer.toString();
  }

  List<String> _generateValidations(
    final String type,
    final Map<String, String> properties,
  ) {
    final validations = <String>[];

    if (type == 'SemanticTypeIntent') {
      for (final entry in properties.entries) {
        switch (entry.value) {
          case 'string':
            validations.add('${entry.key} must not be empty');
          case 'int':
            validations.add('${entry.key} must be a valid integer');
          case 'double':
            validations.add('${entry.key} must be a finite number');
          case 'bool':
            validations.add('${entry.key} must be a boolean value');
        }
      }
    }

    return validations;
  }

  List<String> _generateArtifactFileNames(
    final String type,
    final String name,
  ) {
    final baseName = name.replaceAll('Intent', '').toLowerCase();
    final fileNames = <String>[];

    switch (type) {
      case 'SemanticTypeIntent':
        fileNames.addAll([
          '${baseName}_type.dart',
          '${baseName}_type_test.dart',
        ]);
      case 'SemanticCommandIntent':
        fileNames.addAll([
          '${baseName}.cmnd.dart',
          '${baseName}.cmnd_test.dart',
        ]);
      case 'SemanticUiIntent':
        final isScreen = _isScreenComponent(name);
        final suffix = isScreen ? 'screen' : 'widget';
        fileNames.addAll([
          '${baseName}.$suffix.dart',
          '${baseName}.${suffix}_test.dart',
        ]);
      case 'SemanticTestIntent':
        fileNames.add('${baseName}_test.dart');
      case 'SemanticApiIntent':
        fileNames.addAll(['${baseName}_api.dart', '${baseName}_api_test.dart']);
      default:
        fileNames.addAll(['$baseName.dart', '${baseName}_test.dart']);
    }

    return fileNames;
  }

  bool _isScreenComponent(String name) {
    final lower = name.toLowerCase();
    return lower.contains('screen') ||
        lower.contains('page') ||
        lower.contains('view') ||
        lower.contains('route') ||
        lower.contains('window');
  }
}

/// Remote LLM provider that uses OpenAI/LM Studio
class RemoteLlmProvider extends LlmProvider {
  /// Creates a new [RemoteLlmProvider]
  const RemoteLlmProvider({required this.client});

  /// The AI client to use
  final AiClient client;

  @override
  Future<LlmResponse> processMessage(
    final String message,
    final List<String> history,
  ) async {
    try {
      // TODO: Implement remote LLM provider
      return const LlmResponse(
        error: 'Remote LLM provider not implemented yet',
      );
    } catch (e) {
      return LlmResponse(error: e.toString());
    }
  }
}
