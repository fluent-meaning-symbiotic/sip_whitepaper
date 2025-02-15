import 'package:sointent/common_imports.dart';

/// Command to load semantic intents for a selected folder
class LoadIntentsCommand extends SemanticCommand {
  /// Creates a new [LoadIntentsCommand]
  const LoadIntentsCommand({required this.dirPath});
  final String dirPath;
  @override
  Future<void> execute() async {
    final intentsLocalApi = IntentsLocalApi();
    final intents = await intentsLocalApi.getRecursiveIntents(dirPath: dirPath);
    IntentsResource.instance.assignAll(
      intents.toMap(
        toKey: (final intent) => intent.name,
        toValue: (final intent) => intent,
      ),
    );
  }
}
