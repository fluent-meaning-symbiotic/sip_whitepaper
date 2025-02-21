import 'package:sointent/common_imports.dart';
import 'package:sointent/ui_intents_view/card_view/widgets/intent_card_body.dart';
import 'package:sointent/ui_intents_view/card_view/widgets/intent_card_header.dart';
import 'package:sointent/ui_kit/ui_kit.dart';

class UiIntentCard extends StatelessWidget {
  const UiIntentCard({
    required this.intent,
    this.isSelected = false,
    this.onSelect,
    super.key,
  });

  final SemanticIntentFile intent;
  final bool isSelected;
  final VoidCallback? onSelect;

  @override
  Widget build(final BuildContext context) {
    final theme = AppTheme.of(context);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color:
              isSelected
                  ? theme.primaryAccent.withOpacity(0.3)
                  : theme.primaryAccent.withOpacity(0),
          width: isSelected ? 1 : 0,
        ),
      ),
      color: theme.surfaceBackground,
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IntentCardHeader(intent: intent),
            IntentCardBody(intent: intent),
          ],
        ),
      ),
    );
  }
}
