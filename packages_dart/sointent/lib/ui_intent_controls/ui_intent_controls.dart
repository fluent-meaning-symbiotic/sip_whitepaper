import 'package:sointent/common_imports.dart';

/// {@template ui_intent_controls}
/// Right panel of the workbench that displays controls and actions
/// for the currently selected intent.
/// {@endtemplate}
class UiIntentControls extends HookWidget {
  /// {@macro ui_intent_controls}
  const UiIntentControls({super.key});

  @override
  Widget build(final BuildContext context) {
    final intents = context.watch<IntentsResource>();

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Intent Controls',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement create intent
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Intent'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement save intent
              },
              icon: const Icon(Icons.save),
              label: const Text('Save Intent'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                // TODO: Implement delete intent
              },
              icon: const Icon(Icons.delete),
              label: const Text('Delete Intent'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
