import 'package:flutter/material.dart';
import 'package:sointent/ui_kit/themes/app_theme.dart';
import 'package:sointent/ui_kit/tokens/design_tokens.dart' as tokens;

/// Extension methods for text styles
extension TextStyleX on TextStyle? {
  /// Creates a section title style
  TextStyle sectionTitle(final BuildContext context) {
    final neumorphicTheme = AppTheme.of(context);
    return tokens.Typography.header.copyWith(
      color: neumorphicTheme.primaryText,
    );
  }

  /// Creates a label style
  TextStyle label(final BuildContext context) {
    final neumorphicTheme = AppTheme.of(context);
    return tokens.Typography.primary.copyWith(
      color: neumorphicTheme.primaryText,
    );
  }

  /// Creates a body text style
  TextStyle body(final BuildContext context) {
    final neumorphicTheme = AppTheme.of(context);
    return tokens.Typography.primary.copyWith(
      color: neumorphicTheme.primaryText,
    );
  }

  /// Creates a helper text style
  TextStyle helper(final BuildContext context) {
    final neumorphicTheme = AppTheme.of(context);
    return tokens.Typography.secondary.copyWith(
      color: neumorphicTheme.secondaryText,
    );
  }
}

/// Extension methods for theme text styles
extension ThemeTextStyleX on BuildContext {
  /// Gets the section title style
  TextStyle get sectionTitleStyle =>
      Theme.of(this).textTheme.titleLarge?.sectionTitle(this) ??
      tokens.Typography.header;

  /// Gets the label style
  TextStyle get labelStyle =>
      Theme.of(this).textTheme.labelLarge?.label(this) ??
      tokens.Typography.primary;

  /// Gets the body text style
  TextStyle get bodyStyle =>
      Theme.of(this).textTheme.bodyMedium?.body(this) ??
      tokens.Typography.primary;

  /// Gets the helper text style
  TextStyle get helperStyle =>
      Theme.of(this).textTheme.bodySmall?.helper(this) ??
      tokens.Typography.secondary;
}
