import 'package:sointent/common_imports.dart';

/// Initializes dependency injection for the application
Future<void> initDI() async {
  // Initialize local storage
  final semanticIntentLocalApi = SemanticIntentLocalApi();
  await semanticIntentLocalApi.init();

  // Initialize AI client
  final aiClient = AiClient();

  // Initialize resources
  AppStateResource.instance = AppStateResource();
  SemanticIntentsResource.instance = SemanticIntentsResource(
    semanticIntentLocalApi: semanticIntentLocalApi,
  );
  DialogMessagesResource.instance = DialogMessagesResource(aiClient: aiClient);
}
