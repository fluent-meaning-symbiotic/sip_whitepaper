import 'package:sointent/common_imports.dart';
import 'package:sointent/ui_intents_view/intent_tree_builder.dart';
import 'package:sointent/ui_intents_view/ui_tree_item.dart';

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
  final String _folderName = IntentsFolderResource.instance.folderName;

  @override
  void initState() {
    super.initState();
    _expandedPaths = {};
    _initializeTree();
  }

  void _initializeTree() {
    final intentsResource = context.read<IntentsResource>();
    _root = IntentTreeBuilder.buildFromIntents(
      intents: intentsResource.orderedValues,
      projectPath: IntentsFolderResource.instance.value,
    );
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

  Widget _buildTreeItem(final TreeNode node, {required final int depth}) =>
      UiTreeItem(
        node: node,
        depth: depth,
        isExpanded: _expandedPaths.contains(node.path),
        isSelected: _selectedPath == node.path,
        onExpand: () => _handleExpand(node.path),
        onSelect: () => _handleSelect(node.path),
        rootName: _folderName,
        children:
            node.children.values
                .map((final child) => _buildTreeItem(child, depth: depth + 1))
                .toList(),
      );

  @override
  Widget build(final BuildContext context) => Card(
    margin: const EdgeInsets.all(4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(4),
          child: SizedBox(
            height: 36,
            child: TextField(
              style: Theme.of(context).textTheme.bodySmall,
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search intents...',
                hintStyle: Theme.of(context).textTheme.bodySmall,
                prefixIcon: const Icon(Icons.search, size: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 8,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: _buildTreeItem(_root, depth: 0),
          ),
        ),
      ],
    ),
  );
}
