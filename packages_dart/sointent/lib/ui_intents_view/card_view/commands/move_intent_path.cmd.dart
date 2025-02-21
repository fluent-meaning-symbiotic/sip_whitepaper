import 'package:path/path.dart' as path;
import 'package:sointent/common_imports.dart';
import 'package:sointent/data_commands/search/search_intents.cmd.dart';
import 'package:sointent/data_resources/intent_editor_resource.dart';
import 'package:sointent/ui_intents_view/card_view/path_editor_tool.dart';

class MoveIntentPathCommand extends SemanticCommand {
  const MoveIntentPathCommand({required this.intent, required this.newPath});

  final SemanticIntentFile intent;
  final String newPath;

  Future<void> _moveFile(final String oldPath, final String newPath) async {
    final oldFile = File(oldPath);
    final newFile = File(newPath);

    // Create parent directory if it doesn't exist
    await newFile.parent.create(recursive: true);

    // Move the file
    await oldFile.rename(newPath);

    // Move associated artifacts if they exist
    final oldDir = oldFile.parent;
    final oldBaseName = path.basenameWithoutExtension(oldPath);
    final newDir = newFile.parent;
    final newBaseName = path.basenameWithoutExtension(newPath);

    // Find all artifacts with the same base name
    final artifacts =
        await oldDir
            .list()
            .where(
              (final entity) =>
                  path.basename(entity.path).startsWith(oldBaseName),
            )
            .toList();

    // Move each artifact
    for (final artifact in artifacts) {
      if (artifact.path == oldPath) continue; // Skip the main file

      final artifactExt = path.extension(artifact.path);
      final newArtifactPath = path.join(
        newDir.path,
        '$newBaseName$artifactExt',
      );

      await File(artifact.path).rename(newArtifactPath);
    }

    // Clean up empty directories
    var currentDir = oldDir;
    while (currentDir.path != IntentsFolderResource.instance.value) {
      final contents = await currentDir.list().toList();
      if (contents.isEmpty) {
        await currentDir.delete();
        currentDir = currentDir.parent;
      } else {
        break;
      }
    }
  }

  @override
  Future<void> execute() async {
    try {
      // Validate the new path
      if (!PathValidationRules.validStructure(newPath)) {
        throw ArgumentError('Invalid path structure: $newPath');
      }

      final projectPath = IntentsFolderResource.instance.value;
      final oldFullPath = path.join(projectPath, intent.path);
      final newFullPath = path.join(projectPath, newPath);

      // Move the file and its artifacts
      await _moveFile(oldFullPath, newFullPath);

      // Update the intent in the editor
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

      // Update filtered intents
      FilteredIntentsResource.instance.upsert(intent.name, updatedIntent);

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
