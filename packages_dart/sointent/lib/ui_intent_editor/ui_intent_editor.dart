import 'package:sointent/common_imports.dart';
import 'package:sointent/ui_intent_editor/yaml_editor.dart';

/// {@template ui_intent_editor}
/// Center panel of the workbench that provides editing capabilities
/// for the currently selected intent.
/// {@endtemplate}
class UiIntentEditor extends HookWidget {
  /// {@macro ui_intent_editor}
  const UiIntentEditor({super.key});

  @override
  Widget build(final BuildContext context) {
    final selectedIntent = context.watch<SelectedIntentResource>();
    final currentIntent = selectedIntent.value;

    if (currentIntent == null) {
      return const Card(
        margin: EdgeInsets.all(8),
        child: Center(child: Text('Select an intent to edit')),
      );
    }

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Editing: ${currentIntent.name}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: YamlEditor(
                key: ValueKey(currentIntent.path),
                initialValue: currentIntent.toYaml(),
                onChanged: (final yaml) {
                  // TODO: Implement save functionality
                },
                onValidationError: (final error) {
                  // TODO: Implement error handling
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
