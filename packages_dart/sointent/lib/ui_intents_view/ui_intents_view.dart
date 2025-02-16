import 'dart:async';

import 'package:sointent/common_imports.dart';
import 'package:sointent/data_commands/search/search_intents.cmd.dart';
import 'package:sointent/data_resources/intents_search_resource.dart';
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
  late final Set<String> _expandedPaths;
  String? _selectedPath;
  final String _folderName = IntentsFolderResource.instance.folderName;
  TreeNode? _root;
  List<TreeNode> _visibleNodes = [];
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _expandedPaths = {};
    _searchController = TextEditingController(
      text: IntentSearchResource.instance.value,
    );
    unawaited(_initializeView());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeView() async {
    // Initialize filtered intents with current search query
    await SearchIntentsCommand(
      query: IntentSearchResource.instance.value,
    ).execute();
    if (!mounted) return;

    setState(_initializeTree);
  }

  void _initializeTree() {
    final root =
        _root = IntentTreeBuilder.buildFromIntents(
          intents: FilteredIntentsResource.instance.orderedValues,
          projectPath: IntentsFolderResource.instance.value,
        );
    // Expand root by default
    _expandedPaths.add('');
    _updateVisibleNodes(root);
  }

  void _updateVisibleNodes(final TreeNode root) {
    _visibleNodes = [];
    void addVisibleNodes(final TreeNode node) {
      _visibleNodes.add(node);
      if (_expandedPaths.contains(node.path)) {
        node.children.values.forEach(addVisibleNodes);
      }
    }

    addVisibleNodes(root);
  }

  void _handleExpand(final String path) {
    setState(() {
      if (_expandedPaths.contains(path)) {
        _expandedPaths.remove(path);
      } else {
        _expandedPaths.add(path);
      }
      _updateVisibleNodes(_root!);
    });
  }

  void _handleSelect(final String path) {
    setState(() {
      _selectedPath = path;
    });
  }

  Future<void> _handleSearch(final String query) async {
    await SearchIntentsCommand(query: query).execute();
    if (mounted) setState(_initializeTree);
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
  Widget build(final BuildContext context) {
    // Listen to search query changes to update controller if changed externally
    final searchQuery = context.watch<IntentSearchResource>().value;
    if (searchQuery != _searchController.text) {
      _searchController.text = searchQuery;
    }

    final sortMode = context.watch<IntentSortResource>().value;
    final root = _root;
    if (root == null) return const CircularProgressIndicator();

    return Card(
      margin: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search and Sort Controls
          Row(
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 300),
                    height: 36,
                    child: TextField(
                      style: Theme.of(context).textTheme.bodySmall,
                      controller: _searchController,
                      onChanged: _handleSearch,
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
              ),
            ],
          ),
          // Tree View
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: _buildTreeItem(root, depth: 0),
            ),
          ),
        ],
      ),
    );
  }
}
