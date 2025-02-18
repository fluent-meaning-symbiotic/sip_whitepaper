import 'package:sointent/common_imports.dart';

/// A widget that displays a list of strings as chips
class ChipListView extends StatelessWidget {
  /// Creates a new instance of [ChipListView]
  const ChipListView({required this.items, required this.onRemove, super.key});

  /// The items to display
  final List<String> items;

  /// Callback when an item is removed
  final ValueChanged<String> onRemove;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'No items yet. Click + to add.',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          items
              .map(
                (final item) => Chip(
                  label: Text(
                    item,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  backgroundColor: colorScheme.surface,
                  side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
                  deleteIcon: Icon(
                    Icons.cancel,
                    size: 18,
                    color: colorScheme.error,
                  ),
                  onDeleted: () => onRemove(item),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
              )
              .toList(),
    );
  }
}
