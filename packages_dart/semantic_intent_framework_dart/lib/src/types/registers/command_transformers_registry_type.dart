import 'dart:async';

import '../../commands/commands.dart';

class CommandTransformersRegistryType {
  CommandTransformersRegistryType();

  final _transformers =
      <SemanticReactiveCommandStreamName, Map<Type, List<Function>>>{};

  void addTransformer<T extends SemanticReactiveCommand>(
    SemanticReactiveCommandStreamName streamName,
    Stream<T> Function(Stream<T>) transformer,
  ) {
    _transformers[streamName] ??= {};
    final typeTransformers = _transformers[streamName]!;
    typeTransformers[T] ??= [];
    typeTransformers[T]!.add(transformer);
  }

  List<Stream<T> Function(Stream<T>)>?
      getTransformers<T extends SemanticReactiveCommand>(
    SemanticReactiveCommandStreamName streamName,
  ) {
    if (!_transformers.containsKey(streamName) ||
        !_transformers[streamName]!.containsKey(T)) {
      return null;
    }

    return _transformers[streamName]![T]!
        .cast<Stream<T> Function(Stream<T>)>()
        .toList();
  }

  void dispose() {
    _transformers.clear();
  }
}
