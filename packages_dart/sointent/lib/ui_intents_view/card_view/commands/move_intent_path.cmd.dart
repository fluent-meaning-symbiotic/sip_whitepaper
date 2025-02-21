import 'package:sointent/common_imports.dart';
import 'package:sointent/data_commands/search/search_intents.cmd.dart';
import 'package:sointent/data_resources/intent_editor_resource.dart';

class MoveIntentPathCommand extends SemanticCommand {
  const MoveIntentPathCommand({required this.intent, required this.newPath});

  final SemanticIntentFile intent;
  final String newPath;

  @override
  Future<void> execute() async {
    try {
      // TODO: Implement actual file system move
      // For now, just update the path in the editor
      final updatedIntent = SemanticIntentFile(
        path: newPath,
        type: intent.type,
        name: intent.name,
        meaning: intent.meaning,
        description: intent.description,
        data: intent.data,
        structuredData: intent.structuredData,
      );

      IntentEditorResource.instance.updateState(
        currentIntent: updatedIntent,
        isDirty: true,
      );

      // Update the selected intent
      SelectedIntentResource.instance.value = updatedIntent;

      // Trigger a refresh of the filtered intents
      await SearchIntentsCommand(
        query: IntentSearchResource.instance.value,
      ).execute();
    } catch (e) {
      print('Error moving intent: $e'); // For debugging
      rethrow;
    }
  }
}
