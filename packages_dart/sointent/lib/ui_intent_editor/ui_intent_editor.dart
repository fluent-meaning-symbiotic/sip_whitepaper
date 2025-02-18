import 'package:sointent/common_imports.dart';
import 'package:sointent/data_commands/intent_editor/discard_changes.cmd.dart';
import 'package:sointent/data_commands/intent_editor/save_changes.cmd.dart';
import 'package:sointent/data_commands/intent_editor/set_intent.cmd.dart';
import 'package:sointent/data_commands/intent_editor/update_content.cmd.dart';
import 'package:sointent/data_resources/intent_editor_resource.dart';
import 'package:sointent/ui_intent_editor/structured_intent_editor.dart';
import 'package:sointent/ui_kit/atoms/atoms.dart';

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
  SemanticIntentName? _currentIntentName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final selectedIntent = context.read<SelectedIntentResource>();

    // Keep editor in sync with selected intent
    if (selectedIntent.value != null &&
        _currentIntentName != selectedIntent.value!.name) {
      _currentIntentName = selectedIntent.value!.name;
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (editor.currentIntent == null) {
      return SectionCard(
        child: Center(
          child: Text(
            'Select an intent to edit',
            style: context.bodyStyle.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Intent ${editor.currentIntent!.name} Editor',
                  style: context.sectionTitleStyle,
                ),
              ),
              if (editor.isDirty) ...[
                OutlinedButton.icon(
                  onPressed: () => const DiscardChangesCommand().execute(),
                  icon: const Icon(Icons.undo, size: 18),
                  label: const Text('Discard'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide(
                      color: colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: () async {
                    try {
                      await const SaveChangesCommand().execute();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Changes saved successfully',
                            style: context.bodyStyle.copyWith(
                              color: colorScheme.onPrimary,
                            ),
                          ),
                          backgroundColor: colorScheme.primary,
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      _setErrorMessage('Failed to save changes: $e');
                    }
                  },
                  icon: const Icon(Icons.save, size: 18),
                  label: const Text('Save'),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (_errorMessage != null)
          Container(
            margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colorScheme.error.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.error.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: colorScheme.error, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: context.bodyStyle.copyWith(color: colorScheme.error),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => _setErrorMessage(null),
                  color: colorScheme.error,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ),
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
    );
  }
}
