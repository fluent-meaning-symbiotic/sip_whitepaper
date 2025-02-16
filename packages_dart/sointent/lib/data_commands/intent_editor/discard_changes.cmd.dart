import 'package:sointent/data_resources/intent_editor_resource.dart';

/// Command to discard changes to the current intent
class DiscardChangesCommand {
  /// Creates a new instance of [DiscardChangesCommand]
  const DiscardChangesCommand();

  /// Executes the command
  void execute() {
    IntentEditorResource.instance.updateState(isDirty: false);
  }
}
