import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import '../core/mesh.dart';

/// Shared rendering utilities
class RenderUtils {
  /// Project vertices to screen space
  static List<Offset> projectVertices(
      List<Vector3> vertices, Matrix4 viewProjection, Size size) {
    return vertices.map((v) {
      final projected = viewProjection.transformed3(v);
      return Offset(
        (projected.x / projected.z * size.width / 2) + size.width / 2,
        (projected.y / projected.z * size.height / 2) + size.height / 2,
      );
    }).toList();
  }

  /// Render mesh geometry
  static void renderMeshGeometry(
    Mesh mesh,
    List<Offset> screenPoints,
    Paint paint,
    Canvas canvas, {
    bool wireframe = false,
  }) {
    if (mesh.geometry.indices.isEmpty) {
      renderPoints(screenPoints, paint, canvas);
      return;
    }

    // Check if this is a line geometry (2 indices per primitive)
    final isLineGeometry = mesh.geometry.indices.length % 2 == 0;

    if (isLineGeometry) {
      _renderLines(mesh.geometry.indices, screenPoints, paint, canvas);
    } else {
      _renderTriangles(
          mesh.geometry.indices, screenPoints, paint, canvas, wireframe);
    }
  }

  static void _renderLines(
    List<int> indices,
    List<Offset> screenPoints,
    Paint paint,
    Canvas canvas,
  ) {
    for (var i = 0; i < indices.length; i += 2) {
      canvas.drawLine(
        screenPoints[indices[i]],
        screenPoints[indices[i + 1]],
        paint,
      );
    }
  }

  static void _renderTriangles(
    List<int> indices,
    List<Offset> screenPoints,
    Paint paint,
    Canvas canvas,
    bool wireframe,
  ) {
    for (var i = 0; i < indices.length; i += 3) {
      final path = Path()
        ..moveTo(screenPoints[indices[i]].dx, screenPoints[indices[i]].dy)
        ..lineTo(
            screenPoints[indices[i + 1]].dx, screenPoints[indices[i + 1]].dy)
        ..lineTo(
            screenPoints[indices[i + 2]].dx, screenPoints[indices[i + 2]].dy)
        ..close();

      if (wireframe) {
        canvas.drawPath(path, paint..style = PaintingStyle.stroke);
      } else {
        canvas.drawPath(path, paint);
      }
    }
  }

  /// Render points
  static void renderPoints(
    List<Offset> screenPoints,
    Paint paint,
    Canvas canvas, {
    double pointSize = 5.0,
  }) {
    canvas.drawPoints(
      PointMode.points,
      screenPoints,
      paint..strokeWidth = pointSize,
    );
  }
}
