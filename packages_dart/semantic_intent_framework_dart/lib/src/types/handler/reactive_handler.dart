import 'dart:async';

import '../../commands/commands.dart';

abstract class SemanticReactiveCommandHandler<
    T extends SemanticReactiveCommand> {
  // Abstract base class for Reactive Semantic Command Handlers

  // Handlers declare the stream they subscribe to
  SemanticReactiveCommandStreamName get streamName;

  StreamSubscription<T> subscribe(Stream<T> commandStream) =>
      commandStream.listen(handleCommand);

  /// Reactive handler processes commands from stream
  Future<void> handleCommand(T command);
}
