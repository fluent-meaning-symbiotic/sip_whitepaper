import '../../command/semantic_reactive_command.dart';
import '../../handler/semantic_reactive_command_handler.dart';

class CommandHandlersRegistryType {
  CommandHandlersRegistryType();
  final Map<Type, SemanticReactiveCommandHandler> _handlers = {};

  /// Uses [T] as the key for the handler, so it must be unique
  void registerHandler<T extends SemanticReactiveCommand>(
    SemanticReactiveCommandHandler<T> handler,
  ) {
    _handlers[T] = handler;
  }

  SemanticReactiveCommandHandler<T>?
      getHandlerForCommand<T extends SemanticReactiveCommand>(
    Type commandType,
  ) {
    return _handlers[commandType] as SemanticReactiveCommandHandler<T>?;
  }
}
