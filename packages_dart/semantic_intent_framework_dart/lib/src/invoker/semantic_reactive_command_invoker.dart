import 'dart:async';

import 'package:semantic_intent_framework_dart/src/command/semantic_reactive_command_transformer.dart';
import 'package:semantic_intent_framework_dart/src/handler/semantic_reactive_command_handler.dart';
import 'package:semantic_intent_framework_dart/src/invoker/registers/command_handlers_register_type.dart';

import '../command/semantic_reactive_command.dart';
import 'registers/command_reactive_stream_registry_type.dart';
import 'registers/command_transformers_registry_type.dart';

class SemanticReactiveCommandInvoker {
  SemanticReactiveCommandInvoker(); // Constructor remains same
  // --- Composed Registries ---
  final _handlersRegistry = CommandHandlersRegistryType();
  final _streamRegistry = ReactiveStreamRegistryType();
  final _transformersRegistry = CommandTransformersRegistryType();

  Stream<T> _getCommandStream<T extends SemanticReactiveCommand>(
    SemanticReactiveCommandStreamName streamName,
  ) {
    final stream = _streamRegistry.getCommandStream<T>(streamName);
    _applyTransformer(streamName, stream);
    return stream;
  }

  void _applyTransformer<T extends SemanticReactiveCommand>(
    SemanticReactiveCommandStreamName streamName,
    Stream<T> stream,
  ) {
    final transformers = _transformersRegistry.getTransformers(streamName);
    if (transformers == null) return;

    Stream<SemanticReactiveCommand> currentStream = stream;
    for (final transformer in transformers) {
      // Apply middleware sequentially
      currentStream = transformer(currentStream);
    }
    // In a more complex scenario, stream transformations consider
    // caching or handled differently.
  }

  // Gets stream from registry and publish
  void push<T extends SemanticReactiveCommand>(
    SemanticReactiveCommandStreamName streamName,
    T command,
  ) {
    _streamRegistry.getCommandStreamController<T>(streamName).add(command);
  }

  void registerHandler<T extends SemanticReactiveCommand>(
    SemanticReactiveCommandHandler<T> handler,
  ) {
    _handlersRegistry.registerHandler<T>(handler);
    // Get stream from StreamRegistry
    final stream = _streamRegistry.getCommandStream<T>(handler.streamName);
    handler.subscribe(stream); // Handler subscribes
  }

  /// Middleware pipeline will be applied when stream is
  /// requested via [_getCommandStream]
  void addTransformer<T extends SemanticReactiveCommand>(
    SemanticReactiveCommandStreamName streamName,
    SemanticReactiveCommandTransformer<T> transformer,
  ) {
    _transformersRegistry.addTransformer<T>(streamName, transformer);
  }

  // --- Dispose ---
  void dispose() {
    _streamRegistry.dispose();
    _transformersRegistry.dispose();
  }
}
