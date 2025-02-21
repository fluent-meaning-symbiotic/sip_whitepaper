import 'dart:async';

import 'package:sointent/common_imports.dart';
import 'package:sointent/data_commands/search/search_intents.cmd.dart';
import 'package:sointent/data_resources/intent_editor_resource.dart';
import 'package:sointent/ui_intents_view/card_view/ui_intent_cards_view.dart';
import 'package:sointent/ui_intents_view/tree_view/intent_tree_builder.dart';
import 'package:sointent/ui_intents_view/ui_tree_item.dart';

/// {@template ui_intents_view}
/// A widget that displays semantic intents in either a hierarchical tree view
/// or a card-based grid view. Each node/card represents a path segment or an
/// intent file. Users can switch between views while maintaining the same data
/// and interactions.
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
  bool _isCardView = false;

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
      final intent =
          FilteredIntentsResource.instance.orderedValues
              .where((final i) => i.path.endsWith(path))
              .firstOrNull;
      final currentIntentName = SelectedIntentResource.instance.value?.name;
      if (intent != null && currentIntentName != intent.name) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          IntentEditorResource.instance.updateState(
            currentIntent: intent,
            isDirty: false,
          );
          SelectedIntentResource.instance.value = intent;
        });
      }
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
    final searchQuery = context.watch<IntentSearchResource>().value;
    if (searchQuery != _searchController.text) {
      _searchController.text = searchQuery;
    }

    final root = _root;
    if (root == null) return const CircularProgressIndicator();

    return Card(
      margin: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search and View Controls
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
              // View Toggle Button
              Padding(
                padding: const EdgeInsets.all(4),
                child: IconButton(
                  icon: Icon(
                    _isCardView ? Icons.account_tree : Icons.grid_view,
                    size: 16,
                  ),
                  tooltip:
                      _isCardView
                          ? 'Switch to Tree View'
                          : 'Switch to Card View',
                  onPressed: () => setState(() => _isCardView = !_isCardView),
                ),
              ),
            ],
          ),
          // View Content
          Expanded(
            child:
                _isCardView
                    ? const UiIntentCardsView()
                    : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: _buildTreeItem(root, depth: 0),
                    ),
          ),
        ],
      ),
    );
  }
}
