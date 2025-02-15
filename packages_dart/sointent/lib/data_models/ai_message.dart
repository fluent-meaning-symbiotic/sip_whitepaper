extension type const AiMessageTimestamp(DateTime value) {}

class AiMessage {
  const AiMessage({
    this.content = '',
    this.role = '',
    this.timestamp,
    this.chatMessageJson = const {},
  });
  final String content;
  final String role;
  final AiMessageTimestamp? timestamp;
  final Map<String, dynamic> chatMessageJson;
  static const empty = AiMessage();
}
