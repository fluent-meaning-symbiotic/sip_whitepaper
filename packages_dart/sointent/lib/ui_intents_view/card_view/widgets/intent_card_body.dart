import 'package:sointent/common_imports.dart';
import 'package:sointent/ui_intents_view/card_view/widgets/intent_path_chips.dart';
import 'package:sointent/ui_kit/ui_kit.dart';

class IntentCardBody extends StatelessWidget {
  const IntentCardBody({required this.intent, super.key});

  final SemanticIntentFile intent;

  @override
  Widget build(final BuildContext context) {
    final theme = AppTheme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            intent.meaning.split('\n').first,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.primaryText,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.2,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),
          IntentPathChips(intent: intent),
        ],
      ),
    );
  }
}
