import 'package:sointent/data_models/ai_message.dart';

class AiResponse {
  const AiResponse({this.message = AiMessage.empty, this.error = ''});
  final AiMessage message;
  final String error;
}
