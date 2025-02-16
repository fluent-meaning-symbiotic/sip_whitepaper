import 'package:sointent/common_imports.dart';
import 'package:sointent/ui_intent_controls/ui_intent_controls.dart';

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

    return Scaffold(
      body: Row(
        children: [
          // Left Panel - Intents List
          SizedBox(
            width: leftPanelWidth.value,
            child: Card(
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Intents',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search intents...',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (final value) {
                        // TODO: Implement search
                      },
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child:
                          intents.orderedValues.isEmpty
                              ? const Center(
                                child: Text(
                                  'No intents yet.\nCreate one using the controls.',
                                  textAlign: TextAlign.center,
                                ),
                              )
                              : ListView.builder(
                                itemCount: intents.orderedValues.length,
                                itemBuilder: (final context, final index) {
                                  final intent = intents.orderedValues[index];
                                  return ListTile(
                                    title: Text(intent.name.value),
                                    subtitle: Text(intent.description),
                                    onTap: () {
                                      // TODO: Implement selection
                                    },
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              ),
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
          // Center Panel - Intent Editor
          const Expanded(child: UiIntentEditor()),
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
      ),
    );
  }
}
