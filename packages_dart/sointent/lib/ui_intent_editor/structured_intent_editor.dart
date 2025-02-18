import 'package:sointent/common_imports.dart';
import 'package:sointent/ui_intent_editor/controllers/structured_intent_controller.dart';
import 'package:sointent/ui_intent_editor/widgets/artifacts_section.dart';
import 'package:sointent/ui_intent_editor/widgets/basic_properties_section.dart';
import 'package:sointent/ui_intent_editor/widgets/llm_section.dart';
import 'package:sointent/ui_intent_editor/widgets/semantic_interactions_section.dart';
import 'package:sointent/ui_intent_editor/widgets/semantic_properties_section.dart';
import 'package:sointent/ui_intent_editor/widgets/testing_section.dart';
import 'package:sointent/ui_kit/ui_kit.dart';

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
    this.selectedTabIndex = 0,
    super.key,
  });

  /// The initial intent data
  final SemanticIntentFile initialValue;

  /// Callback when the intent data changes
  final ValueChanged<String> onChanged;

  /// Callback when validation errors occur
  final ValueChanged<String>? onValidationError;

  /// Currently selected tab index
  final int selectedTabIndex;

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
    final neumorphic = AppTheme.of(context);

    Widget buildSection() {
      switch (selectedTabIndex) {
        case 0:
          return BasicPropertiesSection(controller: controller);
        case 1:
          return SemanticPropertiesSection(controller: controller);
        case 2:
          return SemanticInteractionsSection(controller: controller);
        case 3:
          return TestingSection(controller: controller);
        case 4:
          return ArtifactsSection(controller: controller);
        case 5:
          return LlmSection(controller: controller);
        default:
          return const SizedBox.shrink();
      }
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            neumorphic.primaryAccent.withOpacity(0.03),
            Colors.transparent,
          ],
        ),
      ),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverToBoxAdapter(
              child: SectionCard(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: buildSection(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
