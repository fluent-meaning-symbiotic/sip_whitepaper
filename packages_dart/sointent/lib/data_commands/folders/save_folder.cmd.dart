import 'package:sointent/common_imports.dart';

/// Command to save a folder to the local storage
class SaveFolderCommand extends SemanticCommand {
  /// Creates a new [SaveFolderCommand]
  const SaveFolderCommand({required this.folderPath});
  final String folderPath;

  @override
  Future<void> execute() async {
    await LocalDb.instance.init();
    final foldersLocalApi = FoldersLocalApi();
    await foldersLocalApi.savePath(folderPath);
  }
}
