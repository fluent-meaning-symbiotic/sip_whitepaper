import 'package:sointent/common_imports.dart';
import 'package:sointent/core/core.dart';
import 'package:sointent/data_local_api/folders_local_api.dart';
import 'package:sointent/data_resources/folders_resource.dart';

/// Command to load folders from local storage
class LoadFoldersCommand extends SemanticCommand {
  /// Creates a new [LoadFoldersCommand]
  const LoadFoldersCommand();

  @override
  Future<void> execute() async {
    final foldersLocalApi = FoldersLocalApi();
    final recentPaths = await foldersLocalApi.getRecentPaths();
    FoldersResource.instance.value = recentPaths;
  }
}
