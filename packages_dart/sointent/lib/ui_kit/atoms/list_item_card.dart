import 'package:flutter/material.dart';
import 'package:sointent/ui_kit/themes/app_theme.dart';
import 'package:sointent/ui_kit/tokens/design_tokens.dart' as tokens;

/// A reusable card component for list items with consistent styling
class ListItemCard extends StatelessWidget {
  /// Creates a new [ListItemCard] instance
  const ListItemCard({
    required this.title,
    this.subtitle,
    this.onDelete,
    this.onTap,
    super.key,
  });

  /// The title of the list item
  final String title;

  /// Optional subtitle for the list item
  final String? subtitle;

  /// Optional callback when delete is pressed
  final VoidCallback? onDelete;

  /// Optional callback when card is tapped
  final VoidCallback? onTap;

  @override
  Widget build(final BuildContext context) {
    final neumorphicTheme = AppTheme.of(context);
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(tokens.ComponentSize.cardRadius),
      child: Container(
        margin: const EdgeInsets.only(bottom: tokens.Spacing.verticalElement),
        padding: const EdgeInsets.all(tokens.Spacing.base),
        decoration: BoxDecoration(
          color: neumorphicTheme.surfaceBackground,
          borderRadius: BorderRadius.circular(tokens.ComponentSize.cardRadius),
          boxShadow: [
            BoxShadow(
              color: neumorphicTheme.lightShadow,
              blurRadius: tokens.Elevation.defaultDesktop,
              offset: const Offset(-1, -1),
            ),
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
        child: Row(
          children: [
            Icon(
              Icons.folder,
              size: tokens.ComponentSize.actionIconSize,
              color: neumorphicTheme.primaryAccent,
            ),
            const SizedBox(width: tokens.Spacing.micro * 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: tokens.Spacing.micro),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: neumorphicTheme.secondaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onDelete,
                iconSize: tokens.ComponentSize.actionIconSize,
                color: neumorphicTheme.secondaryText,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: tokens.ComponentSize.actionIconSize,
                  minHeight: tokens.ComponentSize.actionIconSize,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
