import '../../commands/commands.dart';

class CommandTransformersRegistryType {
  CommandTransformersRegistryType();
  final _transformers = <SemanticReactiveCommandStreamName,
      Set<SemanticReactiveCommandTransformer>>{};

  void addTransformer<T extends SemanticReactiveCommand>(
    SemanticReactiveCommandStreamName streamName,
    SemanticReactiveCommandTransformer<T> transformer,
  ) {
    final t = transformer as SemanticReactiveCommandTransformer;
    _transformers.update(
      streamName,
      (value) => value..add(t),
      ifAbsent: () => {t},
    );
  }

  Set<SemanticReactiveCommandTransformer>? getTransformers(
    SemanticReactiveCommandStreamName streamName,
  ) =>
      _transformers[streamName];

  void dispose() {
    _transformers.clear();
  }
}
