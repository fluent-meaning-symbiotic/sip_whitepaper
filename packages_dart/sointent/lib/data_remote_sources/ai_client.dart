import 'package:openai_dart/openai_dart.dart';
import 'package:sointent/common_imports.dart';

/// Service for handling AI agent operations and communication with OpenAI/LM Studio
class AiClient {
  /// Creates an [AiClient] with the provided OpenAI client
  AiClient({required final String baseUrl, required this.modelId})
    : _openAI = OpenAIClient(baseUrl: baseUrl);
  final OpenAIClient _openAI;
  final String modelId;

  /// Processes a user message and returns an AI response
  ///
  /// Takes a [message] string and conversation [history] to maintain context
  /// Returns an [AiResponse] containing either the AI's message or an error
  Future<AiResponse> processMessage(
    final String message,
    final List<AiMessage> history,
  ) async {
    try {
      final messages = [
        ...history.map(
          (final msg) => ChatCompletionMessage.fromJson(msg.chatMessageJson),
        ),
        ChatCompletionMessage.user(
          content: ChatCompletionUserMessageContent.string(message),
        ),
      ];

      final response = await _openAI.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: ChatCompletionModel.modelId(modelId),
          messages: messages,
        ),
      );

      if (response.choices.isEmpty) {
        throw Exception('No response from AI');
      }
      final responseMessage = response.choices.first.message;
      return AiResponse(
        message: AiMessage(
          chatMessageJson: responseMessage.toJson(),
          content: responseMessage.content ?? '',
          role: 'assistant',
          timestamp: AiMessageTimestamp(DateTime.now()),
        ),
      );
    } catch (e) {
      return AiResponse(error: e.toString());
    }
  }
}
