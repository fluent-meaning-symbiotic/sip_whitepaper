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

/// Material with transparency support
class TransparentMaterial extends BasicMaterial {
  final double opacity;

  const TransparentMaterial({
    super.color = Colors.blue,
    super.style = PaintingStyle.fill,
    super.strokeWidth = 1.0,
    this.opacity = 0.5,
  });

  @override
  Paint createPaint() => super.createPaint()
    ..color = color.withOpacity(opacity)
    ..blendMode = BlendMode.srcOver;
}

/// Add shader support
abstract class ShaderMaterial extends Material {
  String get vertexShader;
  String get fragmentShader;
  Map<String, dynamic> get uniforms;
}
