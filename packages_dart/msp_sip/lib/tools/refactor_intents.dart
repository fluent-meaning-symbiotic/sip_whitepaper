import 'dart:io';

import 'package:path/path.dart' as path;

import '../llm/llm_provider.dart';
import '../server.dart';

/// MCP tool for refactoring multiple semantic intents
class RefactorIntentsTool extends McpTool {
  /// Creates a new instance of [RefactorIntentsTool]
  const RefactorIntentsTool({required this.llmProvider});

  /// The LLM provider to use
  final LlmProvider llmProvider;

  @override
  String get name => 'refactor_intents';

  @override
  Future<Map<String, dynamic>> execute(
    final Map<String, dynamic> parameters,
    final McpContext context,
  ) async {
    // Validate parameters
    final paths = parameters['paths'] as List<dynamic>?;
    if (paths == null || paths.isEmpty) {
      throw Exception('Missing required parameter: paths');
    }

    final changes = parameters['changes'] as String?;
    if (changes == null) {
      throw Exception('Missing required parameter: changes');
    }

    // Convert paths to strings and validate
    final intentPaths = paths.map((final p) => p as String).toList();
    final fullPaths =
        intentPaths
            .map((final p) => path.join(context.workspaceRoot, p))
            .toList();

    // Verify all files exist
    for (final p in fullPaths) {
      if (!File(p).existsSync()) {
        throw Exception('Intent file not found: $p');
      }
    }

    // Read all current content
    final currentYamls =
        fullPaths.map((final p) => File(p).readAsStringSync()).toList();

    // Generate refactored YAMLs
    final response = await llmProvider.processMessage(
      '''Refactor these semantic intent YAMLs according to these changes: $changes

Current YAMLs:
${currentYamls.asMap().entries.map((final e) => '''
File ${intentPaths[e.key]}:
${e.value}
''').join('\n')}

Follow these rules:
1. Keep consistent structure across all files
2. Update related intents together
3. Maintain semantic relationships
4. Update versions if meanings change
5. Add/update semantic validations if needed
6. Update llm_prompts if needed
7. Return map of original paths to new content
8. Suggest file renames if needed''',
      [], // Empty history for now
    );

    if (response.hasError) {
      throw Exception('Failed to refactor YAMLs: ${response.error}');
    }

    final content = response.content;
    if (content == null || content.isEmpty) {
      throw Exception('LLM returned empty content');
    }

    // Create backups
    final backups = <String, String>{};
    for (final p in fullPaths) {
      final backupPath = '$p.bak';
      File(p).copySync(backupPath);
      backups[p] = backupPath;
    }

    try {
      // Parse LLM response to get file changes
      final changes = _parseRefactorResponse(content);

      // Apply changes
      final updatedPaths = <String>[];
      for (final entry in changes.entries) {
        final originalPath = entry.key;
        final newContent = entry.value['content']!;
        final newPath = entry.value['path'] ?? originalPath;

        // Handle file rename
        if (newPath != originalPath) {
          File(originalPath).deleteSync();
          final newFullPath = path.join(context.workspaceRoot, newPath);
          final newDir = path.dirname(newFullPath);
          Directory(newDir).createSync(recursive: true);
          File(newFullPath).writeAsStringSync(newContent);
        } else {
          File(originalPath).writeAsStringSync(newContent);
        }

        updatedPaths.add(newPath);
      }

      // Delete backups on success
      for (final backup in backups.values) {
        final file = File(backup);
        if (file.existsSync()) {
          file.deleteSync();
        }
      }

      return {'updated_paths': updatedPaths};
    } catch (e) {
      // Restore from backups
      for (final entry in backups.entries) {
        final file = File(entry.key);
        final backup = File(entry.value);
        if (backup.existsSync()) {
          if (file.existsSync()) {
            file.deleteSync();
          }
          backup.copySync(entry.key);
          backup.deleteSync();
        }
      }
      rethrow;
    }
  }

  Map<String, Map<String, String>> _parseRefactorResponse(
    final String response,
  ) {
    // TODO: Implement proper parsing of LLM response
    // For now, just assume the response is a simple map of paths to content
    final changes = <String, Map<String, String>>{};

    // This is a placeholder implementation
    // The actual implementation would parse the LLM's structured response
    final lines = response.split('\n');
    String? currentPath;
    StringBuffer? currentContent;

    for (final line in lines) {
      if (line.startsWith('File: ')) {
        if (currentPath != null && currentContent != null) {
          changes[currentPath] = {
            'content': currentContent.toString(),
            'path': currentPath,
          };
        }
        currentPath = line.substring(6).trim();
        currentContent = StringBuffer();
      } else if (currentContent != null) {
        currentContent.writeln(line);
      }
    }

    if (currentPath != null && currentContent != null) {
      changes[currentPath] = {
        'content': currentContent.toString(),
        'path': currentPath,
      };
    }

    return changes;
  }
}
