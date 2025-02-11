import 'dart:async';

import '../../commands/commands.dart';
import '../invoker/invoker.dart';

/// Abstract base class for all Semantic Command Handlers
abstract class SemanticCommandHandler<T extends SemanticCommand> {
  SemanticCommandHandler({required this.invoker});
  final SemanticCommandInvoker invoker;

  /// Execute method to be implemented by handlers
  Future<void> execute(T command);
}
