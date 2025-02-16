import 'package:sointent/common_imports.dart';
import 'package:sointent/ui_intents_view/intent_tree_builder.dart';

/// {@template ui_tree_item}
/// A widget that displays a single item in the tree view.
/// Can represent either a file or a folder.
/// {@endtemplate}
class UiTreeItem extends StatelessWidget {
  /// {@macro ui_tree_item}
  const UiTreeItem({
    required this.node,
    required this.depth,
    required this.isExpanded,
    required this.isSelected,
    required this.onExpand,
    required this.onSelect,
    required this.children,
    super.key,
  });

  /// The tree node to display
  final TreeNode node;

  /// The depth level in the tree
  final int depth;

  /// Whether this node is expanded
  final bool isExpanded;

  /// Whether this node is selected
  final bool isSelected;

  /// Callback when the node is expanded/collapsed
  final VoidCallback onExpand;

  /// Callback when the node is selected
  final VoidCallback onSelect;

  /// Children of the node
  final List<Widget> children;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    if (node.isFile) {
      return Padding(
        padding: EdgeInsets.only(left: (depth * 12).toDouble()),
        child: InkWell(
          onTap: onSelect,
          child: Container(
            color:
                isSelected
                    ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                    : null,
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Icon(
                  Icons.description,
                  size: 16,
                  color: theme.colorScheme.primary.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        node.name,
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        node.intent!.type.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onExpand,
          child: Padding(
            padding: EdgeInsets.only(
              left: (depth * 10).toDouble(),
              top: 2,
              bottom: 2,
              right: 2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isExpanded ? Icons.expand_more : Icons.chevron_right,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 1),
                Icon(Icons.folder, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    node.name,
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) ...[...children],
      ],
    );
  }
}
