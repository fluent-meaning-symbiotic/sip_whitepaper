import 'package:flutter/material.dart';
import 'package:sointent/ui_kit/atoms/text_styles.dart';
import 'package:sointent/ui_kit/themes/app_theme.dart';
import 'package:sointent/ui_kit/tokens/design_tokens.dart' as tokens;

/// A reusable chip component with consistent styling
class CustomChip extends StatelessWidget {
  /// Creates a new [CustomChip] instance
  const CustomChip({required this.label, this.onDeleted, super.key});

  /// The text to display in the chip
  final String label;

  /// Optional callback when delete is pressed
  final VoidCallback? onDeleted;

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
            blurRadius: tokens.Elevation.defaultMobile,
            offset: const Offset(-0.5, -0.5),
          ),
          // Dark shadow (bottom-right)
          BoxShadow(
            color: neumorphicTheme.darkShadow,
            blurRadius: tokens.Elevation.defaultMobile,
            offset: const Offset(0.5, 0.5),
          ),
        ],
        border: Border.all(
          color: neumorphicTheme.primaryText.withOpacity(
            tokens.EnhancementTokens.borderLuminosityDiff,
          ),
        ),
      ),
      child: Chip(
        label: Text(label, style: context.bodyStyle),
        backgroundColor: Colors.transparent,
        side: BorderSide.none,
        deleteIcon:
            onDeleted != null
                ? Icon(
                  Icons.cancel,
                  size: tokens.ComponentSize.actionIconSize,
                  color: neumorphicTheme.primaryAccent.withOpacity(
                    tokens.StateModifiers.disabledOpacity,
                  ),
                )
                : null,
        onDeleted: onDeleted,
        padding: const EdgeInsets.symmetric(
          horizontal: tokens.Spacing.horizontalElement / 2,
          vertical: tokens.Spacing.micro,
        ),
      ),
    );
  }
}
