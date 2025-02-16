import 'package:collection/collection.dart';
import 'package:sointent/common_imports.dart';
import 'package:sointent/ui_intent_editor/utils/yaml_utils.dart';
import 'package:yaml_edit/yaml_edit.dart';

/// Unique identifier for semantic intents
extension type const SemanticIntentName(String value) {
  bool get isEmpty => value.isEmpty;
  static const empty = SemanticIntentName('');
}

/// Type of semantic intent
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

/// Represents a semantic intent file in the system
class SemanticIntentFile {
  const SemanticIntentFile({
    this.name = SemanticIntentName.empty,
    this.type = SemanticIntentType.type,
    this.description = '',
    this.path = '',
    this.meaning = '',
    this.data,
    this.structuredData,
  });

  factory SemanticIntentFile.fromYaml(final String path, final String yaml) {
    final json = yamlToJson(yaml);
    final data = json['semantic_intent'] as Map<String, dynamic>;
    final structuredData = StructuredIntentData.fromYaml(data);

    return SemanticIntentFile(
      name: SemanticIntentName(data['name'] as String),
      type: SemanticIntentType.fromJson(data['type'] as String),
      description: data['description'] as String,
      meaning: data['meaning'] as String,
      path: path,
      data: yaml,
      structuredData: structuredData,
    );
  }

  String toYaml() {
    if (structuredData != null) {
      return structuredData!.toYaml();
    }

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

  /// Gets the intent file name without extension
  String get intentFileName => path.split('/').last.split('.').first;

  /// The name of the intent
  final SemanticIntentName name;

  /// The core meaning of the intent
  final String meaning;

  /// Detailed description of the intent
  final String description;

  /// The type of the intent
  final SemanticIntentType type;

  /// The path to the intent file
  final String path;

  /// The raw YAML data
  final String? data;

  /// The structured data representation of the intent
  final StructuredIntentData? structuredData;
}
