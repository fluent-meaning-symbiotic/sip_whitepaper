import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import '../../graph/materials/graph_materials.dart';
import '../core/material.dart';
import '../core/scene.dart';
import 'render_pipeline.dart';
import 'render_target.dart';
import 'render_utils.dart';

/// Create a mixin to share common rendering logic
mixin ProjectionUtils {
  List<Offset> projectVertices(
      List<Vector3> vertices, Matrix4 viewProjection, Size size) {
    return vertices.map((v) {
      final projected = viewProjection.transformed3(v);
      return Offset(
        (projected.x / projected.z * size.width / 2) + size.width / 2,
        (projected.y / projected.z * size.height / 2) + size.height / 2,
      );
    }).toList();
  }
}

/// Base class for render passes
abstract class Pass {
  final RenderPassType type;
  bool enabled = true;

  Pass(this.type);

  void render(Canvas canvas, Size size, Scene3D scene);
}

/// Standard geometry render pass
class GeometryPass extends Pass {
  final Matrix4 projectionMatrix;

  GeometryPass(super.type, {required this.projectionMatrix});

  @override
  void render(Canvas canvas, Size size, Scene3D scene) {
    if (size.width <= 0 || size.height <= 0) {
      print('Warning: Invalid size for rendering: $size');
      return;
    }

    // Create view-projection matrix
    final viewProjectionMatrix = projectionMatrix.clone()
      ..multiply(scene.camera.viewMatrix);

    for (final mesh in scene.getVisibleMeshes()) {
      final geometry = mesh.geometry;
      final material = mesh.material;
      final vertices = mesh.getTransformedVertices();
      final indices = geometry.indices;

      // Debug info
      print(
          'Rendering mesh: vertices=${vertices.length}, indices=${indices.length}');

      // Convert 3D points to screen space using view-projection matrix
      final screenPoints = vertices.map((v) {
        final projected = viewProjectionMatrix.transformed3(v);
        if (projected.z.abs() < 0.001) return Offset.zero;

        // Perform perspective division
        final w = projected.z;
        return Offset(
          (projected.x / w + 1) * size.width / 2,
          (projected.y / w + 1) * size.height / 2,
        );
      }).toList();

      final paint = material.createPaint();

      // Check if this is an edge (line) or a face (triangle)
      if (material is EdgeMaterial) {
        // Draw lines
        for (var i = 0; i < indices.length; i += 2) {
          if (i + 1 >= indices.length) {
            print('Warning: Invalid line indices at $i');
            continue;
          }

          final idx1 = indices[i];
          final idx2 = indices[i + 1];

          if (idx1 >= screenPoints.length || idx2 >= screenPoints.length) {
            print(
                'Warning: Index out of bounds - indices: [$idx1, $idx2], points: ${screenPoints.length}');
            continue;
          }

          canvas.drawLine(
            screenPoints[idx1],
            screenPoints[idx2],
            paint,
          );
        }
      } else {
        // Draw triangles
        for (var i = 0; i < indices.length; i += 3) {
          if (i + 2 >= indices.length) {
            print('Warning: Invalid triangle indices at $i');
            continue;
          }

          final idx1 = indices[i];
          final idx2 = indices[i + 1];
          final idx3 = indices[i + 2];

          if (idx1 >= screenPoints.length ||
              idx2 >= screenPoints.length ||
              idx3 >= screenPoints.length) {
            print(
                'Warning: Index out of bounds - indices: [$idx1, $idx2, $idx3], points: ${screenPoints.length}');
            continue;
          }

          final path = Path()
            ..moveTo(screenPoints[idx1].dx, screenPoints[idx1].dy)
            ..lineTo(screenPoints[idx2].dx, screenPoints[idx2].dy)
            ..lineTo(screenPoints[idx3].dx, screenPoints[idx3].dy)
            ..close();

          canvas.drawPath(path, paint);
        }
      }
    }
  }
}

/// Transparent objects render pass
class TransparentPass extends Pass {
  TransparentPass() : super(RenderPassType.transparent);

  @override
  void render(Canvas canvas, Size size, Scene3D scene) {
    final viewProjection = scene.camera.viewMatrix;
    final meshes = scene
        .getVisibleMeshes()
        .where((mesh) =>
            mesh.isVisible(viewProjection) &&
            mesh.material is TransparentMaterial)
        .toList();

    for (final mesh in meshes) {
      final vertices = mesh.getTransformedVertices();
      final screenPoints = RenderUtils.projectVertices(
        vertices,
        viewProjection,
        size,
      );
      final paint = mesh.material.createPaint();

      RenderUtils.renderMeshGeometry(mesh, screenPoints, paint, canvas);
    }
  }
}

/// Post-processing render pass
class PostProcessPass extends Pass {
  final List<PostProcessEffect> effects;
  RenderTarget? _renderTarget;

  PostProcessPass(this.effects) : super(RenderPassType.postProcess);

  @override
  void render(Canvas canvas, Size size, Scene3D scene) async {
    _renderTarget ??= RenderTarget(size);

    ui.Image? currentImage;

    for (final effect in effects) {
      // Draw to render target
      final targetCanvas = _renderTarget!.begin();

      if (currentImage != null) {
        // Draw previous effect result
        targetCanvas.drawImage(currentImage, Offset.zero, Paint());
        currentImage.dispose();
      } else {
        // First pass - draw scene
        targetCanvas.drawPaint(Paint()..color = Colors.transparent);

        // Draw all visible meshes
        final viewProjection = scene.camera.viewMatrix;
        for (final mesh in scene.getVisibleMeshes()) {
          if (mesh.isVisible(viewProjection)) {
            final vertices = mesh.getTransformedVertices();
            final screenPoints = RenderUtils.projectVertices(
              vertices,
              viewProjection,
              size,
            );
            final paint = mesh.material.createPaint();
            RenderUtils.renderMeshGeometry(
                mesh, screenPoints, paint, targetCanvas);
          }
        }
      }

      // Get render target image
      currentImage = await _renderTarget!.end();

      // Apply effect
      effect.apply(currentImage, canvas, size);
    }

    // Clean up final image
    currentImage?.dispose();
  }

  void dispose() {
    _renderTarget?.dispose();
    _renderTarget = null;
  }
}
