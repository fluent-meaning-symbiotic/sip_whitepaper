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

    for (var i = 0; i < mesh.geometry.indices.length; i += 3) {
      final path = Path()
        ..moveTo(screenPoints[mesh.geometry.indices[i]].dx,
            screenPoints[mesh.geometry.indices[i]].dy)
        ..lineTo(screenPoints[mesh.geometry.indices[i + 1]].dx,
            screenPoints[mesh.geometry.indices[i + 1]].dy)
        ..lineTo(screenPoints[mesh.geometry.indices[i + 2]].dx,
            screenPoints[mesh.geometry.indices[i + 2]].dy)
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
