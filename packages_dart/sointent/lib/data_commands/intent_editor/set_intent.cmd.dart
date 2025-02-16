import 'package:sointent/common_imports.dart';
import 'package:sointent/data_models/semantic_intent_file.dart';
import 'package:sointent/data_resources/intent_editor_resource.dart';

/// Command to set the current intent for editing
class SetIntentCommand {
  /// Creates a new instance of [SetIntentCommand]
  const SetIntentCommand({required this.intent});

  /// The intent to set
  final SemanticIntentFile intent;

  /// Executes the command
  void execute() {
    IntentEditorResource.instance.updateState(
      currentIntent: intent,
      isDirty: false,
    );
  }
}
