import 'package:sointent/common_imports.dart';
import 'package:sointent/data_resources/intent_editor_resource.dart';
import 'package:sointent/ui_intents_view/card_view/ui_intent_card.dart';

class UiIntentCardsView extends StatelessWidget {
  const UiIntentCardsView({super.key});

  void _handleSelect(
    final BuildContext context,
    final SemanticIntentFile intent,
  ) {
    final currentIntentName = SelectedIntentResource.instance.value?.name;
    if (currentIntentName != intent.name) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        IntentEditorResource.instance.updateState(
          currentIntent: intent,
          isDirty: false,
        );
        SelectedIntentResource.instance.value = intent;
      });
    }
  }

  @override
  Widget build(final BuildContext context) {
    final intents = context.watch<FilteredIntentsResource>().orderedValues;
    final selectedIntent = context.watch<SelectedIntentResource>().value;

    return intents.isEmpty
        ? Center(
          child: Text(
            'No intents found',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        )
        : ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: intents.length,
          separatorBuilder:
              (final context, final index) => const SizedBox(height: 2),
          itemBuilder: (final context, final index) {
            final intent = intents[index];
            return UiIntentCard(
              intent: intent,
              isSelected: selectedIntent?.name == intent.name,
              onSelect: () => _handleSelect(context, intent),
            );
          },
        );
  }
}
