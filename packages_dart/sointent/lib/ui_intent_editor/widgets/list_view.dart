import 'package:sointent/common_imports.dart';
import 'package:sointent/ui_kit/atoms/atoms.dart';

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
                (final item) =>
                    CustomChip(label: item, onDeleted: () => onRemove(item)),
              )
              .toList(),
    );
  }
}
