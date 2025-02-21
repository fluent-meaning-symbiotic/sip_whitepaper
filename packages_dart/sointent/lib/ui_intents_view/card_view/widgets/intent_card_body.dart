import 'package:sointent/common_imports.dart';
import 'package:sointent/ui_kit/ui_kit.dart';

class IntentCardBody extends StatelessWidget {
  const IntentCardBody({required this.intent, super.key});

  final SemanticIntentFile intent;

  @override
  Widget build(final BuildContext context) {
    final theme = AppTheme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        intent.meaning,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: theme.primaryText,
          fontSize: 12,
          height: 1.4,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
