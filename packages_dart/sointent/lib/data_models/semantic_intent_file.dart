import 'package:collection/collection.dart';
import 'package:sointent/common_imports.dart';
import 'package:yaml_edit/yaml_edit.dart';

/// Unique identifier for semantic intents
extension type const SemanticIntentName(String value) {
  bool get isEmpty => value.isEmpty;
  static const empty = SemanticIntentName('');
}

enum SemanticIntentType {
  type,
  seed,
  api,
  ui,
  command,
  reactiveCommand,
  asset,
  themeTokens,
  test;

  // ignore: prefer_expression_function_bodies
  factory SemanticIntentType.fromJson(final String json) {
    final result = _all.entries.firstWhereOrNull((final e) => e.value == json);
    if (result == null) {
      throw ArgumentError.value(json, 'json', 'Invalid semantic intent type');
    }
    return result.key;
  }

  String get json => _all[this]!;

  static const _all = <SemanticIntentType, String>{
    type: 'SemanticTypeIntent',
    api: 'SemanticApiIntent',
    seed: 'SeedSemanticIntent',
    ui: 'SemanticUiIntent',
    command: 'SemanticCommandIntent',
    reactiveCommand: 'SemanticReactiveCommandIntent',
    asset: 'SemanticAssetIntent',
    themeTokens: 'SemanticThemeTokensIntent',
    test: 'SemanticTestIntent',
  };
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
    final data = yaml['semantic_intent'] as YamlMap;

    return SemanticIntentFile(
      name: SemanticIntentName(data['name'] as String),
      type: SemanticIntentType.fromJson(data['type'] as String),
      description: data['description'] as String,
      meaning: data['meaning'] as String,
      path: path,
      data: yaml,
    );
  }

  String toYaml() {
    final yamlMap = {
      'semantic_intent': {
        'name': name.value,
        'description': description,
        'meaning': meaning,
        'type': type.json,
      },
    };
    final yamlEditor = YamlEditor('')..update([], yamlMap);

    return yamlEditor.toString();
  }

  /// The relative path to the project containing this intent
  String getRelativePath(final String projectPath) =>
      path.replaceFirst(projectPath, '');
  String get intentFileName => path.split('/').last.split('.').first;
  final SemanticIntentName name;
  final String meaning;
  final String description;
  final SemanticIntentType type;
  final String path;
  final Map<String, dynamic> data;
}
