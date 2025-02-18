import 'package:sointent/common_imports.dart';
import 'package:sointent/ui_intent_editor/controllers/structured_intent_controller.dart';
import 'package:sointent/ui_intent_editor/widgets/map_editor_dialog.dart';
import 'package:sointent/ui_kit/atoms/atoms.dart';

/// Section for editing semantic properties
class SemanticPropertiesSection extends StatelessWidget {
  /// Creates a new instance of [SemanticPropertiesSection]
  const SemanticPropertiesSection({required this.controller, super.key});

  /// The controller managing the intent data
  final StructuredIntentController controller;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Semantic Properties',
            action: IconButton(
              icon: Icon(Icons.add_circle_outline, color: colorScheme.primary),
              onPressed: () async {
                final result = await showDialog<MapEntry<String, dynamic>>(
                  context: context,
                  builder:
                      (final context) =>
                          const MapEditorDialog(title: 'Add Semantic Property'),
                );

                if (result != null) {
                  controller.updateSemanticProperties({
                    result.key: result.value,
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          if (controller.data.semanticProperties.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No properties yet. Click + to add.',
                  style: context.bodyStyle.copyWith(
                    fontStyle: FontStyle.italic,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            )
          else
            ...controller.data.semanticProperties.entries.map(
              (final entry) => ListItemCard(
                title: entry.key,
                subtitle: entry.value.toString(),
                onDelete: () {
                  final newProps = Map<String, dynamic>.from(
                    controller.data.semanticProperties,
                  )..remove(entry.key);
                  controller.updateSemanticProperties(newProps);
                },
              ),
            ),
        ],
      ),
    );
  }
}
