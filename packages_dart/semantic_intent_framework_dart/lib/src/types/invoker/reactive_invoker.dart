import 'dart:async';

import '../../commands/commands.dart';
import '../handler/reactive_handler.dart';
import '../registers/registers.dart';

class SemanticReactiveCommandInvoker {
  SemanticReactiveCommandInvoker();

  final _handlersRegistry = CommandHandlersRegistryType();
  final _streamRegistry = ReactiveStreamRegistryType();
  final _transformersRegistry = CommandTransformersRegistryType();

  Stream<T> _getNewCommandStream<T extends SemanticReactiveCommand>(
    SemanticReactiveCommandStreamName streamName,
  ) {
    var stream = _streamRegistry.getCommandStream<T>(streamName);
    final transformers = _transformersRegistry.getTransformers<T>(streamName);
    if (transformers != null) {
      for (final transformer in transformers) {
        stream = transformer(stream);
      }
    }

    return stream;
  }

  void push<T extends SemanticReactiveCommand>(
    SemanticReactiveCommandStreamName streamName,
    T command,
  ) {
    _streamRegistry.push(streamName, command);
  }

  void registerHandler<T extends SemanticReactiveCommand>(
    SemanticReactiveCommandHandler<T> handler,
  ) {
    final stream = _getNewCommandStream<T>(handler.streamName);
    handler.subscribe(stream);
    _handlersRegistry.registerHandler<T>(handler);
  }

  void addTransformer<T extends SemanticReactiveCommand>(
    SemanticReactiveCommandStreamName streamName,
    Stream<T> Function(Stream<T>) transformer,
  ) {
    _transformersRegistry.addTransformer<T>(streamName, transformer);

    // Resubscribe all handlers for this stream to get the transformed stream
    final handlers = _handlersRegistry.getHandlersForStream(streamName);
    for (final handler in handlers) {
      final stream = _getNewCommandStream<T>(streamName);
      handler.unsubscribe();
      handler.subscribe(stream);
    }
  }

  Future<void> dispose() async {
    _handlersRegistry.dispose();
    _streamRegistry.dispose();
    _transformersRegistry.dispose();
  }
}
