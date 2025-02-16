import 'package:sointent/common_imports.dart';
import 'package:sointent/ui_intents_view/intent_tree_builder.dart';

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
  late final TreeNode _root;
  late final Set<String> _expandedPaths;
  String? _selectedPath;

  @override
  void initState() {
    super.initState();
    _expandedPaths = {};
    _initializeTree();
  }

  void _initializeTree() {
    final intentsResource = context.read<IntentsResource>();
    _root = IntentTreeBuilder.buildFromIntents(
      intentsResource.orderedValues.toList(),
    );
    print(_root);
    // Expand root by default
    _expandedPaths.add('');
  }

  void _handleExpand(final String path) {
    setState(() {
      if (_expandedPaths.contains(path)) {
        _expandedPaths.remove(path);
      } else {
        _expandedPaths.add(path);
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
          title: Text(node.name, style: theme.textTheme.bodyMedium),
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
