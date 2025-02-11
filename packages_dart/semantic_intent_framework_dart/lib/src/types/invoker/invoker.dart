import 'dart:async';

import '../../commands/commands.dart';
import '../handler/handler.dart';

class SemanticCommandInvoker {
  /// For MVP simplicity, we can use a basic, implicit handler resolution.
  /// In a real framework, this would likely be replaced by a more robust
  /// handler registry or dependency injection mechanism.
  final Map<Type, SemanticCommandHandler> _handlers = {};

  SemanticCommandInvoker(); // Constructor

  /// Register a handler for a specific command type
  void registerHandler<T extends SemanticCommand>(
      SemanticCommandHandler<T> handler) {
    _handlers[T] = handler;
  }

  /// Invoke a Semantic Command - Dispatches command to its registered handler
  void invoke<T extends SemanticCommand>(T command) {
    final handler =
        _handlers[T] as SemanticCommandHandler<T>?; // Type-safe retrieval

    if (handler == null) {
      throw Exception(
          "No handler registered for command type: ${T.toString()}");
    }

    unawaited(handler.execute(command)); // Execute the handler's logic
  }
}
