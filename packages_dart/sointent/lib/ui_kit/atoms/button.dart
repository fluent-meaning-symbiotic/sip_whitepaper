import 'package:flutter/material.dart';
import 'package:sointent/ui_kit/atoms/text_styles.dart';
import 'package:sointent/ui_kit/themes/app_theme.dart';
import 'package:sointent/ui_kit/tokens/design_tokens.dart' as tokens;

/// A reusable button component with consistent neumorphic styling
class NeumorphicButton extends StatelessWidget {
  /// Creates a new [NeumorphicButton] instance
  const NeumorphicButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isSelected = false,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    super.key,
  });

  /// The text to display in the button
  final String label;

  /// Callback when the button is pressed
  final VoidCallback? onPressed;

  /// Optional icon to display before the label
  final IconData? icon;

  /// Whether the button is in a selected state
  final bool isSelected;

  /// The visual variant of the button
  final ButtonVariant variant;

  /// The size variant of the button
  final ButtonSize size;

  @override
  Widget build(final BuildContext context) {
    final neumorphicTheme = AppTheme.of(context);
    final isEnabled = onPressed != null;

    final backgroundColor = () {
      if (!isEnabled) return neumorphicTheme.surfaceBackground.withOpacity(0.5);
      if (isSelected) {
        return variant == ButtonVariant.primary
            ? neumorphicTheme.primaryAccent.withOpacity(0.1)
            : neumorphicTheme.surfaceBackground;
      }
      return variant == ButtonVariant.primary
          ? neumorphicTheme.primaryAccent
          : neumorphicTheme.surfaceBackground;
    }();

    final textColor = () {
      if (!isEnabled) return neumorphicTheme.secondaryText.withOpacity(0.5);
      if (isSelected) {
        return variant == ButtonVariant.primary
            ? neumorphicTheme.primaryAccent
            : neumorphicTheme.primaryText;
      }
      return variant == ButtonVariant.primary
          ? Colors.white
          : neumorphicTheme.primaryText;
    }();

    final height = () {
      switch (size) {
        case ButtonSize.small:
          return tokens.ComponentSize.buttonHeight - 8;
        case ButtonSize.medium:
          return tokens.ComponentSize.buttonHeight;
        case ButtonSize.large:
          return tokens.ComponentSize.buttonHeight + 8;
      }
    }();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(tokens.ComponentSize.buttonRadius),
        child: AnimatedContainer(
          duration: tokens.AnimationTokens.microDuration,
          curve: tokens.AnimationTokens.microCurve,
          height: height,
          padding: EdgeInsets.symmetric(
            horizontal: size == ButtonSize.small ? 12.0 : 16.0,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(
              tokens.ComponentSize.buttonRadius,
            ),
            border: Border.all(
              color:
                  isSelected
                      ? neumorphicTheme.primaryAccent.withOpacity(0.2)
                      : neumorphicTheme.primaryText.withOpacity(
                        tokens.EnhancementTokens.borderLuminosityDiff,
                      ),
            ),
            boxShadow:
                isEnabled
                    ? [
                      BoxShadow(
                        color: neumorphicTheme.lightShadow,
                        blurRadius: tokens.Elevation.defaultDesktop,
                        offset: const Offset(-0.5, -0.5),
                      ),
                      BoxShadow(
                        color: neumorphicTheme.darkShadow,
                        blurRadius: tokens.Elevation.defaultDesktop,
                        offset: const Offset(0.5, 0.5),
                      ),
                    ]
                    : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: tokens.ComponentSize.actionIconSize,
                  color: textColor,
                ),
                SizedBox(width: size == ButtonSize.small ? 4.0 : 8.0),
              ],
              Text(
                label,
                style: context.labelStyle.copyWith(
                  color: textColor,
                  fontSize: size == ButtonSize.small ? 13 : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The visual variants of the button
enum ButtonVariant {
  /// Primary action button with accent color background
  primary,

  /// Secondary action button with surface background
  secondary,
}

/// The size variants of the button
enum ButtonSize {
  /// Small compact button
  small,

  /// Standard size button
  medium,

  /// Large prominent button
  large,
}
