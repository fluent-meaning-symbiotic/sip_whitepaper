import 'package:sointent/common_imports.dart';
import 'package:sointent/data_commands/intent_editor/discard_changes.cmd.dart';
import 'package:sointent/data_commands/intent_editor/save_changes.cmd.dart';
import 'package:sointent/data_commands/intent_editor/set_intent.cmd.dart';
import 'package:sointent/data_commands/intent_editor/update_content.cmd.dart';
import 'package:sointent/data_resources/intent_editor_resource.dart';
import 'package:sointent/ui_intent_editor/structured_intent_editor.dart';
import 'package:sointent/ui_kit/atoms/atoms.dart';
import 'package:sointent/ui_kit/themes/app_theme.dart';
import 'package:sointent/ui_kit/tokens/design_tokens.dart';

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

/// Navigation tabs for the intent editor sections
class _IntentEditorTabs extends StatelessWidget {
  const _IntentEditorTabs({
    required this.selectedIndex,
    required this.onTabSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  static const _tabs = [
    'General',
    'Properties',
    'Interactions',
    'Testing',
    'Artifacts',
    'Prompts',
  ];

  @override
  Widget build(final BuildContext context) {
    final neumorphic = AppTheme.of(context);

    return Container(
      height: 48,
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.sectionPadding.left,
        vertical: Spacing.micro,
      ),
      decoration: BoxDecoration(
        color: neumorphic.surfaceBackground,
        border: Border(
          bottom: BorderSide(color: neumorphic.primaryAccent.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          for (var i = 0; i < _tabs.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: Spacing.horizontalElement),
              child: _TabButton(
                label: _tabs[i],
                isSelected: i == selectedIndex,
                onTap: () => onTabSelected(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) {
    final neumorphic = AppTheme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ComponentSize.buttonRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color:
                isSelected
                    ? neumorphic.primaryAccent.withOpacity(0.1)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(ComponentSize.buttonRadius),
            border: Border.all(
              color:
                  isSelected
                      ? neumorphic.primaryAccent.withOpacity(0.2)
                      : Colors.transparent,
            ),
          ),
          child: Text(
            label,
            style: context.labelStyle.copyWith(
              color:
                  isSelected
                      ? neumorphic.primaryAccent
                      : neumorphic.secondaryText,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

/// Header section of the intent editor with title and actions
class _IntentEditorHeader extends StatelessWidget {
  const _IntentEditorHeader({
    required this.intentName,
    required this.isDirty,
    required this.onSave,
    required this.onDiscard,
  });

  final String intentName;
  final bool isDirty;
  final VoidCallback onSave;
  final VoidCallback onDiscard;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final neumorphic = AppTheme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.sectionPadding.horizontal,
        vertical: Spacing.base,
      ),
      decoration: BoxDecoration(
        color: neumorphic.surfaceBackground,
        border: Border(
          bottom: BorderSide(color: neumorphic.primaryAccent.withOpacity(0.1)),
        ),
        boxShadow: [
          BoxShadow(
            color: neumorphic.darkShadow.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              intentName,
              style: context.sectionTitleStyle.copyWith(
                color: neumorphic.primaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (isDirty) ...[
            OutlinedButton.icon(
              onPressed: onDiscard,
              icon: const Icon(Icons.undo, size: ComponentSize.actionIconSize),
              label: const Text('Discard'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.horizontalElement,
                  vertical: Spacing.base,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ComponentSize.buttonRadius,
                  ),
                ),
                side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
              ),
            ),
            const SizedBox(width: Spacing.horizontalElement),
            FilledButton.icon(
              onPressed: onSave,
              icon: const Icon(Icons.save, size: ComponentSize.actionIconSize),
              label: const Text('Save'),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.horizontalElement,
                  vertical: Spacing.base,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ComponentSize.buttonRadius,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _UiIntentEditorState extends State<UiIntentEditor> {
  String? _errorMessage;
  SemanticIntentName? _currentIntentName;
  int _selectedTabIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final selectedIntent = context.read<SelectedIntentResource>();

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
        _IntentEditorHeader(
          intentName: 'Intent ${editor.currentIntent!.name} Editor',
          isDirty: editor.isDirty,
          onSave: () async {
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
          onDiscard: () => const DiscardChangesCommand().execute(),
        ),
        _IntentEditorTabs(
          selectedIndex: _selectedTabIndex,
          onTabSelected:
              (final index) => setState(() => _selectedTabIndex = index),
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
