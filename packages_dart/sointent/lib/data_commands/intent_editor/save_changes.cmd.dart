import 'dart:io';

import 'package:sointent/common_imports.dart';
import 'package:sointent/data_resources/intent_editor_resource.dart';

/// Command to save changes to the current intent
class SaveChangesCommand {
  /// Creates a new instance of [SaveChangesCommand]
  const SaveChangesCommand();

  /// Executes the command
  Future<void> execute() async {
    final editor = IntentEditorResource.instance;
    final currentIntent = editor.currentIntent;
    final pendingChanges = editor.pendingChanges;

    if (currentIntent == null || pendingChanges == null || !editor.isDirty) {
      return;
    }

    try {
      final file = File(currentIntent.path);

      // Create backup
      final backupPath = '${currentIntent.path}.bak';
      if (file.existsSync()) {
        file.copySync(backupPath);
      }

      // Write new content
      file.writeAsStringSync(pendingChanges);

      // Delete backup on success
      final backup = File(backupPath);
      if (backup.existsSync()) {
        backup.deleteSync();
      }

      editor.updateState(isDirty: false);
    } catch (e) {
      // Restore from backup if available
      final file = File(currentIntent.path);
      final backupPath = '${currentIntent.path}.bak';
      final backup = File(backupPath);

      if (backup.existsSync()) {
        backup.copySync(currentIntent.path);
        backup.deleteSync();
      }

      rethrow;
    }
  }
}
