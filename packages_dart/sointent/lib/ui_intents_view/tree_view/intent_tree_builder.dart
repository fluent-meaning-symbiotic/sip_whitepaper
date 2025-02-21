import 'package:sointent/common_imports.dart';

/// {@template tree_node}
/// Represents a node in the semantic intent tree structure.
/// Each node can be either a file (containing an intent) or a directory
/// containing other nodes.
/// {@endtemplate}
@immutable
class TreeNode {
  /// {@macro tree_node}
  const TreeNode({
    required this.name,
    required this.path,
    this.intent,
    final Map<String, TreeNode>? children,
  }) : children = children ?? const {};

  /// The display name of the node
  final String name;

  /// The full path to this node in the tree
  final String path;

  /// The semantic intent file associated with this node, if it's a file node
  final SemanticIntentFile? intent;

  /// Child nodes mapped by their names
  final Map<String, TreeNode> children;

  /// Whether this node represents a file (has an associated intent)
  bool get isFile => intent != null;

  /// Whether this node represents a directory (has children)
  bool get isDirectory => children.isNotEmpty;

  @override
  String toString() =>
      'TreeNode(name: $name, path: $path, intent: $intent, children: $children)';
}

/// {@template intent_tree_builder}
/// Utility class for building and managing the semantic intent tree structure.
/// Converts a flat list of [SemanticIntentFile]s into a hierarchical tree structure
/// that can be used for display and navigation.
/// {@endtemplate}
class IntentTreeBuilder {
  IntentTreeBuilder._();

  /// Creates a tree structure from a list of semantic intent files.
  ///
  /// The resulting tree structure represents the hierarchical organization of the
  /// intent files, with directories as intermediate nodes and files as leaf nodes.
  ///
  /// [intents] - The list of semantic intent files to organize into a tree.
  /// Returns a [TreeNode] representing the root of the tree.
  static TreeNode buildFromIntents({
    required final Iterable<SemanticIntentFile> intents,
    required final String projectPath,
  }) {
    if (intents.isEmpty) {
      return const TreeNode(name: 'root', path: '', children: {});
    }

    // Sort intents by path for consistent ordering
    final sortedIntents = List<SemanticIntentFile>.from(intents)
      ..sort((final a, final b) => a.path.compareTo(b.path));

    // First pass: collect all paths and create path-to-intent mapping
    final Map<String, SemanticIntentFile> intentsByPath = {};
    final Set<String> allParentPaths = {};

    for (final intent in sortedIntents) {
      // Normalize path by removing leading/trailing slashes
      final normalizedPath = intent
          .getRelativePath(projectPath)
          .trim()
          .replaceAll(RegExp(r'^/+|/+$'), '');
      if (normalizedPath.isEmpty) continue;

      intentsByPath[normalizedPath] = intent;
      _addParentPaths(normalizedPath, allParentPaths);

      // Debug logging
      debugPrint('Added intent path: $normalizedPath');
      debugPrint('Current allParentPaths: $allParentPaths');
    }

    if (allParentPaths.isEmpty) {
      debugPrint('No paths were processed. Input intents: $sortedIntents');
      return const TreeNode(name: 'root', path: '', children: {});
    }

    // Build tree recursively starting from root
    return _buildNode('', allParentPaths, intentsByPath);
  }

  /// Adds all parent paths for a given path to the paths set
  static void _addParentPaths(final String path, final Set<String> paths) {
    if (path.isEmpty) return;

    final segments = path.split('/')
      ..removeWhere((final segment) => segment.isEmpty);

    var currentPath = '';
    for (final segment in segments) {
      currentPath = currentPath.isEmpty ? segment : '$currentPath/$segment';
      paths.add(currentPath);
      debugPrint('Added parent path: $currentPath');
    }
  }

  /// Recursively builds a node and its children for a given path
  static TreeNode _buildNode(
    final String path,
    final Set<String> allParentPaths,
    final Map<String, SemanticIntentFile> intentsByPath,
  ) {
    debugPrint('Building node for path: "$path"');

    final List<String> childPaths =
        allParentPaths.where((final p) {
            if (path.isEmpty) {
              // For root, get top-level paths (no slashes)
              return !p.contains('/');
            }
            // For other paths, get immediate children
            final relativePath =
                p.startsWith('$path/') ? p.substring(path.length + 1) : p;
            return p.startsWith('$path/') && !relativePath.contains('/');
          }).toList()
          ..sort();

    debugPrint('Found child paths: $childPaths');

    final Map<String, TreeNode> children = {};

    for (final childPath in childPaths) {
      final name =
          path.isEmpty ? childPath : childPath.substring(path.length + 1);
      final intent = intentsByPath[childPath];

      debugPrint(
        'Processing child: path=$childPath, name=$name, hasIntent=${intent != null}',
      );

      children[name] =
          intent != null
              ? TreeNode(
                name: intent.name.value,
                path: childPath,
                intent: intent,
              )
              : _buildNode(childPath, allParentPaths, intentsByPath);
    }

    final nodeName = path.isEmpty ? 'root' : path.split('/').last;
    debugPrint(
      'Created node: name=$nodeName, path=$path, childCount=${children.length}',
    );

    return TreeNode(name: nodeName, path: path, children: children);
  }
}
