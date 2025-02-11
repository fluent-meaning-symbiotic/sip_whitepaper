import 'dart:async';

import 'package:meta/meta.dart';

import '../../commands/commands.dart';

abstract class SemanticReactiveCommandHandler<
    T extends SemanticReactiveCommand> {
  // Abstract base class for Reactive Semantic Command Handlers

  // Handlers declare the stream they subscribe to
  SemanticReactiveCommandStreamName get streamName;

  StreamSubscription<T>? _subscription;

  /// subscribes to command stream
  @internal
  void subscribe(Stream<T> stream) {
    unsubscribe();
    _subscription = stream.listen(handleCommand);
  }

  /// unsubscribes from command stream
  @internal
  void unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// Reactive handler processes commands from stream
  @internal
  Future<void> handleCommand(T command);
}
