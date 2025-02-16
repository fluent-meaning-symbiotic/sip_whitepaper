import 'package:sointent/common_imports.dart';
import 'package:sointent/data_models/intent_types.dart';
import 'package:sointent/data_resources/intents_search_resource.dart';

/// Command to sort filtered intents
class SortIntentsCommand extends SemanticCommand {
  /// Creates a new [SortIntentsCommand]
  const SortIntentsCommand({required this.mode});

  /// The sort mode to apply
  final IntentSortMode mode;

  @override
  Future<void> execute() async {
    // Update sort mode
    IntentSortResource.instance.value = mode;

    // Get filtered intents
    final intents = FilteredIntentsResource.instance.orderedValues.toList();

    // Apply sorting
    switch (mode) {
      case IntentSortMode.byName:
        intents.sort(
          (final a, final b) => a.name.value.compareTo(b.name.value),
        );
      case IntentSortMode.byLastModified:
        // TODO: Implement last modified sorting when available
        break;
      case IntentSortMode.byType:
        intents.sort((final a, final b) => a.type.name.compareTo(b.type.name));
    }

    // Update filtered intents with new order
    FilteredIntentsResource.instance.assignAll(
      intents.toMap(
        toKey: (final intent) => intent.name,
        toValue: (final intent) => intent,
      ),
    );
  }
}
