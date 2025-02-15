import 'package:sointent/common_imports.dart';
import 'package:sointent/core/utils/ordered_map_notifier.dart';

/// Resource for managing dialog messages
class DialogMessagesResource
    extends OrderedMapNotifier<AiMessageTimestamp, AiMessage> {
  /// Creates a new [DialogMessagesResource]
  DialogMessagesResource({required this.aiClient});

  /// AI client for message processing
  final AiClient aiClient;

  /// Singleton instance
  static late DialogMessagesResource instance;
}
