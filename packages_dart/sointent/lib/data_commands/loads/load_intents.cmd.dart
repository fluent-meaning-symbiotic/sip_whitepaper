import 'package:sointent/common_imports.dart';
import 'package:sointent/core/commands.dart';

/// Command to load semantic intents for a selected folder
class LoadIntentsCommand extends SemanticCommand {
  /// Creates a new [LoadIntentsCommand]
  const LoadIntentsCommand();

  @override
  Future<void> execute() async {
    // TODO: Implement intent loading logic
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Simulated loading
  }
}
