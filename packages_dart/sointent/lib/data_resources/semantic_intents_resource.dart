import 'package:sointent/common_imports.dart';
import 'package:sointent/core/utils/ordered_map_notifier.dart';

/// Resource for managing semantic intents
class SemanticIntentsResource
    extends OrderedMapNotifier<SemanticIntentName, SemanticIntentFile> {
  /// Creates a new [SemanticIntentsResource]
  SemanticIntentsResource({required this.semanticIntentLocalApi});

  /// Local API for semantic intents
  final SemanticIntentLocalApi semanticIntentLocalApi;

  /// Singleton instance
  static late SemanticIntentsResource instance;
}
