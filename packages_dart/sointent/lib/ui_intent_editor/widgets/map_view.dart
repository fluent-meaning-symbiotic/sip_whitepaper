import 'package:sointent/common_imports.dart';

/// A widget that displays a map of key-value pairs
class MapView extends StatelessWidget {
  /// Creates a new instance of [MapView]
  const MapView({required this.items, required this.onRemove, super.key});

  /// The items to display
  final Map<String, dynamic> items;

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

    return Column(
      children:
          items.entries
              .map(
                (final entry) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(entry.key),
                    subtitle: Text(entry.value.toString()),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => onRemove(entry.key),
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }
}
