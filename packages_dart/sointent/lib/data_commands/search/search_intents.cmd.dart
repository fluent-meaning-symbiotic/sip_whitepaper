import 'package:sointent/common_imports.dart';
import 'package:sointent/data_resources/intents_search_resource.dart';

/// Command to search intents based on query
class SearchIntentsCommand extends SemanticCommand {
  /// Creates a new [SearchIntentsCommand]
  const SearchIntentsCommand({required this.query});

  /// The search query
  final String query;

  @override
  Future<void> execute() async {
    // Update search query
    IntentSearchResource.instance.value = query;

    // Get all intents
    final allIntents = IntentsResource.instance.orderedValues;

    // Update filtered intents
    FilteredIntentsResource.instance.assignAll(
      allIntents.toMap(
        toKey: (final intent) => intent.name,
        toValue: (final intent) => intent,
      ),
    );

    // Apply search filter if query is not empty
    if (query.isNotEmpty) {
      final filtered = allIntents.where((final intent) {
        final searchQuery = query.toLowerCase();
        final name = intent.name.value.toLowerCase();
        final type = intent.type.name.toLowerCase();
        final path = intent.path.toLowerCase();
        return name.contains(searchQuery) ||
            type.contains(searchQuery) ||
            path.contains(searchQuery);
      });

      // Update filtered intents with search results
      FilteredIntentsResource.instance.assignAll(
        filtered.toMap(
          toKey: (final intent) => intent.name,
          toValue: (final intent) => intent,
        ),
      );
    }
  }
}
