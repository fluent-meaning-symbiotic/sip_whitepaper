import 'package:flutter/material.dart';
import 'package:semantic_intent_graph/three_d/core/projection.dart';

import '../core/material.dart';
import '../core/renderer.dart';
import '../core/scene.dart';
import 'render_passes.dart';
import 'render_pipeline.dart';

/// Base renderer interface for Flutter-based 3D rendering
abstract class BaseFlutterRenderer extends Renderer3D {
  final Matrix4 projectionMatrix = Matrix4.identity();

  void _updateProjection(Size size) {
    const fov = 45.0;
    const near = 0.1;
    const far = 1000.0;
    final aspectRatio = size.width / size.height;

    projectionMatrix.setFrom(Projection.perspective(
      fov: fov,
      aspectRatio: aspectRatio,
      near: near,
      far: far,
    ));
  }

  @override
  void render(Scene3D scene, Canvas canvas, Size size) {
    _updateProjection(size);
    renderScene(scene, canvas, size);
  }

  /// Implement actual scene rendering in subclasses
  void renderScene(Scene3D scene, Canvas canvas, Size size);
}

/// Standard Flutter renderer with render passes and queue
class StandardFlutterRenderer extends BaseFlutterRenderer {
  final RenderQueue _renderQueue = RenderQueue();
  late final List<Pass> _renderPasses;

  StandardFlutterRenderer({List<PostProcessEffect>? postProcessEffects}) {
    _renderPasses = [
      GeometryPass(
        RenderPassType.opaque,
        projectionMatrix: projectionMatrix,
      ),
      TransparentPass(),
      if (postProcessEffects != null) PostProcessPass(postProcessEffects),
    ];
  }

  @override
  void renderScene(Scene3D scene, Canvas canvas, Size size) {
    print('StandardFlutterRenderer.renderScene: size=$size');
    print('Visible meshes: ${scene.getVisibleMeshes().length}');

    _updateRenderQueue(scene);
    print('RenderQueue stats: ${_renderQueue.stats}');

    // Execute render passes
    for (final pass in _renderPasses) {
      if (pass.enabled) {
        print('Executing render pass: ${pass.runtimeType}');
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

  @override
  void update(double dt) {
    // Update any renderer state if needed
  }

  @override
  void dispose() {
    // Clean up any resources
  }
}

/// Simple Flutter renderer for basic rendering without passes
class SimpleFlutterRenderer extends BaseFlutterRenderer {
  @override
  void renderScene(Scene3D scene, Canvas canvas, Size size) {
    // Implement basic rendering without passes
  }

  @override
  void update(double dt) {}

  @override
  void dispose() {}
}

// Export the base class as FlutterRenderer for backward compatibility
typedef FlutterRenderer = BaseFlutterRenderer;
