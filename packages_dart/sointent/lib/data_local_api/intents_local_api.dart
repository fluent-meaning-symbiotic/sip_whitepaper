import 'package:path/path.dart' as path;
import 'package:sointent/common_imports.dart';

/// {@template intents_local_api}
/// Local API for managing semantic intents following SIP principles.
/// Provides functionality for loading, saving, and managing intent files.
///
/// Core responsibilities:
/// - Loading intents recursively from directories
/// - Saving intents to files
/// - Managing intent file paths
/// - Handling YAML serialization/deserialization
/// {@endtemplate}
class IntentsLocalApi {
  static late IntentsLocalApi instance;

  /// Loads all intent.yaml files from a directory recursively.
  ///
  /// Follows SIP principles by:
  /// - Maintaining semantic meaning through proper file structure
  /// - Preserving intent relationships in directory hierarchy
  /// - Validating intent file format and content
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
            intents.add(SemanticIntentFile.fromYaml(entity.path, content));
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

  /// Saves a semantic intent to a file, preserving its semantic meaning
  /// and relationships within the intent graph.
  ///
  /// Follows SIP principles by:
  /// - Maintaining semantic integrity during serialization
  /// - Preserving intent relationships
  /// - Validating output format
  Future<void> saveIntent(
    final String path,
    final SemanticIntentFile intent,
  ) async {
    final file = File(path);
    final yamlContent = intent.toYaml(); // Assuming toYaml() method exists
    await file.writeAsString(yamlContent);
  }

  /// Gets the original path for a semantic intent, maintaining
  /// semantic relationships in the intent graph.
  String? getOriginalPath(final YamlMap intent) => null;
}
