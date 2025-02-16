import 'package:sointent/common_imports.dart';
import 'package:sointent/data_commands/loads/load_folders.cmd.dart';

/// Command to initialize the application and load initial resources
class LoadAppCommand extends SemanticCommand {
  /// Creates a new [LoadAppCommand]
  const LoadAppCommand();

  @override
  Future<void> execute() async {
    await LocalDb.instance.init();
    await const LoadFoldersCommand().execute();
  }
}
