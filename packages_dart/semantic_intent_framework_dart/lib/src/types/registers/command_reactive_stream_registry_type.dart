import 'dart:async';

import '../../commands/commands.dart';

class ReactiveStreamRegistryType {
  ReactiveStreamRegistryType();
  final _commandStreams = <SemanticReactiveCommandStreamName,
      StreamController<SemanticReactiveCommand>>{};

  StreamController<T>
      getCommandStreamController<T extends SemanticReactiveCommand>(
    SemanticReactiveCommandStreamName streamIntentName,
  ) {
    if (!_commandStreams.containsKey(streamIntentName)) {
      _commandStreams[streamIntentName] =
          StreamController<SemanticReactiveCommand>.broadcast();
    }
    return _commandStreams[streamIntentName]! as StreamController<T>;
  }

  Stream<T> getCommandStream<T extends SemanticReactiveCommand>(
    SemanticReactiveCommandStreamName streamIntentName,
  ) =>
      getCommandStreamController<T>(streamIntentName).stream.cast<T>();

  void disposeStream(SemanticReactiveCommandStreamName streamIntentName) {
    if (_commandStreams.containsKey(streamIntentName)) {
      _commandStreams[streamIntentName]!.close();
      _commandStreams.remove(streamIntentName);
    }
  }

  void dispose() {
    for (final controller in _commandStreams.values) {
      controller.close();
    }
    _commandStreams.clear();
  }
}
