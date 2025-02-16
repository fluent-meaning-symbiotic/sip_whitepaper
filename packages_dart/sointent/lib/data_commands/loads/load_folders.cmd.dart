import 'package:sointent/common_imports.dart';

/// Command to load folders from local storage
class LoadFoldersCommand extends SemanticCommand {
  /// Creates a new [LoadFoldersCommand]
  const LoadFoldersCommand();

  @override
  Future<void> execute() async {
    final foldersLocalApi = FoldersLocalApi();
    final recentPaths = await foldersLocalApi.getRecentPaths();
    FoldersResource.instance.assignAll(recentPaths);
  }
}
