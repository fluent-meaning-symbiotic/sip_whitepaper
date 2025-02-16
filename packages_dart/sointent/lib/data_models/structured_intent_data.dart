import 'dart:convert';

import 'package:sointent/common_imports.dart';
import 'package:sointent/ui_intent_editor/utils/yaml_utils.dart';

/// Represents the structured data for a semantic intent following SIP principles
@immutable
class StructuredIntentData {
  /// Creates a new instance of [StructuredIntentData]
  const StructuredIntentData({
    required this.name,
    required this.type,
    required this.meaning,
    required this.description,
    this.version = '',
    this.semanticProperties = const {},
    this.semanticInteractions = const {},
    this.testCategories = const {},
    this.semanticValidations = const [],
    this.outputArtifacts = const {},
    this.llmPrompts = const {},
    this.scratchpadTodo = '',
  });

  /// Creates a [StructuredIntentData] from YAML
  factory StructuredIntentData.fromYaml(
    final Map<String, dynamic> data,
  ) => StructuredIntentData(
    name: data['name'] as String? ?? '',
    type: data['type'] as String? ?? '',
    meaning: data['meaning'] as String? ?? '',
    description: data['description'] as String? ?? '',
    version: data['version'] as String? ?? '',
    semanticProperties:
        data['semantic_properties'] as Map<String, dynamic>? ?? {},
    semanticInteractions:
        data['semantic_interactions'] as Map<String, dynamic>? ?? {},
    testCategories: data['test_categories'] as Map<String, dynamic>? ?? {},
    semanticValidations:
        (data['semantic_validations'] as List<dynamic>?)?.cast<String>() ?? [],
    outputArtifacts: data['output_artifacts'] as Map<String, dynamic>? ?? {},
    llmPrompts: data['llm_prompts'] as Map<String, dynamic>? ?? {},
    scratchpadTodo: jsonEncode(data['scratchpad_todo'] as dynamic),
  );

  /// The version of the Semantic Intent Paradigm
  /// 0.1.0
  final String version;

  /// The name of the intent
  final String name;

  /// The type of the intent
  final String type;

  /// Core meaning of the intent's purpose
  final String meaning;

  /// Detailed description of the intent
  final String description;

  /// Semantic properties specific to the Intent Type
  final Map<String, dynamic> semanticProperties;

  /// Semantic interactions with Commands/Intents (UI Events -> Semantic Intents)
  final Map<String, dynamic> semanticInteractions;

  /// Test categories describing style of test, priority, meanings
  final Map<String, dynamic> testCategories;

  /// Validation rules for Command properties or handler
  final List<String> semanticValidations;

  /// Artifacts to generate (code files, UI component names, asset file paths, test files)
  final Map<String, dynamic> outputArtifacts;

  /// Prompts to guide LLM generation for different artifact types
  final Map<String, dynamic> llmPrompts;

  /// LLM's internal notes and todos for this Semantic Intent
  final String scratchpadTodo;

  /// Converts the intent data to YAML
  String toYaml() {
    final Map<String, dynamic> data = {
      'semantic_intent': {
        'version': version,
        'name': name,
        'type': type,
        'meaning': meaning,
        'description': description,
        if (semanticProperties.isNotEmpty)
          'semantic_properties': semanticProperties,
        if (semanticInteractions.isNotEmpty)
          'semantic_interactions': semanticInteractions,
        if (testCategories.isNotEmpty) 'test_categories': testCategories,
        if (semanticValidations.isNotEmpty)
          'semantic_validations': semanticValidations,
        if (outputArtifacts.isNotEmpty) 'output_artifacts': outputArtifacts,
        if (llmPrompts.isNotEmpty) 'llm_prompts': llmPrompts,
        if (scratchpadTodo.isNotEmpty) 'scratchpad_todo': scratchpadTodo,
      },
    };

    return jsonToYaml(data);
  }

  /// Creates a copy of this intent data with the given fields replaced
  StructuredIntentData copyWith({
    final String? version,
    final String? name,
    final String? type,
    final String? meaning,
    final String? description,
    final Map<String, dynamic>? semanticProperties,
    final Map<String, dynamic>? semanticInteractions,
    final Map<String, dynamic>? testCategories,
    final List<String>? semanticValidations,
    final Map<String, dynamic>? outputArtifacts,
    final Map<String, dynamic>? llmPrompts,
    final String? scratchpadTodo,
  }) => StructuredIntentData(
    version: version ?? this.version,
    name: name ?? this.name,
    type: type ?? this.type,
    meaning: meaning ?? this.meaning,
    description: description ?? this.description,
    semanticProperties: semanticProperties ?? this.semanticProperties,
    semanticInteractions: semanticInteractions ?? this.semanticInteractions,
    testCategories: testCategories ?? this.testCategories,
    semanticValidations: semanticValidations ?? this.semanticValidations,
    outputArtifacts: outputArtifacts ?? this.outputArtifacts,
    llmPrompts: llmPrompts ?? this.llmPrompts,
    scratchpadTodo: scratchpadTodo ?? this.scratchpadTodo,
  );
}
