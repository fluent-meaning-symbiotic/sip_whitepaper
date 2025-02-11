import 'dart:async';

import '../../commands/commands.dart';

class ReactiveStreamRegistryType {
  ReactiveStreamRegistryType();

  final _commandStreams = <SemanticReactiveCommandStreamName,
      Map<Type, StreamController<dynamic>>>{};

  StreamController<T>
      getCommandStreamController<T extends SemanticReactiveCommand>(
    SemanticReactiveCommandStreamName streamName,
  ) {
    _commandStreams[streamName] ??= {};

    final typeStreams = _commandStreams[streamName]!;
    if (!typeStreams.containsKey(T)) {
      typeStreams[T] = StreamController<T>.broadcast();
    }

    return typeStreams[T]! as StreamController<T>;
  }

  Stream<T> getCommandStream<T extends SemanticReactiveCommand>(
    SemanticReactiveCommandStreamName streamName,
  ) =>
      getCommandStreamController<T>(streamName).stream;

  void push<T extends SemanticReactiveCommand>(
    SemanticReactiveCommandStreamName streamName,
    T command,
  ) {
    if (_commandStreams.containsKey(streamName) &&
        _commandStreams[streamName]!.containsKey(T)) {
      final controller =
          _commandStreams[streamName]![T]! as StreamController<T>;
      controller.add(command);
    }
  }

  void disposeStream(SemanticReactiveCommandStreamName streamName) {
    if (_commandStreams.containsKey(streamName)) {
      for (final controller in _commandStreams[streamName]!.values) {
        controller.close();
      }
      _commandStreams.remove(streamName);
    }
  }

  void dispose() {
    for (final typeStreams in _commandStreams.values) {
      for (final controller in typeStreams.values) {
        controller.close();
      }
    }
    _commandStreams.clear();
  }
}
