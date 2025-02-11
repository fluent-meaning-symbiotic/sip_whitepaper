import '../../commands/commands.dart';
import '../handler/reactive_command_handler.dart';

class CommandHandlersRegistryType {
  CommandHandlersRegistryType();
  final Map<Type, SemanticReactiveCommandHandler> _handlers = {};
  final Map<SemanticReactiveCommandStreamName, Set<Type>>
      _handlersByStreamName = {};

  /// Uses [T] as the key for the handler, so it must be unique
  void registerHandler<T extends SemanticReactiveCommand>(
    SemanticReactiveCommandHandler<T> handler,
  ) {
    _handlers[T] = handler;
    _handlersByStreamName.update(
      handler.streamName,
      (value) => value..add(T),
      ifAbsent: () => {T},
    );
  }

  SemanticReactiveCommandHandler<T>?
      getHandlerForCommand<T extends SemanticReactiveCommand>(
    Type commandType,
  ) {
    return _handlers[commandType] as SemanticReactiveCommandHandler<T>?;
  }

  Set<SemanticReactiveCommandHandler> getHandlersForStream(
    SemanticReactiveCommandStreamName streamName,
  ) {
    final handlers = _handlersByStreamName[streamName]
        ?.map((type) => _handlers[type])
        .nonNulls
        .toSet();
    return handlers ?? {};
  }

  void dispose() {
    for (final handler in _handlers.values) {
      handler.unsubscribe();
    }
    _handlers.clear();
    _handlersByStreamName.clear();
  }
}
