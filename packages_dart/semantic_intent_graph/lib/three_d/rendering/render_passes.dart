import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

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

/// Standard geometry render pass
class GeometryPass extends RenderPass {
  GeometryPass() : super(RenderPassType.opaque);

  @override
  void render(Canvas canvas, Size size, Scene3D scene) {
    final viewProjection = scene.camera.viewMatrix;
    final meshes = scene
        .getVisibleMeshes()
        .where((mesh) =>
            mesh.isVisible(viewProjection) &&
            mesh.material is! TransparentMaterial)
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

/// Transparent objects render pass
class TransparentPass extends RenderPass {
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
class PostProcessPass extends RenderPass {
  final List<PostProcessEffect> effects;
  RenderTarget? _renderTarget;

  PostProcessPass(this.effects) : super(RenderPassType.postProcess);

  @override
  Future<void> render(Canvas canvas, Size size, Scene3D scene) async {
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

  @override
  void dispose() {
    _renderTarget?.dispose();
    _renderTarget = null;
  }
}
