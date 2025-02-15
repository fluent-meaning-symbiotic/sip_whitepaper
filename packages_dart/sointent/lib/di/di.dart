import 'package:sointent/common_imports.dart';

/// Initializes dependency injection for the application
Future<void> initDI() async {
  // Initialize local storage
  final semanticIntentLocalApi = SemanticIntentLocalApi();

  // Initialize AI client
  final aiClient = AiClient(
    baseUrl: Envs.openAiBaseUrl,
    modelId: Envs.openApiModel,
  );

  // Initialize resources
  AppStateResource.instance = AppStateResource();
  SemanticIntentsResource.instance = SemanticIntentsResource(
    semanticIntentLocalApi: semanticIntentLocalApi,
  );
  DialogMessagesResource.instance = DialogMessagesResource(aiClient: aiClient);
}
