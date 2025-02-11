// --- semantic_intent_framework/reactive_semantic_command.dart ---
import 'semantic_command.dart';

/// Use this to use a [SemanticReactiveCommand] unified stream
abstract interface class SemanticReactiveCommandStreamName implements Enum {}

/// Use this to create a command that can be sent on a stream
abstract class SemanticReactiveCommand extends SemanticCommand {
  /// Constructor (can be empty or have common command properties)
  const SemanticReactiveCommand();
}
