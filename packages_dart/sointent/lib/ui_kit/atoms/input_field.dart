import 'package:flutter/material.dart';
import 'package:sointent/ui_kit/atoms/text_styles.dart';

/// A reusable input field component with consistent styling
class InputField extends StatelessWidget {
  /// Creates a new [InputField] instance
  const InputField({
    required this.label,
    required this.controller,
    this.onChanged,
    this.helperText,
    this.maxLines,
    super.key,
  });

  /// The label text for the field
  final String label;

  /// The text editing controller
  final TextEditingController controller;

  /// Callback when the text changes
  final ValueChanged<String>? onChanged;

  /// Optional helper text
  final String? helperText;

  /// Optional maximum number of lines
  final int? maxLines;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.labelStyle),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                if (colorScheme.brightness == Brightness.light)
                  const Color(0x1A000000)
                else
                  const Color(0x33000000),
                Colors.transparent,
              ],
            ),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            maxLines: maxLines,
            style: context.bodyStyle,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.transparent,
              helperText: helperText,
              helperStyle: context.helperStyle,
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: colorScheme.outline.withOpacity(0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: colorScheme.outline.withOpacity(0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
