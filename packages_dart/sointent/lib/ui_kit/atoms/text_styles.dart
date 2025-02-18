import 'package:flutter/material.dart';
import 'package:sointent/ui_kit/themes/app_theme.dart';

/// Extension methods for theme text styles
extension ThemeTextStyleX on BuildContext {
  /// Gets the section title style
  TextStyle get sectionTitleStyle {
    final theme = AppTheme.of(this);
    return Theme.of(
          this,
        ).textTheme.titleLarge?.copyWith(color: theme.primaryText) ??
        Theme.of(this).textTheme.titleLarge!;
  }

  /// Gets the label style
  TextStyle get labelStyle {
    final theme = AppTheme.of(this);
    return Theme.of(
          this,
        ).textTheme.labelLarge?.copyWith(color: theme.primaryText) ??
        Theme.of(this).textTheme.labelLarge!;
  }

  /// Gets the body text style
  TextStyle get bodyStyle {
    final theme = AppTheme.of(this);
    return Theme.of(
          this,
        ).textTheme.bodyMedium?.copyWith(color: theme.primaryText) ??
        Theme.of(this).textTheme.bodyMedium!;
  }

  /// Gets the helper text style
  TextStyle get helperStyle {
    final theme = AppTheme.of(this);
    return Theme.of(
          this,
        ).textTheme.bodySmall?.copyWith(color: theme.secondaryText) ??
        Theme.of(this).textTheme.bodySmall!;
  }
}
