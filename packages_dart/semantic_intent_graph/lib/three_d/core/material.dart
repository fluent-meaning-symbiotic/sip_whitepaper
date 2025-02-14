import 'package:flutter/material.dart';

/// Base class for materials
abstract class Material {
  Paint createPaint();
}

/// Basic material with color and style
class BasicMaterial implements Material {
  final Color color;
  final PaintingStyle style;
  final double strokeWidth;

  const BasicMaterial({
    this.color = Colors.blue,
    this.style = PaintingStyle.fill,
    this.strokeWidth = 1.0,
  });

  @override
  Paint createPaint() => Paint()
    ..color = color
    ..style = style
    ..strokeWidth = strokeWidth;
}
