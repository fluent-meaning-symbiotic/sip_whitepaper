import 'package:flutter/material.dart';
import 'package:sointent/ui_kit/atoms/text_styles.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          // Light shadow (top-left)
          BoxShadow(
            color:
                colorScheme.brightness == Brightness.light
                    ? const Color(0x1A6B63FF)
                    : const Color(0x0F7B63FF),
            blurRadius: 2,
            offset: const Offset(-1, -1),
          ),
          // Dark shadow (bottom-right)
          BoxShadow(
            color:
                colorScheme.brightness == Brightness.light
                    ? const Color(0x33000000)
                    : const Color(0x4D000000),
            blurRadius: 3,
            offset: const Offset(1, 1),
          ),
        ],
        border: Border.all(color: colorScheme.onSurface.withOpacity(0.03)),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          title: Text(
            title,
            style: context.bodyStyle.copyWith(fontWeight: FontWeight.w500),
          ),
          subtitle:
              subtitle != null
                  ? Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      subtitle!,
                      style: context.helperStyle.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                  )
                  : null,
          trailing:
              onDelete != null
                  ? IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: colorScheme.error.withOpacity(0.8),
                      size: 20,
                    ),
                    onPressed: onDelete,
                  )
                  : null,
        ),
      ),
    );
  }
}
