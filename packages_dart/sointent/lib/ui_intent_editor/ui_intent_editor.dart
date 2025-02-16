import 'package:sointent/common_imports.dart';
import 'package:sointent/data_commands/intent_editor/discard_changes.cmd.dart';
import 'package:sointent/data_commands/intent_editor/save_changes.cmd.dart';
import 'package:sointent/data_commands/intent_editor/set_intent.cmd.dart';
import 'package:sointent/data_commands/intent_editor/update_content.cmd.dart';
import 'package:sointent/data_resources/intent_editor_resource.dart';
import 'package:sointent/ui_intent_editor/structured_intent_editor.dart';

/// {@template ui_intent_editor}
/// Center panel of the workbench that provides editing capabilities
/// for the currently selected intent.
/// {@endtemplate}
class UiIntentEditor extends StatefulWidget {
  /// {@macro ui_intent_editor}
  const UiIntentEditor({super.key});

  @override
  State<UiIntentEditor> createState() => _UiIntentEditorState();
}

class _UiIntentEditorState extends State<UiIntentEditor> {
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final selectedIntent = context.read<SelectedIntentResource>();

    // Keep editor in sync with selected intent
    if (selectedIntent.value != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SetIntentCommand(intent: selectedIntent.value!).execute();
      });
    }
  }

  void _setErrorMessage(final String? message) {
    setState(() {
      _errorMessage = message;
    });
  }

  @override
  Widget build(final BuildContext context) {
    final selectedIntent = context.watch<SelectedIntentResource>();
    final editor = context.watch<IntentEditorResource>();

    if (editor.currentIntent == null) {
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Editing: ${editor.currentIntent!.name}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (editor.isDirty) ...[
                  OutlinedButton.icon(
                    onPressed: () => const DiscardChangesCommand().execute(),
                    icon: const Icon(Icons.undo),
                    label: const Text('Discard'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () async {
                      try {
                        await const SaveChangesCommand().execute();
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Changes saved successfully'),
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        _setErrorMessage('Failed to save changes: $e');
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Save'),
                  ),
                ],
              ],
            ),
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _setErrorMessage(null),
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: StructuredIntentEditor(
                key: ValueKey(editor.currentIntent!.path),
                initialValue: editor.currentIntent!,
                onChanged:
                    (final yaml) => UpdateContentCommand(yaml: yaml).execute(),
                onValidationError: _setErrorMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
