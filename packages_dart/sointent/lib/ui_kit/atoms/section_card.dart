import 'package:flutter/material.dart';

/// A reusable card component for sections with consistent styling
class SectionCard extends StatelessWidget {
  /// Creates a new [SectionCard] instance
  const SectionCard({required this.child, this.elevation = 1, super.key});

  /// The content of the card
  final Widget child;

  /// The elevation of the card
  final double elevation;

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
                    ? const Color(0x1A6B63FF) // Light theme purple glow
                    : const Color(0x0F7B63FF), // Dark theme purple glow
            blurRadius: 2,
            offset: const Offset(-1, -1),
          ),
          // Dark shadow (bottom-right)
          BoxShadow(
            color:
                colorScheme.brightness == Brightness.light
                    ? const Color(0x33000000) // Light theme shadow
                    : const Color(0x4D000000), // Dark theme shadow
            blurRadius: 3,
            offset: const Offset(1, 1),
          ),
        ],
        border: Border.all(color: colorScheme.onSurface.withOpacity(0.03)),
      ),
      child: child,
    );
  }
}
