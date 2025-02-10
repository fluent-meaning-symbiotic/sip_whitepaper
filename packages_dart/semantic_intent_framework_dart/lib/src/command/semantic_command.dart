import '../../semantic_intent_framework_dart.dart';

/// Base class for all Semantic Commands
abstract class SemanticCommand {
  /// Constructor (can be empty or have common command properties)
  const SemanticCommand();
}

/// Base class for all Semantic Commands that access and modify state
abstract class SemanticSingleStateAccessorCommand<T extends Object>
    extends SemanticCommand {
  /// Constructor (can be empty or have common command properties)
  const SemanticSingleStateAccessorCommand({
    required this.stateAccessor,
  });

  /// Get the state accessor for the command
  final SemanticCommandStateAccessor<T> stateAccessor;
}
