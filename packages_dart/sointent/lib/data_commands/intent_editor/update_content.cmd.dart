import 'package:sointent/data_resources/intent_editor_resource.dart';

/// Command to update the content of the current intent
class UpdateContentCommand {
  /// Creates a new instance of [UpdateContentCommand]
  const UpdateContentCommand({required this.yaml});

  /// The new YAML content
  final String yaml;

  /// Executes the command
  void execute() {
    IntentEditorResource.instance.updateState(
      pendingChanges: yaml,
      isDirty: true,
    );
  }
}
