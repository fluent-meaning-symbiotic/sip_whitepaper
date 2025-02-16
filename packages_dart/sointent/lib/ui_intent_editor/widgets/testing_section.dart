import 'package:sointent/common_imports.dart';
import 'package:sointent/ui_intent_editor/controllers/structured_intent_controller.dart';
import 'package:sointent/ui_intent_editor/widgets/list_view.dart';
import 'package:sointent/ui_intent_editor/widgets/map_editor_dialog.dart';
import 'package:sointent/ui_intent_editor/widgets/map_view.dart';

/// Section for editing test categories and validations
class TestingSection extends StatelessWidget {
  /// Creates a new instance of [TestingSection]
  const TestingSection({required this.controller, super.key});

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
                  'Test Categories',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () async {
                  final result = await showDialog<MapEntry<String, dynamic>>(
                    context: context,
                    builder:
                        (final context) =>
                            const MapEditorDialog(title: 'Add Test Category'),
                  );

                  if (result != null) {
                    controller.updateTestCategories({result.key: result.value});
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          MapView(
            items: controller.data.testCategories,
            onRemove: (final key) {
              final newCategories = Map<String, dynamic>.from(
                controller.data.testCategories,
              )..remove(key);
              controller.updateTestCategories(newCategories);
            },
          ),
          const Divider(height: 32),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Semantic Validations',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () async {
                  final result = await showDialog<String>(
                    context: context,
                    builder:
                        (final context) => const MapEditorDialog(
                          title: 'Add Semantic Validation',
                        ),
                  );

                  if (result != null) {
                    controller.updateSemanticValidations([result]);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          ChipListView(
            items: controller.data.semanticValidations,
            onRemove: (final key) {
              final newValidations = List<String>.from(
                controller.data.semanticValidations,
              )..remove(key);
              controller.updateSemanticValidations(newValidations);
            },
          ),
        ],
      ),
    ),
  );
}
