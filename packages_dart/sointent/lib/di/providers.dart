import 'package:sointent/common_imports.dart';

/// Provides all application resources
List<InheritedProvider> resourceProviders = [
  Provider<PrefsDb>(
    lazy: false,
    create:
        (final context) => PrefsDb()..also((final it) => LocalDb.instance = it),
  ),
  Provider<IntentsLocalApi>(
    lazy: false,
    create:
        (final context) =>
            IntentsLocalApi()
              ..also((final it) => IntentsLocalApi.instance = it),
  ),
  Provider<AiClient>(
    lazy: false,
    create:
        (final context) =>
            AiClient(baseUrl: Envs.openAiBaseUrl, modelId: Envs.openApiModel)
              ..also((final it) => AiClient.instance = it),
  ),
  ChangeNotifierProvider<AppStateResource>(
    lazy: false,
    create:
        (_) =>
            AppStateResource()
              ..also((final it) => AppStateResource.instance = it),
  ),
  ChangeNotifierProvider<DialogMessagesResource>(
    lazy: false,
    create:
        (final context) =>
            DialogMessagesResource()
              ..also((final it) => DialogMessagesResource.instance = it),
  ),
  ChangeNotifierProvider<IntentsResource>(
    lazy: false,
    create:
        (final context) =>
            IntentsResource()
              ..also((final it) => IntentsResource.instance = it),
  ),
  ChangeNotifierProvider<FoldersResource>(
    lazy: false,
    create:
        (final context) =>
            FoldersResource()
              ..also((final it) => FoldersResource.instance = it),
  ),
];

/// Extension to initialize a resource and assign it to its singleton instance
extension ResourceInitializer<T> on T {
  /// Initializes the resource and assigns it to its singleton instance
  T also(final void Function(T) block) {
    block(this);
    return this;
  }
}
