import 'package:sointent/common_imports.dart';

/// Initializes dependency injection for the application
Future<void> initDI() async {
  // Initialize local storage
  final semanticIntentLocalApi = IntentsLocalApi();

  // Initialize AI client
  final aiClient = AiClient(
    baseUrl: Envs.openAiBaseUrl,
    modelId: Envs.openApiModel,
  );

  // Initialize resources
  AppStateResource.instance = AppStateResource();
  IntentsResource.instance = IntentsResource(
    intentsLocalApi: semanticIntentLocalApi,
  );
  DialogMessagesResource.instance = DialogMessagesResource(aiClient: aiClient);
}
