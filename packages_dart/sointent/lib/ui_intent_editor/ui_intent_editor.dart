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
class UiIntentEditorTabs extends StatelessWidget {
  const UiIntentEditorTabs({
    required this.selectedIndex,
    required this.onTabSelected,
    super.key,
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
      decoration: BoxDecoration(
        color: neumorphic.surfaceBackground,
        border: Border(
          bottom: BorderSide(color: neumorphic.primaryAccent.withOpacity(0.1)),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.sectionPadding.left,
          vertical: Spacing.micro,
        ),
        child: Row(
          children: [
            for (var i = 0; i < _tabs.length; i++)
              Padding(
                padding: const EdgeInsets.only(
                  right: Spacing.horizontalElement,
                ),
                child: _TabButton(
                  label: _tabs[i],
                  isSelected: i == selectedIndex,
                  onTap: () => onTabSelected(i),
                ),
              ),
          ],
        ),
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
  Widget build(final BuildContext context) => NeumorphicButton(
    label: label,
    onPressed: onTap,
    isSelected: isSelected,
    variant: ButtonVariant.secondary,
    size: ButtonSize.small,
  );
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
            NeumorphicButton(
              label: 'Discard',
              onPressed: onDiscard,
              icon: Icons.undo,
              variant: ButtonVariant.secondary,
            ),
            const SizedBox(width: Spacing.horizontalElement),
            NeumorphicButton(
              label: 'Save',
              onPressed: onSave,
              icon: Icons.save,
            ),
          ],
        ],
      ),
    );
  }
}

/// Content section of the intent editor that changes based on selected tab
class _IntentEditorContent extends StatelessWidget {
  const _IntentEditorContent({
    required this.selectedTabIndex,
    required this.intentFile,
    required this.onChanged,
    required this.onValidationError,
  });

  final int selectedTabIndex;
  final SemanticIntentFile intentFile;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onValidationError;

  @override
  Widget build(final BuildContext context) => StructuredIntentEditor(
    key: ValueKey('${intentFile.path}_$selectedTabIndex'),
    initialValue: intentFile,
    onChanged: onChanged,
    onValidationError: onValidationError,
    selectedTabIndex: selectedTabIndex,
  );
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
        UiIntentEditorTabs(
          selectedIndex: _selectedTabIndex,
          onTabSelected:
              (final index) => setState(() => _selectedTabIndex = index),
        ),
        if (_errorMessage != null)
          ErrorMessage(
            message: _errorMessage!,
            onDismiss: () => _setErrorMessage(null),
          ),
        Expanded(
          child: _IntentEditorContent(
            selectedTabIndex: _selectedTabIndex,
            intentFile: editor.currentIntent!,
            onChanged:
                (final yaml) => UpdateContentCommand(yaml: yaml).execute(),
            onValidationError: _setErrorMessage,
          ),
        ),
      ],
    );
  }
}
