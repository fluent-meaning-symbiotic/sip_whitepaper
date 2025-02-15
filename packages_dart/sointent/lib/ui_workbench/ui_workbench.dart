import 'package:sointent/common_imports.dart';
import 'package:sointent/data_resources/data_resources.dart';

/// {@template workbench_screen}
/// Main workbench screen of the application.
/// Displays the list of intents and allows editing them.
/// {@endtemplate}
class WorkbenchScreen extends HookWidget {
  /// {@macro workbench_screen}
  const WorkbenchScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    final appState = context.watch<AppStateResource>();
    final intents = context.watch<SemanticIntentsResource>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('SoIntent Workbench'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await context.push(AppRoutes.intentEditor);
            },
          ),
        ],
      ),
      body:
          intents.orderedValues.isEmpty
              ? const Center(
                child: Text(
                  'No intents yet. Create one by clicking the + button.',
                ),
              )
              : ListView.builder(
                itemCount: intents.orderedValues.length,
                itemBuilder: (final context, final index) {
                  final intent = intents.orderedValues[index];
                  return ListTile(
                    title: Text(intent.name.value),
                    subtitle: Text(intent.description),
                    onTap: () async {
                      await context.push(AppRoutes.intentEditor);
                    },
                  );
                },
              ),
    );
  }
}
