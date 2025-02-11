import '../state_accessor/state_accessor.dart';
import 'command.dart';

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
