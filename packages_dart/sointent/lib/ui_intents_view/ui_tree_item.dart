import 'package:sointent/common_imports.dart';
import 'package:sointent/ui_intents_view/tree_view/intent_tree_builder.dart';

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
    required this.rootName,
    super.key,
  });

  /// The name of the root folder
  final String rootName;

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
  static const fileDepth = 8;
  static const folderDepth = 8;
  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = ColorScheme.of(context);

    if (node.isFile) {
      final intent = node.intent!;
      return DefaultTextStyle.merge(
        style: theme.textTheme.bodySmall!.copyWith(
          color: colorScheme.onSurface.withOpacity(0.9),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: (depth * fileDepth).toDouble()),
          child: InkWell(
            onTap: onSelect,
            child: Container(
              color:
                  isSelected
                      ? colorScheme.primaryContainer.withOpacity(0.3)
                      : null,
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(
                    Icons.description,
                    size: 16,
                    color: colorScheme.primary.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          intent.intentFileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          intent.type.name,
                          style: theme.textTheme.labelSmall!.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
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
        ),
      );
    }

    return DefaultTextStyle.merge(
      style: theme.textTheme.bodySmall!.copyWith(
        color: colorScheme.onSurface.withOpacity(0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onExpand,
            child: Padding(
              padding: EdgeInsets.only(
                left: (depth * folderDepth).toDouble(),
                top: 4,
                bottom: 4,
                right: 2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isExpanded ? Icons.expand_more : Icons.chevron_right,
                    size: 16,
                    color: colorScheme.primary.withOpacity(0.7),
                  ),
                  const SizedBox(width: 1),
                  Icon(
                    Icons.folder,
                    size: 16,
                    color: colorScheme.primary.withOpacity(0.7),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text(
                      switch (node.name) {
                        'root' => rootName,
                        _ => node.name,
                      },
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
      ),
    );
  }
}
