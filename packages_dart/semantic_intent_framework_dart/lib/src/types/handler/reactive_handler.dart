import 'dart:async';

import 'package:meta/meta.dart';

import '../../commands/reactive/reactive_command.dart';
import '../invoker/reactive_invoker.dart';

abstract class SemanticReactiveCommandHandler<
    T extends SemanticReactiveCommand> {
  SemanticReactiveCommandHandler({required this.invoker});
  final SemanticReactiveCommandInvoker invoker;

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
