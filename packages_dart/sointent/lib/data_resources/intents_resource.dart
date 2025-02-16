import 'package:sointent/common_imports.dart';

/// Resource for managing semantic intents
class IntentsResource
    extends OrderedMapNotifier<SemanticIntentName, SemanticIntentFile> {
  /// Creates a new [IntentsResource]
  IntentsResource();

  /// Singleton instance
  static late IntentsResource instance;
}
