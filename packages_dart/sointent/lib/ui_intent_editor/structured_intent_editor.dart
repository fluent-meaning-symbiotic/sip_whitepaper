import 'package:sointent/common_imports.dart';
import 'package:sointent/ui_intent_editor/controllers/structured_intent_controller.dart';
import 'package:sointent/ui_intent_editor/widgets/artifacts_section.dart';
import 'package:sointent/ui_intent_editor/widgets/basic_properties_section.dart';
import 'package:sointent/ui_intent_editor/widgets/llm_section.dart';
import 'package:sointent/ui_intent_editor/widgets/semantic_interactions_section.dart';
import 'package:sointent/ui_intent_editor/widgets/semantic_properties_section.dart';
import 'package:sointent/ui_intent_editor/widgets/testing_section.dart';
import 'package:sointent/ui_kit/atoms/atoms.dart';

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

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary.withOpacity(0.03), Colors.transparent],
        ),
      ),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SectionCard(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: BasicPropertiesSection(controller: controller),
                  ),
                ),
                const SizedBox(height: 16),
                SectionCard(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: SemanticPropertiesSection(controller: controller),
                  ),
                ),
                const SizedBox(height: 16),
                SectionCard(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: SemanticInteractionsSection(controller: controller),
                  ),
                ),
                const SizedBox(height: 16),
                SectionCard(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: TestingSection(controller: controller),
                  ),
                ),
                const SizedBox(height: 16),
                SectionCard(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: ArtifactsSection(controller: controller),
                  ),
                ),
                const SizedBox(height: 16),
                SectionCard(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: LlmSection(controller: controller),
                  ),
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
