import 'package:sointent/common_imports.dart';

/// API for managing folder paths in local storage
class FoldersLocalApi {
  /// Creates a new [FoldersLocalApi]
  FoldersLocalApi();
  final _prefsDb = PrefsDb();

  static const _recentPathsKey = 'recent_paths';

  /// Retrieves list of recently accessed folder paths
  Future<List<String>> getRecentPaths() async {
    final list = await _prefsDb.getStringsIterable(key: _recentPathsKey);
    return list.toList();
  }

  /// Saves a folder path to recent paths
  Future<void> savePath(final String path) async {
    final paths = await getRecentPaths();
    if (!paths.contains(path)) {
      paths.insert(0, path);
      if (paths.length > 10) paths.removeLast(); // Keep only 10 most recent
      await _prefsDb.setStringList(key: _recentPathsKey, value: paths.toList());
    }
  }

  /// Clears all stored folder paths
  Future<void> clearPaths() async {
    await _prefsDb.setStringList(key: _recentPathsKey, value: []);
  }
}
