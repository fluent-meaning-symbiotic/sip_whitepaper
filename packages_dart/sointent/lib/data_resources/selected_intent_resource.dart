import 'package:sointent/common_imports.dart';

/// Resource for managing the currently selected semantic intent
class SelectedIntentResource extends ValueNotifier<SemanticIntentFile?> {
  /// Creates a new [SelectedIntentResource]
  SelectedIntentResource() : super(null);

  /// Singleton instance
  static late SelectedIntentResource instance;
}
