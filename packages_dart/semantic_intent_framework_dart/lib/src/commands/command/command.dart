/// Base class for all Semantic Commands
abstract class SemanticCommand {
  /// Constructor (can be empty or have common command properties)
  const SemanticCommand();

  // TODO(arenukvern): add docs and figure out how best way to solve it
  /// Undo the command.
  void undo() => throw UnimplementedError();
}
