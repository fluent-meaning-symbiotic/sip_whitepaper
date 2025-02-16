import 'package:sointent/common_imports.dart';

/// Controller for managing the state of the structured intent editor
class StructuredIntentController extends ChangeNotifier {
  /// Creates a new instance of [StructuredIntentController]
  StructuredIntentController({
    required final SemanticIntentFile data,
    required this.onChanged,
    this.onValidationError,
  }) : _data = data.structuredData!;

  /// The current intent data
  StructuredIntentData get data => _data;
  StructuredIntentData _data;

  /// Callback when the intent data changes
  final ValueChanged<String> onChanged;

  /// Callback when validation errors occur
  final ValueChanged<String>? onValidationError;

  /// Updates the basic properties of the intent
  void updateBasicProperties({
    final String? name,
    final String? type,
    final String? meaning,
    final String? description,
  }) {
    _data = _data.copyWith(
      name: name,
      type: type,
      meaning: meaning,
      description: description,
    );
    _notifyChanges();
  }

  /// Updates the semantic properties of the intent
  void updateSemanticProperties(final Map<String, dynamic> properties) {
    _data = _data.copyWith(
      semanticProperties: {..._data.semanticProperties, ...properties},
    );
    _notifyChanges();
  }

  /// Updates the semantic interactions of the intent
  void updateSemanticInteractions(final Map<String, dynamic> interactions) {
    _data = _data.copyWith(
      semanticInteractions: {..._data.semanticInteractions, ...interactions},
    );
    _notifyChanges();
  }

  /// Updates the test categories of the intent
  void updateTestCategories(final Map<String, dynamic> categories) {
    _data = _data.copyWith(
      testCategories: {..._data.testCategories, ...categories},
    );
    _notifyChanges();
  }

  /// Updates the semantic validations of the intent
  void updateSemanticValidations(final List<String> validations) {
    _data = _data.copyWith(
      semanticValidations: [..._data.semanticValidations, ...validations],
    );
    _notifyChanges();
  }

  /// Updates the output artifacts of the intent
  void updateOutputArtifacts(final Map<String, dynamic> artifacts) {
    _data = _data.copyWith(
      outputArtifacts: {..._data.outputArtifacts, ...artifacts},
    );
    _notifyChanges();
  }

  /// Updates the LLM prompts of the intent
  void updateLlmPrompts(final Map<String, dynamic> prompts) {
    _data = _data.copyWith(llmPrompts: {..._data.llmPrompts, ...prompts});
    _notifyChanges();
  }

  /// Updates the scratchpad todos of the intent
  void updateScratchpadTodo(final String todos) {
    _data = _data.copyWith(scratchpadTodo: todos);
    _notifyChanges();
  }

  void _notifyChanges() {
    notifyListeners();
    try {
      onChanged(_data.toYaml());
    } catch (e) {
      onValidationError?.call(e.toString());
    }
  }
}
