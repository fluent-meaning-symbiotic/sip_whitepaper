import 'package:flutter/material.dart';
import 'package:sointent/ui_kit/tokens/design_tokens.dart' as tokens;

/// Custom theme extension for neumorphic properties
class NeumorphicTheme extends ThemeExtension<NeumorphicTheme> {
  const NeumorphicTheme({
    required this.baseBackground,
    required this.surfaceBackground,
    required this.lightShadow,
    required this.darkShadow,
    required this.primaryAccent,
    required this.secondaryAccent,
    required this.primaryText,
    required this.secondaryText,
  });
  final Color baseBackground;
  final Color surfaceBackground;
  final Color lightShadow;
  final Color darkShadow;
  final Color primaryAccent;
  final Color secondaryAccent;
  final Color primaryText;
  final Color secondaryText;

  @override
  ThemeExtension<NeumorphicTheme> copyWith({
    final Color? baseBackground,
    final Color? surfaceBackground,
    final Color? lightShadow,
    final Color? darkShadow,
    final Color? primaryAccent,
    final Color? secondaryAccent,
    final Color? primaryText,
    final Color? secondaryText,
  }) => NeumorphicTheme(
    baseBackground: baseBackground ?? this.baseBackground,
    surfaceBackground: surfaceBackground ?? this.surfaceBackground,
    lightShadow: lightShadow ?? this.lightShadow,
    darkShadow: darkShadow ?? this.darkShadow,
    primaryAccent: primaryAccent ?? this.primaryAccent,
    secondaryAccent: secondaryAccent ?? this.secondaryAccent,
    primaryText: primaryText ?? this.primaryText,
    secondaryText: secondaryText ?? this.secondaryText,
  );

  @override
  ThemeExtension<NeumorphicTheme> lerp(
    final ThemeExtension<NeumorphicTheme>? other,
    final double t,
  ) {
    if (other is! NeumorphicTheme) return this;

    return NeumorphicTheme(
      baseBackground: Color.lerp(baseBackground, other.baseBackground, t)!,
      surfaceBackground:
          Color.lerp(surfaceBackground, other.surfaceBackground, t)!,
      lightShadow: Color.lerp(lightShadow, other.lightShadow, t)!,
      darkShadow: Color.lerp(darkShadow, other.darkShadow, t)!,
      primaryAccent: Color.lerp(primaryAccent, other.primaryAccent, t)!,
      secondaryAccent: Color.lerp(secondaryAccent, other.secondaryAccent, t)!,
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
    );
  }
}

/// App theme data provider
class AppTheme {
  static ThemeData get lightTheme {
    const neumorphicTheme = NeumorphicTheme(
      baseBackground: Color(0xFF1E1B2E),
      surfaceBackground: Color(0xFF2A2639),
      lightShadow: Color(0x1A6B63FF),
      darkShadow: Color(0x33000000),
      primaryAccent: Color(0xFF8E7CFF),
      secondaryAccent: Color(0xFF4A90E2),
      primaryText: Color(0xFFE0E0EC),
      secondaryText: Color(0xFFB0B0C0),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: neumorphicTheme.primaryAccent,
        secondary: neumorphicTheme.secondaryAccent,
        surface: neumorphicTheme.surfaceBackground,
        onSecondary: Colors.white,
        onSurface: neumorphicTheme.primaryText,
      ),
      textTheme: TextTheme(
        bodyLarge: tokens.Typography.primary,
        bodyMedium: tokens.Typography.secondary,
        titleMedium: tokens.Typography.header,
      ),
      extensions: const [neumorphicTheme],
    );
  }

  static ThemeData get darkTheme {
    const neumorphicTheme = NeumorphicTheme(
      baseBackground: Color(0xFF0F0B1E),
      surfaceBackground: Color(0xFF1A1628),
      lightShadow: Color(0x0F7B63FF),
      darkShadow: Color(0x4D000000),
      primaryAccent: Color(0xFF9D8FFF),
      secondaryAccent: Color(0xFF5B9FE2),
      primaryText: Color(0xFFF0F0FF),
      secondaryText: Color(0xFFA0A0C0),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: neumorphicTheme.primaryAccent,
        secondary: neumorphicTheme.secondaryAccent,
        surface: neumorphicTheme.surfaceBackground,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: neumorphicTheme.primaryText,
      ),
      textTheme: TextTheme(
        bodyLarge: tokens.Typography.primaryDark,
        bodyMedium: tokens.Typography.secondary,
        titleMedium: tokens.Typography.header,
      ),
      extensions: const [neumorphicTheme],
    );
  }

  /// Helper to get neumorphic theme from current context
  static NeumorphicTheme of(final BuildContext context) =>
      Theme.of(context).extension<NeumorphicTheme>()!;
}
