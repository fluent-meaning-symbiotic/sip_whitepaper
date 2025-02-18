import 'package:flutter/material.dart';
import 'package:sointent/ui_kit/atoms/text_styles.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
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
            offset: const Offset(-0.5, -0.5),
          ),
          // Dark shadow (bottom-right)
          BoxShadow(
            color:
                colorScheme.brightness == Brightness.light
                    ? const Color(0x33000000)
                    : const Color(0x4D000000),
            blurRadius: 2,
            offset: const Offset(0.5, 0.5),
          ),
        ],
        border: Border.all(color: colorScheme.onSurface.withOpacity(0.03)),
      ),
      child: Chip(
        label: Text(label, style: context.bodyStyle),
        backgroundColor: Colors.transparent,
        side: BorderSide.none,
        deleteIcon:
            onDeleted != null
                ? Icon(
                  Icons.cancel,
                  size: 18,
                  color: colorScheme.error.withOpacity(0.8),
                )
                : null,
        onDeleted: onDeleted,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }
}
