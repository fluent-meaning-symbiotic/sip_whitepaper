import 'package:flutter/material.dart';
import 'package:sointent/ui_kit/atoms/text_styles.dart';
import 'package:sointent/ui_kit/themes/app_theme.dart';
import 'package:sointent/ui_kit/tokens/design_tokens.dart' as tokens;

/// A reusable card component for list items with consistent styling
class ListItemCard extends StatelessWidget {
  /// Creates a new [ListItemCard] instance
  const ListItemCard({
    required this.title,
    this.subtitle,
    this.onDelete,
    super.key,
  });

  /// The title of the list item
  final String title;

  /// Optional subtitle for the list item
  final String? subtitle;

  /// Optional callback when delete is pressed
  final VoidCallback? onDelete;

  @override
  Widget build(final BuildContext context) {
    final neumorphicTheme = AppTheme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: tokens.Spacing.verticalElement),
      decoration: BoxDecoration(
        color: neumorphicTheme.surfaceBackground,
        borderRadius: BorderRadius.circular(tokens.ComponentSize.cardRadius),
        boxShadow: [
          // Light shadow (top-left)
          BoxShadow(
            color: neumorphicTheme.lightShadow,
            blurRadius: tokens.Elevation.defaultDesktop,
            offset: const Offset(-1, -1),
          ),
          // Dark shadow (bottom-right)
          BoxShadow(
            color: neumorphicTheme.darkShadow,
            blurRadius: tokens.Elevation.defaultDesktop + 1,
            offset: const Offset(1, 1),
          ),
        ],
        border: Border.all(
          color: neumorphicTheme.primaryText.withOpacity(
            tokens.EnhancementTokens.borderLuminosityDiff,
          ),
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: tokens.Spacing.horizontalElement,
            vertical: tokens.Spacing.verticalElement,
          ),
          title: Text(
            title,
            style: context.bodyStyle.copyWith(fontWeight: FontWeight.w500),
          ),
          subtitle:
              subtitle != null
                  ? Padding(
                    padding: const EdgeInsets.only(top: tokens.Spacing.micro),
                    child: Text(subtitle!, style: context.helperStyle),
                  )
                  : null,
          trailing:
              onDelete != null
                  ? IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: neumorphicTheme.primaryAccent.withOpacity(
                        tokens.StateModifiers.disabledOpacity,
                      ),
                      size: tokens.ComponentSize.actionIconSize,
                    ),
                    onPressed: onDelete,
                  )
                  : null,
        ),
      ),
    );
  }
}
