/// Client for interacting with AI services
class AiClient {
  /// Creates a new [AiClient]
  const AiClient({required this.baseUrl, required this.modelId});

  /// The base URL for the AI service
  final String baseUrl;

  /// The model ID to use
  final String modelId;
}

/// Message from an AI service
class AiMessage {
  /// Creates a new [AiMessage]
  const AiMessage({required this.content, required this.timestamp});

  /// The message content
  final String content;

  /// The message timestamp
  final DateTime timestamp;
}

/// Timestamp for an AI message
class AiMessageTimestamp {
  /// Creates a new [AiMessageTimestamp]
  const AiMessageTimestamp({required this.timestamp});

  /// The timestamp
  final DateTime timestamp;
}
