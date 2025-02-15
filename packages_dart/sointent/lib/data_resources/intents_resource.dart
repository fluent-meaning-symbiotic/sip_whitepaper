import 'package:sointent/common_imports.dart';
import 'package:sointent/core/utils/ordered_map_notifier.dart';

/// Resource for managing semantic intents
class IntentsResource
    extends OrderedMapNotifier<SemanticIntentName, SemanticIntentFile> {
  /// Creates a new [IntentsResource]
  IntentsResource({required this.intentsLocalApi});

  /// Local API for semantic intents
  final IntentsLocalApi intentsLocalApi;

  /// Singleton instance
  static late IntentsResource instance;
}
