import 'package:sointent/common_imports.dart';
import 'package:sointent/ui_intent_editor/controllers/structured_intent_controller.dart';
import 'package:sointent/ui_intent_editor/widgets/map_editor_dialog.dart';
import 'package:sointent/ui_intent_editor/widgets/map_view.dart';

/// Section for editing semantic interactions
class SemanticInteractionsSection extends StatelessWidget {
  /// Creates a new instance of [SemanticInteractionsSection]
  const SemanticInteractionsSection({required this.controller, super.key});

  /// The controller managing the intent data
  final StructuredIntentController controller;

  @override
  Widget build(final BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Semantic Interactions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () async {
                  final result = await showDialog<MapEntry<String, dynamic>>(
                    context: context,
                    builder:
                        (final context) => const MapEditorDialog(
                          title: 'Add Semantic Interaction',
                        ),
                  );

                  if (result != null) {
                    controller.updateSemanticInteractions({
                      result.key: result.value,
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          MapView(
            items: controller.data.semanticInteractions,
            onRemove: (final key) {
              final newInteractions = Map<String, dynamic>.from(
                controller.data.semanticInteractions,
              )..remove(key);
              controller.updateSemanticInteractions(newInteractions);
            },
          ),
        ],
      ),
    ),
  );
}
