import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'render_pipeline.dart';

/// Blur post-processing effect
class BlurEffect extends PostProcessEffect {
  final double blurRadius;

  BlurEffect({this.blurRadius = 3.0});

  @override
  void apply(ui.Image input, Canvas canvas, Size size) {
    final paint = Paint()
      ..imageFilter = ui.ImageFilter.blur(
        sigmaX: blurRadius,
        sigmaY: blurRadius,
      );
    canvas.drawImage(input, Offset.zero, paint);
  }
}

/// Color correction post-processing effect
class ColorCorrectionEffect extends PostProcessEffect {
  final double brightness;
  final double contrast;
  final double saturation;

  ColorCorrectionEffect({
    this.brightness = 1.0,
    this.contrast = 1.0,
    this.saturation = 1.0,
  });

  @override
  void apply(ui.Image input, Canvas canvas, Size size) {
    final paint = Paint()
      ..colorFilter = ColorFilter.matrix([
        contrast,
        0,
        0,
        0,
        brightness,
        0,
        contrast,
        0,
        0,
        brightness,
        0,
        0,
        contrast,
        0,
        brightness,
        0,
        0,
        0,
        1,
        0,
      ]);
    canvas.drawImage(input, Offset.zero, paint);
  }
}
