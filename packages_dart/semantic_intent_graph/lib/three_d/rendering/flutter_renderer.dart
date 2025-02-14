import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import '../core/mesh.dart';
import '../core/renderer.dart';
import '../core/scene.dart';

class FlutterRenderer extends Renderer3D {
  final Paint _defaultPaint;
  Matrix4 _projectionMatrix = Matrix4.identity();
  late Canvas _canvas;
  late Size _size;

  FlutterRenderer()
      : _defaultPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.blue;

  @override
  void render(Scene3D scene, Canvas canvas, Size size) {
    _canvas = canvas;
    _size = size;
    _updateProjection(size);

    final viewProjection = _projectionMatrix * scene.camera.viewMatrix;

    // Sort meshes by depth for proper rendering
    final meshes = scene.getVisibleMeshes()
      ..sort((a, b) {
        final depthA = viewProjection.transformed3(a.position).z;
        final depthB = viewProjection.transformed3(b.position).z;
        return depthB.compareTo(depthA);
      });

    // Render each mesh
    for (final mesh in meshes) {
      _renderMesh(mesh, viewProjection);
    }
  }

  void _renderMesh(Mesh mesh, Matrix4 viewProjection) {
    final vertices = mesh.getTransformedVertices();
    final screenPoints = vertices.map((v) {
      final projected = viewProjection.transformed3(v);
      return Offset(
        (projected.x / projected.z * _size.width / 2) + _size.width / 2,
        (projected.y / projected.z * _size.height / 2) + _size.height / 2,
      );
    }).toList();

    final paint = mesh.material.createPaint();

    // Draw geometry based on indices
    final indices = mesh.geometry.indices;
    if (indices.isNotEmpty) {
      for (var i = 0; i < indices.length; i += 3) {
        final path = Path()
          ..moveTo(screenPoints[indices[i]].dx, screenPoints[indices[i]].dy)
          ..lineTo(
              screenPoints[indices[i + 1]].dx, screenPoints[indices[i + 1]].dy)
          ..lineTo(
              screenPoints[indices[i + 2]].dx, screenPoints[indices[i + 2]].dy)
          ..close();
        _canvas.drawPath(path, paint);
      }
    } else {
      // Fallback for meshes without indices
      _canvas.drawPoints(
        PointMode.points,
        screenPoints,
        paint..strokeWidth = 5.0,
      );
    }
  }

  void _updateProjection(Size size) {
    const fov = 45.0;
    const near = 0.1;
    const far = 1000.0;
    final aspectRatio = size.width / size.height;

    final fovRad = radians(fov);
    final tanHalfFov = tan(fovRad / 2);

    _projectionMatrix = Matrix4.identity()
      ..setEntry(0, 0, 1 / (aspectRatio * tanHalfFov))
      ..setEntry(1, 1, 1 / tanHalfFov)
      ..setEntry(2, 2, -(far + near) / (far - near))
      ..setEntry(2, 3, -2 * far * near / (far - near))
      ..setEntry(3, 2, -1);
  }

  @override
  void update(double dt) {
    // Update any renderer state if needed
  }

  @override
  void dispose() {
    // Clean up any resources
  }
}
