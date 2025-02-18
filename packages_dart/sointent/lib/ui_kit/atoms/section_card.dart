import 'package:flutter/material.dart';
import 'package:sointent/ui_kit/themes/app_theme.dart';
import 'package:sointent/ui_kit/tokens/design_tokens.dart' as tokens;

/// A reusable card component for sections with consistent styling
class SectionCard extends StatelessWidget {
  /// Creates a new [SectionCard] instance
  const SectionCard({
    required this.child,
    this.elevation = tokens.Elevation.defaultDesktop,
    super.key,
  });

  /// The content of the card
  final Widget child;

  /// The elevation of the card
  final double elevation;

  @override
  Widget build(final BuildContext context) {
    final neumorphicTheme = AppTheme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: neumorphicTheme.surfaceBackground,
        borderRadius: BorderRadius.circular(tokens.ComponentSize.cardRadius),
        boxShadow: [
          // Light shadow (top-left)
          BoxShadow(
            color: neumorphicTheme.lightShadow,
            blurRadius: elevation,
            offset: const Offset(-1, -1),
          ),
          // Dark shadow (bottom-right)
          BoxShadow(
            color: neumorphicTheme.darkShadow,
            blurRadius: elevation + 1,
            offset: const Offset(1, 1),
          ),
        ],
        border: Border.all(
          color: neumorphicTheme.primaryText.withOpacity(
            tokens.EnhancementTokens.borderLuminosityDiff,
          ),
        ),
      ),
      child: child,
    );
  }
}
