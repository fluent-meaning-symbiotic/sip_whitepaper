import 'package:sointent/common_imports.dart';
import 'package:sointent/data_resources/intents_search_resource.dart';

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
  ChangeNotifierProvider<IntentsFolderResource>(
    lazy: false,
    create:
        (final context) =>
            IntentsFolderResource()
              ..also((final it) => IntentsFolderResource.instance = it),
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
  ChangeNotifierProvider<IntentSearchResource>(
    lazy: false,
    create:
        (final context) =>
            IntentSearchResource()
              ..also((final it) => IntentSearchResource.instance = it),
  ),
  ChangeNotifierProvider<IntentSortResource>(
    lazy: false,
    create:
        (final context) =>
            IntentSortResource()
              ..also((final it) => IntentSortResource.instance = it),
  ),
  ChangeNotifierProvider<FilteredIntentsResource>(
    lazy: false,
    create:
        (final context) =>
            FilteredIntentsResource()
              ..also((final it) => FilteredIntentsResource.instance = it),
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
