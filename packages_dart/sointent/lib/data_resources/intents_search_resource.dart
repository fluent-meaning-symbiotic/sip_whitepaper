import 'package:sointent/common_imports.dart';
import 'package:sointent/data_models/intent_types.dart';

/// Resource for managing intent search state
class IntentSearchResource extends ValueNotifier<String> {
  /// Creates a new [IntentSearchResource]
  IntentSearchResource() : super('');

  /// Singleton instance
  static late IntentSearchResource instance;
}

/// Resource for managing intent sort mode
class IntentSortResource extends ValueNotifier<IntentSortMode> {
  /// Creates a new [IntentSortResource]
  IntentSortResource() : super(IntentSortMode.byName);

  /// Singleton instance
  static late IntentSortResource instance;
}

/// Resource for managing filtered intents
class FilteredIntentsResource
    extends OrderedMapNotifier<SemanticIntentName, SemanticIntentFile> {
  /// Creates a new [FilteredIntentsResource]
  FilteredIntentsResource() : super();

  /// Singleton instance
  static late FilteredIntentsResource instance;
}
