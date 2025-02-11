import 'dart:async';

import '../command/semantic_command.dart';
import '../invoker/semantic_command_invoker.dart';

/// Abstract base class for all Semantic Command Handlers
abstract class SemanticCommandHandler<T extends SemanticCommand> {
  SemanticCommandHandler({required this.invoker});
  final SemanticCommandInvoker invoker;

  /// Execute method to be implemented by handlers
  Future<void> execute(T command);
}
