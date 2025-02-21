import 'package:recase/recase.dart';
import 'package:sointent/common_imports.dart';
import 'package:sointent/ui_intents_view/card_view/widgets/intent_path_chips.dart';
import 'package:sointent/ui_kit/ui_kit.dart';

class IntentCardHeader extends StatelessWidget {
  const IntentCardHeader({required this.intent, super.key});

  final SemanticIntentFile intent;

  @override
  Widget build(final BuildContext context) {
    final theme = AppTheme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: theme.primaryAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                intent.type.name.paramCase,
                style: TextStyle(
                  color: theme.primaryAccent,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              if (intent.name.value.isNotEmpty) ...[
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 1,
                  height: 10,
                  color: theme.primaryAccent.withOpacity(0.2),
                ),
                Text(
                  intent.name.value.replaceFirst('Intent', '').paramCase,
                  style: TextStyle(
                    color: theme.primaryAccent.withOpacity(0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: IntentPathChips(intent: intent)),
        IconButton(
          icon: const Icon(Icons.more_vert, size: 14),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          color: theme.secondaryText.withOpacity(0.5),
          onPressed: () {
            // TODO: Show context menu
          },
        ),
      ],
    );
  }
}
