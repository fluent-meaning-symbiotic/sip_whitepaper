import '../command/semantic_command.dart';

/// Abstract base class for all Semantic Command Handlers
abstract class SemanticCommandHandler<T extends SemanticCommand> {
  /// Execute method to be implemented by handlers
  Future<void> execute(T command);
}
