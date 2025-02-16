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
    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'No items yet. Click + to add.',
            style: TextStyle(fontStyle: FontStyle.italic),
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
                    Chip(label: Text(item), onDeleted: () => onRemove(item)),
              )
              .toList(),
    );
  }
}
