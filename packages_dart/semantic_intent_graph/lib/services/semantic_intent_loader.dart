import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

import '../model/semantic_intent_file.dart';

class SemanticIntentLoader {
  /// Loads all intent.yaml files from a directory recursively
  static Future<List<SemanticIntentFile>> loadFromDirectory(
      String dirPath) async {
    final intents = <SemanticIntentFile>[];
    final dir = Directory(dirPath);

    if (!await dir.exists()) {
      throw Exception('Directory not found: $dirPath');
    }

    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && path.basename(entity.path) == 'intent.yaml') {
        try {
          final content = await entity.readAsString();
          final yaml = loadYaml(content) as Map;
          intents.add(SemanticIntentFile.fromYaml(
            entity.path,
            Map<String, dynamic>.from(yaml),
          ));
        } catch (e) {
          print('Error loading intent from ${entity.path}: $e');
        }
      }
    }

    return intents;
  }
}
