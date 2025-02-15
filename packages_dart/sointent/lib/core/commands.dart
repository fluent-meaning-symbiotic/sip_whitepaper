/// Base class for all semantic commands in the application
abstract class SemanticCommand {
  /// Creates a new [SemanticCommand]
  const SemanticCommand();

  /// Executes the command
  Future<void> execute();
}
