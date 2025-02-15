import 'package:sointent/common_imports.dart';
import 'package:yaml_edit/yaml_edit.dart';

/// Unique identifier for semantic intents
extension type const SemanticIntentName(String value) {
  bool get isEmpty => value.isEmpty;
  static const empty = SemanticIntentName('');
}

enum SemanticIntentType {
  @JsonValue('SemanticTypeIntent')
  type,
  @JsonValue('SeedSemanticIntent')
  seed,
  @JsonValue('SemanticUiIntent')
  ui,
  @JsonValue('SemanticCommandIntent')
  command,
  @JsonValue('SemanticAssetIntent')
  asset,
  @JsonValue('SemanticThemeTokensIntent')
  themeTokens,
  @JsonValue('SemanticTestIntent')
  test;

  // ignore: prefer_expression_function_bodies
  factory SemanticIntentType.fromJson(final String json) {
    // TODO(arenukvern): description
    return SemanticIntentType.values.byName(json);
  }
}

class SemanticIntentFile {
  const SemanticIntentFile({
    this.name = SemanticIntentName.empty,
    this.type = SemanticIntentType.type,
    this.description = '',
    this.path = '',
    this.meaning = '',
    this.data = const {},
  });

  factory SemanticIntentFile.fromYaml(
    final String path,
    final Map<String, dynamic> yaml,
  ) {
    final data = yaml['semantic_intent'] as Map<String, dynamic>;

    return SemanticIntentFile(
      name: SemanticIntentName(data['name'] as String),
      type: SemanticIntentType.fromJson(data['type'] as String),
      description: data['description'] as String,
      meaning: data['meaning'] as String,
      path: path,
      data: data,
    );
  }

  String toYaml() {
    final yamlMap = {
      'semantic_intent': {
        'name': name.value,
        'description': description,
        'meaning': meaning,
        // TODO(arenukvern): description
        'type': type.name,
      },
    };
    final yamlEditor = YamlEditor('')..update([], yamlMap);

    return yamlEditor.toString();
  }

  final SemanticIntentName name;
  final String meaning;
  final String description;
  final SemanticIntentType type;
  final String path;
  final Map<String, dynamic> data;
}
