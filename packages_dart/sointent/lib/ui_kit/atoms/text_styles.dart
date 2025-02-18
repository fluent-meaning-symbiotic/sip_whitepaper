import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Extension methods for text styles
extension TextStyleX on TextStyle? {
  /// Creates a section title style
  TextStyle sectionTitle(final ColorScheme colorScheme) =>
      (this ?? GoogleFonts.spaceGrotesk()).copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: colorScheme.onSurface,
      );

  /// Creates a label style
  TextStyle label(final ColorScheme colorScheme) =>
      (this ?? GoogleFonts.spaceGrotesk()).copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: colorScheme.onSurface.withOpacity(0.8),
      );

  /// Creates a body text style
  TextStyle body(final ColorScheme colorScheme) =>
      (this ?? GoogleFonts.spaceGrotesk()).copyWith(
        fontSize: 14,
        height: 1.3,
        letterSpacing: 0.2,
        color: colorScheme.onSurface,
      );

  /// Creates a helper text style
  TextStyle helper(final ColorScheme colorScheme) =>
      (this ?? GoogleFonts.spaceGrotesk()).copyWith(
        fontSize: 13,
        height: 1.4,
        letterSpacing: 0.5,
        color: colorScheme.onSurface.withOpacity(0.6),
      );
}

/// Extension methods for theme text styles
extension ThemeTextStyleX on BuildContext {
  /// Gets the section title style
  TextStyle get sectionTitleStyle =>
      Theme.of(
        this,
      ).textTheme.titleLarge?.sectionTitle(Theme.of(this).colorScheme) ??
      const TextStyle();

  /// Gets the label style
  TextStyle get labelStyle =>
      Theme.of(this).textTheme.labelLarge?.label(Theme.of(this).colorScheme) ??
      const TextStyle();

  /// Gets the body text style
  TextStyle get bodyStyle =>
      Theme.of(this).textTheme.bodyMedium?.body(Theme.of(this).colorScheme) ??
      const TextStyle();

  /// Gets the helper text style
  TextStyle get helperStyle =>
      Theme.of(this).textTheme.bodySmall?.helper(Theme.of(this).colorScheme) ??
      const TextStyle();
}
