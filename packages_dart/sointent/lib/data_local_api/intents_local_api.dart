import 'package:path/path.dart' as path;
import 'package:sointent/common_imports.dart';

///  for managing semantic intents
class IntentsLocalApi {
  static late IntentsLocalApi instance;

  /// Loads all intent.yaml files from a directory recursively
  Future<List<SemanticIntentFile>> getRecursiveIntents({
    required final String dirPath,
  }) async {
    print('Loading intents from directory: $dirPath');
    final intents = <SemanticIntentFile>[];
    final dir = Directory(dirPath);

    try {
      if (!dir.existsSync()) {
        print('Directory not found: $dirPath');
        throw Exception('Directory not found: $dirPath');
      }

      await for (final entity in dir.list(recursive: true)) {
        if (entity is File &&
            path.basename(entity.path).endsWith('intent.yaml')) {
          try {
            print('Found intent file: ${entity.path}');
            final content = await entity.readAsString();
            final yaml = loadYaml(content) as Map;
            intents.add(
              SemanticIntentFile.fromYaml(
                entity.path,
                Map<String, dynamic>.from(yaml),
              ),
            );
            print('Successfully loaded intent from: ${entity.path}');
          } catch (e) {
            print('Error loading intent from ${entity.path}: $e');
          }
        }
      }

      print('Total intents loaded: ${intents.length}');
      return intents;
    } catch (e) {
      print('Error scanning directory: $e');
      rethrow;
    }
  }

  /// Saves a semantic intent to a file
  Future<void> saveIntent(
    final String path,
    final SemanticIntentFile intent,
  ) async {
    final file = File(path);
    final yamlContent = intent.toYaml(); // Assuming toYaml() method exists
    await file.writeAsString(yamlContent);
  }

  /// Gets the original path for a semantic intent
  String? getOriginalPath(final YamlMap intent) => null;
}
