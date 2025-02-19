import 'package:sointent/common_imports.dart';
import 'package:sointent/data_commands/data_commands.dart';
import 'package:sointent/data_resources/intent_editor_resource.dart';
import 'package:sointent/ui_intent_controls/ui_intent_controls.dart';
import 'package:sointent/ui_intents_view/ui_intents_view.dart';
import 'package:sointent/ui_kit/ui_kit.dart';
import 'package:sointent/ui_workbench/app_bars/center_panel_app_bar.dart';
import 'package:sointent/ui_workbench/app_bars/left_panel_app_bar.dart';
import 'package:sointent/ui_workbench/app_bars/right_panel_app_bar.dart';

/// {@template workbench_screen}
/// Main workbench screen of the application.
/// Displays a three-panel layout with intents list, editor, and controls.
/// {@endtemplate}
class UiWorkbenchScreen extends HookWidget {
  /// {@macro workbench_screen}
  const UiWorkbenchScreen({super.key});

  void _showMessage(
    final BuildContext context,
    final String message, {
    final bool isError = false,
  }) {
    if (!context.mounted) return;
    final colorScheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: context.bodyStyle.copyWith(
            color: isError ? colorScheme.onError : colorScheme.onPrimary,
          ),
        ),
        backgroundColor: isError ? colorScheme.error : colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(final BuildContext context) {
    final editor = context.watch<IntentEditorResource>();

    // Panel width states
    final leftPanelWidth = useState<double>(
      MediaQuery.of(context).size.width * 0.25,
    );
    final rightPanelWidth = useState<double>(
      MediaQuery.of(context).size.width * 0.25,
    );

    // Panel visibility states
    final isLeftPanelVisible = useState(true);
    final isRightPanelVisible = useState(true);

    return Scaffold(
      body: Row(
        children: [
          // Left Panel - Intents List
          if (isLeftPanelVisible.value) ...[
            SizedBox(
              width: leftPanelWidth.value,
              child: Column(
                children: [
                  LeftPanelAppBar(
                    isVisible: isLeftPanelVisible.value,
                    onToggleVisibility:
                        () =>
                            isLeftPanelVisible.value =
                                !isLeftPanelVisible.value,
                  ),
                  const Expanded(child: UiIntentsView()),
                ],
              ),
            ),
            // Left Resizable Divider
            MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              child: GestureDetector(
                onHorizontalDragUpdate: (final details) {
                  leftPanelWidth.value += details.delta.dx;
                },
                child: Container(
                  width: 8,
                  color: Colors.grey.withOpacity(0.1),
                  child: Center(
                    child: Container(
                      width: 1,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
          ],
          // Center Panel - Intent Editor
          Expanded(
            child: Column(
              children: [
                CenterPanelAppBar(
                  title:
                      editor.currentIntent?.name.value ?? 'No Intent Selected',
                  isLeftPanelVisible: isLeftPanelVisible.value,
                  isRightPanelVisible: isRightPanelVisible.value,
                  onShowLeftPanel: () => isLeftPanelVisible.value = true,
                  onShowRightPanel: () => isRightPanelVisible.value = true,
                  onSave:
                      editor.isDirty
                          ? () async {
                            try {
                              await const SaveChangesCommand().execute();
                              if (!context.mounted) return;
                              _showMessage(
                                context,
                                'Changes saved successfully',
                              );
                            } catch (e) {
                              _showMessage(
                                context,
                                'Failed to save changes: $e',
                                isError: true,
                              );
                            }
                          }
                          : null,
                  onUndo:
                      editor.isDirty
                          ? () => const DiscardChangesCommand().execute()
                          : null,
                ),
                const Expanded(child: UiIntentEditor()),
              ],
            ),
          ),
          // Right Panel and Divider
          if (isRightPanelVisible.value) ...[
            // Right Resizable Divider
            MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              child: GestureDetector(
                onHorizontalDragUpdate: (final details) {
                  rightPanelWidth.value -= details.delta.dx;
                },
                child: Container(
                  width: 8,
                  color: Colors.grey.withOpacity(0.1),
                  child: Center(
                    child: Container(
                      width: 1,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
            // Right Panel - Intent Controls
            SizedBox(
              width: rightPanelWidth.value,
              child: Column(
                children: [
                  RightPanelAppBar(
                    isVisible: isRightPanelVisible.value,
                    onToggleVisibility:
                        () =>
                            isRightPanelVisible.value =
                                !isRightPanelVisible.value,
                  ),
                  const Expanded(child: UiIntentControls()),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
