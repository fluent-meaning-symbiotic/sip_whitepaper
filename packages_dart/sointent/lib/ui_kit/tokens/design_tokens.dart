import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Spacing tokens for consistent layout measurements
class Spacing {
  static const double base = 8;
  static const double micro = 4;

  static const EdgeInsets sectionPadding = EdgeInsets.all(24);
  static const EdgeInsets sectionPaddingDark = EdgeInsets.all(20);

  static const double verticalElement = 12;
  static const double horizontalElement = 16;
  static const double nestedIndent = 20;
}

/// Typography tokens for consistent text styles
class Typography {
  Typography._();

  static TextStyle get primary => GoogleFonts.spaceGrotesk(
    fontSize: 14,
    height: 1.3,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2, // Slightly increased for futuristic feel
  );

  static TextStyle get primaryDark => GoogleFonts.spaceGrotesk(
    fontSize: 15,
    height: 1.3,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
  );

  static TextStyle get secondary => GoogleFonts.spaceGrotesk(
    fontSize: 13,
    height: 1.4,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );

  static TextStyle get header => GoogleFonts.spaceGrotesk(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1, // Positive tracking for headers
  );

  static TextStyle get code => GoogleFonts.firaCode(
    fontSize: 13,
    height: 1.2,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );
}

/// Component dimension tokens
class ComponentSize {
  static const double buttonHeight = 32;
  static const double buttonRadius = 10;
  static const double buttonExtrusion = 1.5;

  static const double inputHeight = 36;
  static const double cardRadius = 16;
  static const double cardDepth = 2.5;

  static const double navIconSize = 20;
  static const double actionIconSize = 18;
  static const double iconPadding = 2;
}

/// Animation duration and curve tokens
class AnimationTokens {
  static const Duration microDuration = Duration(milliseconds: 120);
  static const Duration stateDuration = Duration(milliseconds: 180);
  static const Duration complexDuration = Duration(milliseconds: 300);

  static const Curve microCurve = Curves.easeInOut;
  static const Curve stateCurve = Cubic(0.2, 0, 0, 1);
}

/// Depth and elevation tokens
class Elevation {
  static const double defaultDesktop = 1.5;
  static const double defaultMobile = 0.8;
  static const double floatingLight = 4;
  static const double floatingDark = 3;
  static const double borderHighlight = 0.5;
}

/// State modification tokens
class StateModifiers {
  static const double lightModeHoverLightness = 0.08;
  static const double darkModeHoverLightness = 0.06;
  static const double pressedDepthReduction = 2;
  static const double focusRingWidth = 1.5;
  static const double focusRingOpacity = 0.3;
  static const double disabledOpacity = 0.4;
}

/// Enhancement effect tokens
class EnhancementTokens {
  static const double borderGradientWidth = 1;
  static const double borderLuminosityDiff = 0.03;
  static const double lightNoiseOpacity = 0.02;
  static const double darkNoiseOpacity = 0.05;
}

/// Accessibility tokens
class AccessibilityTokens {
  static const double minContrastRatio = 4.6;
  static const double focusIndicatorWidth = 3;
}
