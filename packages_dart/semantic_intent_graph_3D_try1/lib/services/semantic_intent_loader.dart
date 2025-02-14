import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

import '../model/semantic_intent_file.dart';

class SemanticIntentLoader {
  /// Loads all intent.yaml files from a directory recursively
  static Future<List<SemanticIntentFile>> loadFromDirectory(
      String dirPath) async {
    print('Loading intents from directory: $dirPath');
    final intents = <SemanticIntentFile>[];
    final dir = Directory(dirPath);

    try {
      if (!await dir.exists()) {
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
            intents.add(SemanticIntentFile.fromYaml(
              entity.path,
              Map<String, dynamic>.from(yaml),
            ));
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
}
