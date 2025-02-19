import 'package:flutter/material.dart';
import 'package:sointent/ui_kit/atoms/text_styles.dart';
import 'package:sointent/ui_kit/themes/app_theme.dart';
import 'package:sointent/ui_kit/tokens/design_tokens.dart' as tokens;

/// {@template input_field}
/// A reusable input field component with consistent styling and neumorphic design.
/// This is the base input field without a label.
/// {@endtemplate}
class InputField extends StatelessWidget {
  /// Creates a new [InputField] instance
  const InputField({
    required this.controller,
    this.onChanged,
    this.helperText,
    this.maxLines,
    super.key,
  });

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
    final neumorphicTheme = AppTheme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: neumorphicTheme.surfaceBackground,
        borderRadius: BorderRadius.circular(tokens.ComponentSize.buttonRadius),
        boxShadow: [
          BoxShadow(
            color: neumorphicTheme.darkShadow,
            blurRadius: tokens.Elevation.defaultDesktop,
            offset: const Offset(1, 1),
            spreadRadius: -1,
          ),
        ],
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
          contentPadding: const EdgeInsets.all(tokens.Spacing.verticalElement),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              tokens.ComponentSize.buttonRadius,
            ),
            borderSide: BorderSide(
              color: neumorphicTheme.primaryText.withOpacity(
                tokens.EnhancementTokens.borderLuminosityDiff,
              ),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              tokens.ComponentSize.buttonRadius,
            ),
            borderSide: BorderSide(
              color: neumorphicTheme.primaryText.withOpacity(
                tokens.EnhancementTokens.borderLuminosityDiff,
              ),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              tokens.ComponentSize.buttonRadius,
            ),
            borderSide: BorderSide(
              color: neumorphicTheme.primaryAccent,
              width: tokens.Elevation.borderHighlight,
            ),
          ),
        ),
      ),
    );
  }
}

/// {@template column_input_field}
/// A reusable input field component with a label in a column layout.
/// Wraps the base [InputField] with a label and consistent spacing.
/// {@endtemplate}
class ColumnInputField extends StatelessWidget {
  /// Creates a new [ColumnInputField] instance
  const ColumnInputField({
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
  Widget build(final BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: context.labelStyle),
      const SizedBox(height: tokens.Spacing.micro * 2),
      InputField(
        controller: controller,
        onChanged: onChanged,
        helperText: helperText,
        maxLines: maxLines,
      ),
    ],
  );
}
