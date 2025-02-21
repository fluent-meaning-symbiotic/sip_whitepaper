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

    return Material(
      color:
          isSelected
              ? theme.primaryAccent.withOpacity(0.05)
              : theme.surfaceBackground,
      child: InkWell(
        onTap: onSelect,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isSelected ? theme.primaryAccent : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IntentCardHeader(intent: intent),
              IntentCardBody(intent: intent),
            ],
          ),
        ),
      ),
    );
  }
}
