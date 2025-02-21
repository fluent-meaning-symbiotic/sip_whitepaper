import 'package:sointent/common_imports.dart';
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
    'Meaning',
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

class _UiIntentEditorState extends State<UiIntentEditor> {
  String? _errorMessage;
  int _selectedTabIndex = 0;

  void _setErrorMessage(final String? message) {
    setState(() {
      _errorMessage = message;
    });
  }

  @override
  Widget build(final BuildContext context) {
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
    final intentFile = editor.currentIntent!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
          child: StructuredIntentEditor(
            key: ValueKey('${intentFile.path}_$_selectedTabIndex'),
            initialValue: intentFile,
            onChanged:
                (final yaml) => UpdateContentCommand(yaml: yaml).execute(),
            onValidationError: _setErrorMessage,
            selectedTabIndex: _selectedTabIndex,
          ),
        ),
      ],
    );
  }
}
