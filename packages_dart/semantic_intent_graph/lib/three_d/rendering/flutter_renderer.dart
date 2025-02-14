import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import '../core/material.dart';
import '../core/renderer.dart';
import '../core/scene.dart';
import 'render_passes.dart';
import 'render_pipeline.dart';

/// A Flutter-specific renderer implementation using Canvas API
class FlutterRenderer extends Renderer3D {
  final RenderQueue _renderQueue = RenderQueue();
  final List<RenderPass> _renderPasses;
  Matrix4 _projectionMatrix = Matrix4.identity();

  FlutterRenderer({List<PostProcessEffect>? postProcessEffects})
      : _renderPasses = [
          GeometryPass(),
          TransparentPass(),
          if (postProcessEffects != null) PostProcessPass(postProcessEffects),
        ];

  @override
  void render(Scene3D scene, Canvas canvas, Size size) {
    _updateProjection(size);
    _updateRenderQueue(scene);

    // Execute render passes
    for (final pass in _renderPasses) {
      if (pass.enabled) {
        pass.render(canvas, size, scene);
      }
    }
  }

  void _updateRenderQueue(Scene3D scene) {
    _renderQueue.clear();

    // Sort objects into render queues
    for (final mesh in scene.getVisibleMeshes()) {
      final passType = mesh.material is TransparentMaterial
          ? RenderPassType.transparent
          : RenderPassType.opaque;
      _renderQueue.addMesh(mesh, passType);
    }

    // Sort queues
    _renderQueue.sort(scene.camera.viewMatrix);
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

  Matrix4 get projectionMatrix => _projectionMatrix;

  @override
  void update(double dt) {
    // Update any renderer state if needed
  }

  @override
  void dispose() {
    // Clean up any resources
  }
}
