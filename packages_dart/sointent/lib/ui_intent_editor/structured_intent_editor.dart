import 'package:sointent/common_imports.dart';
import 'package:sointent/ui_intent_editor/controllers/structured_intent_controller.dart';
import 'package:sointent/ui_intent_editor/widgets/artifacts_section.dart';
import 'package:sointent/ui_intent_editor/widgets/basic_properties_section.dart';
import 'package:sointent/ui_intent_editor/widgets/llm_section.dart';
import 'package:sointent/ui_intent_editor/widgets/semantic_interactions_section.dart';
import 'package:sointent/ui_intent_editor/widgets/semantic_properties_section.dart';
import 'package:sointent/ui_intent_editor/widgets/testing_section.dart';

/// {@template structured_intent_editor}
/// A structured editor for semantic intents that provides a form-based interface
/// following the Semantic Intent Paradigm (SIP) principles.
/// {@endtemplate}
class StructuredIntentEditor extends HookWidget {
  /// {@macro structured_intent_editor}
  const StructuredIntentEditor({
    required this.initialValue,
    required this.onChanged,
    this.onValidationError,
    super.key,
  });

  /// The initial intent data
  final SemanticIntentFile initialValue;

  /// Callback when the intent data changes
  final ValueChanged<String> onChanged;

  /// Callback when validation errors occur
  final ValueChanged<String>? onValidationError;

  @override
  Widget build(final BuildContext context) {
    final controller = useMemoized(
      () => StructuredIntentController(
        data: initialValue,
        onChanged: onChanged,
        onValidationError: onValidationError,
      ),
      [initialValue],
    );

    useEffect(() => controller.dispose, [controller]);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BasicPropertiesSection(controller: controller),
                const SizedBox(height: 16),
                SemanticPropertiesSection(controller: controller),
                const SizedBox(height: 16),
                SemanticInteractionsSection(controller: controller),
                const SizedBox(height: 16),
                TestingSection(controller: controller),
                const SizedBox(height: 16),
                ArtifactsSection(controller: controller),
                const SizedBox(height: 16),
                LlmSection(controller: controller),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
