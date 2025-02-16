import 'package:sointent/common_imports.dart';

/// Resource for managing semantic intents
class IntentsResource
    extends OrderedMapNotifier<SemanticIntentName, SemanticIntentFile> {
  /// Creates a new [IntentsResource]
  IntentsResource() : super();

  /// Singleton instance
  static late IntentsResource instance;
}

/// Current root folder path of intents
class IntentsFolderResource extends ValueNotifier<String> {
  /// Creates a new [IntentsFolderResource]
  IntentsFolderResource() : super('');

  /// The name of the folder
  String get folderName => value.split('/').last;

  /// Singleton instance
  static late IntentsFolderResource instance;
}
