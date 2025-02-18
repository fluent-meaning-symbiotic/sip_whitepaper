import 'package:flutter/material.dart';
import 'package:sointent/ui_kit/atoms/text_styles.dart';
import 'package:sointent/ui_kit/tokens/design_tokens.dart' as tokens;

/// A reusable error message component with consistent styling
class ErrorMessage extends StatelessWidget {
  /// Creates a new [ErrorMessage] instance
  const ErrorMessage({required this.message, this.onDismiss, super.key});

  /// The error message to display
  final String message;

  /// Optional callback when dismiss button is pressed
  final VoidCallback? onDismiss;

  @override
  Widget build(final BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: tokens.Spacing.verticalElement,
      ),
      padding: const EdgeInsets.all(tokens.Spacing.verticalElement),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(tokens.ComponentSize.buttonRadius),
        border: Border.all(color: colorScheme.error.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.error.withOpacity(0.05),
            blurRadius: tokens.Elevation.defaultMobile,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: colorScheme.error,
            size: tokens.ComponentSize.actionIconSize,
          ),
          const SizedBox(width: tokens.Spacing.base),
          Expanded(
            child: Text(
              message,
              style: context.bodyStyle.copyWith(color: colorScheme.error),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: onDismiss,
              color: colorScheme.error,
              padding: const EdgeInsets.all(tokens.Spacing.base),
              constraints: const BoxConstraints(
                minWidth: tokens.ComponentSize.buttonHeight,
                minHeight: tokens.ComponentSize.buttonHeight,
              ),
              iconSize: tokens.ComponentSize.actionIconSize,
            ),
        ],
      ),
    );
  }
}
