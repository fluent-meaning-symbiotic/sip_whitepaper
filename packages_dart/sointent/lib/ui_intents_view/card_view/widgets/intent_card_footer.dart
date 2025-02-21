import 'package:sointent/common_imports.dart';
import 'package:sointent/ui_kit/ui_kit.dart';

class IntentCardFooter extends StatelessWidget {
  const IntentCardFooter({required this.intent, super.key});

  final SemanticIntentFile intent;

  @override
  Widget build(final BuildContext context) {
    final theme = AppTheme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 2, 8, 6),
      child: Row(
        children: [
          Icon(
            Icons.preview_outlined,
            size: 14,
            color: theme.secondaryText.withOpacity(0.7),
          ),
          const SizedBox(width: 4),
          Text(
            'Preview',
            style: TextStyle(
              color: theme.secondaryText.withOpacity(0.7),
              fontSize: 11,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.3,
            ),
          ),
          const Spacer(),
          Text(
            'Last modified: 2h ago', // TODO: Add actual timestamp
            style: TextStyle(
              color: theme.secondaryText.withOpacity(0.7),
              fontSize: 10,
              fontWeight: FontWeight.w300,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
