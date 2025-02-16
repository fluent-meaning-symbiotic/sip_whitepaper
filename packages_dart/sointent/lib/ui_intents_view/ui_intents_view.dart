import 'package:sointent/common_imports.dart';

/// Tree node data structure for the intent view
@immutable
class TreeNode {
  const TreeNode({
    required this.name,
    required this.path,
    this.intent,
    this.children = const {},
  });

  final String name;
  final String path;
  final SemanticIntentFile? intent;
  final Map<String, TreeNode> children;

  bool get isFile => intent != null;

  TreeNode copyWith({
    final String? name,
    final String? path,
    final SemanticIntentFile? intent,
    final Map<String, TreeNode>? children,
  }) => TreeNode(
    name: name ?? this.name,
    path: path ?? this.path,
    intent: intent ?? this.intent,
    children: children ?? this.children,
  );

  TreeNode addChild(final String key, final TreeNode child) =>
      copyWith(children: {...children, key: child});
}

/// {@template ui_intents_view}
/// A widget that displays a hierarchical tree view of semantic intents.
/// Each node in the tree represents a path segment or an intent file.
/// {@endtemplate}
class UiIntentsView extends StatefulWidget {
  /// {@macro ui_intents_view}
  const UiIntentsView({super.key});

  @override
  State<UiIntentsView> createState() => _UiIntentsViewState();
}

class _UiIntentsViewState extends State<UiIntentsView> {
  late TreeNode _root;
  late Set<String> _expandedPaths;
  String? _selectedPath;

  @override
  void initState() {
    super.initState();
    _expandedPaths = {};
    _initializeTree();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeTree();
  }

  void _initializeTree() {
    final intentsResource = context.read<IntentsResource>();
    _root = _buildTree(intentsResource.orderedValues.toList());
  }

  /// Builds tree structure from intents
  TreeNode _buildTree(final List<SemanticIntentFile> intents) {
    TreeNode root = const TreeNode(name: 'root', path: '');

    for (final intent in intents) {
      final segments = intent.path.split('/');
      var currentNode = root;
      var currentPath = '';

      // Build path nodes
      for (var i = 0; i < segments.length - 1; i++) {
        final segment = segments[i];
        currentPath = currentPath.isEmpty ? segment : '$currentPath/$segment';

        if (!currentNode.children.containsKey(segment)) {
          final newNode = TreeNode(name: segment, path: currentPath);
          currentNode = currentNode.addChild(segment, newNode);
        } else {
          currentNode = currentNode.children[segment]!;
        }
      }

      // Add leaf (intent) node
      final fileName = segments.last;
      final leafNode = TreeNode(
        name: fileName,
        path: intent.path,
        intent: intent,
      );
      root = _updateNodeAtPath(
        root,
        currentNode.path,
        (final node) => node.addChild(fileName, leafNode),
      );
    }

    return root;
  }

  /// Updates a node at the specified path in the tree
  TreeNode _updateNodeAtPath(
    final TreeNode root,
    final String path,
    final TreeNode Function(TreeNode node) updater,
  ) {
    if (path.isEmpty) return updater(root);

    final segments = path.split('/');
    TreeNode currentNode = root;

    for (final segment in segments) {
      if (!currentNode.children.containsKey(segment)) {
        return root;
      }
      currentNode = currentNode.children[segment]!;
    }

    return _updateNode(root, path, updater);
  }

  /// Recursively updates a node in the tree
  TreeNode _updateNode(
    final TreeNode node,
    final String path,
    final TreeNode Function(TreeNode node) updater,
  ) {
    if (node.path == path) return updater(node);

    final newChildren = Map<String, TreeNode>.from(node.children);
    for (final entry in node.children.entries) {
      if (path.startsWith(entry.value.path)) {
        newChildren[entry.key] = _updateNode(entry.value, path, updater);
      }
    }

    return node.copyWith(children: newChildren);
  }

  void _handleExpand(final String path) {
    setState(() {
      if (_expandedPaths.contains(path)) {
        _expandedPaths = _expandedPaths.where((final p) => p != path).toSet();
      } else {
        _expandedPaths = {..._expandedPaths, path};
      }
    });
  }

  void _handleSelect(final String path) {
    setState(() {
      _selectedPath = path;
    });
  }

  /// Builds a tree item widget
  Widget _buildTreeItem(final TreeNode node, {required final int depth}) {
    final theme = Theme.of(context);
    final isExpanded = _expandedPaths.contains(node.path);
    final isSelected = node.path == _selectedPath;

    if (node.isFile) {
      return Padding(
        padding: EdgeInsets.only(left: (depth * 24).toDouble()),
        child: ListTile(
          dense: true,
          leading: Icon(
            Icons.description,
            size: 20,
            color: theme.colorScheme.primary.withOpacity(0.7),
          ),
          title: Text(
            node.intent!.name.value,
            style: theme.textTheme.bodyMedium,
          ),
          subtitle: Text(
            node.intent!.type.name,
            style: theme.textTheme.bodySmall,
          ),
          selected: isSelected,
          selectedTileColor: theme.colorScheme.primaryContainer.withOpacity(
            0.3,
          ),
          onTap: () => _handleSelect(node.path),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => _handleExpand(node.path),
          child: Padding(
            padding: EdgeInsets.only(
              left: (depth * 24).toDouble(),
              top: 8,
              bottom: 8,
            ),
            child: Row(
              children: [
                Icon(
                  isExpanded ? Icons.expand_more : Icons.chevron_right,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Icon(Icons.folder, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(node.name, style: theme.textTheme.bodyMedium),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) ...[
          ...node.children.values.map(
            (final child) => _buildTreeItem(child, depth: depth + 1),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(final BuildContext context) => Card(
    margin: const EdgeInsets.all(8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search bar (to be implemented)
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search intents...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
            ),
          ),
        ),
        // Tree view
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _buildTreeItem(_root, depth: 0),
          ),
        ),
      ],
    ),
  );
}
