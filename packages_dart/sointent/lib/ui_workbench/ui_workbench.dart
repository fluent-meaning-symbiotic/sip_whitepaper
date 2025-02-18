import 'package:sointent/common_imports.dart';
import 'package:sointent/ui_intent_controls/ui_intent_controls.dart';
import 'package:sointent/ui_intents_view/ui_intents_view.dart';

/// {@template workbench_screen}
/// Main workbench screen of the application.
/// Displays a three-panel layout with intents list, editor, and controls.
/// {@endtemplate}
class UiWorkbenchScreen extends HookWidget {
  /// {@macro workbench_screen}
  const UiWorkbenchScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    final intents = context.watch<IntentsResource>();
    final appState = context.watch<AppStateResource>();

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
      appBar: AppBar(
        title: const Text('Workbench'),
        actions: [
          // Left panel toggle
          IconButton(
            icon: Icon(
              isLeftPanelVisible.value
                  ? Icons.chevron_left
                  : Icons.chevron_right,
            ),
            onPressed:
                () => isLeftPanelVisible.value = !isLeftPanelVisible.value,
            tooltip:
                isLeftPanelVisible.value
                    ? 'Hide left panel'
                    : 'Show left panel',
          ),
          // Right panel toggle
          IconButton(
            icon: Icon(
              isRightPanelVisible.value
                  ? Icons.chevron_right
                  : Icons.chevron_left,
            ),
            onPressed:
                () => isRightPanelVisible.value = !isRightPanelVisible.value,
            tooltip:
                isRightPanelVisible.value
                    ? 'Hide right panel'
                    : 'Show right panel',
          ),
        ],
      ),
      body: Row(
        children: [
          // Left Panel - Intents List
          if (isLeftPanelVisible.value) ...[
            SizedBox(width: leftPanelWidth.value, child: const UiIntentsView()),
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
          const Expanded(child: UiIntentEditor()),
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
              child: const UiIntentControls(),
            ),
          ],
        ],
      ),
    );
  }
}
