import 'package:sointent/common_imports.dart';

/// Resource for managing dialog messages
class DialogMessagesResource
    extends OrderedMapNotifier<AiMessageTimestamp, AiMessage> {
  /// Creates a new [DialogMessagesResource]
  DialogMessagesResource();

  /// Singleton instance
  static late DialogMessagesResource instance;
}
