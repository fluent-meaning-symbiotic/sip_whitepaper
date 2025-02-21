import 'package:sointent/common_imports.dart';
import 'package:sointent/ui_kit/ui_kit.dart';

class IntentPathChips extends StatelessWidget {
  const IntentPathChips({required this.intent, super.key});

  final SemanticIntentFile intent;

  @override
  Widget build(final BuildContext context) {
    final projectPath = context.read<IntentsFolderResource>().value;
    final theme = AppTheme.of(context);
    final segments = intent.getRelativePath(projectPath).split('/')
      ..removeWhere((final s) => s.isEmpty);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < segments.length; i++) ...[
            if (i > 0)
              Text(
                '/',
                style: TextStyle(
                  color: theme.secondaryText.withOpacity(0.5),
                  fontSize: 11,
                  fontWeight: FontWeight.w300,
                ),
              ),
            _PathChip(label: segments[i]),
          ],
        ],
      ),
    );
  }
}

class _PathChip extends StatelessWidget {
  const _PathChip({required this.label});

  final String label;

  @override
  Widget build(final BuildContext context) {
    final theme = AppTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: theme.baseBackground.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: theme.primaryAccent.withOpacity(0.05),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: theme.secondaryText,
          fontSize: 11,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
