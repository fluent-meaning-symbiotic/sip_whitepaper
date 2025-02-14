import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/mesh.dart';
import '../core/scene.dart';

/// Defines different types of render passes
enum RenderPassType {
  opaque,
  transparent,
  postProcess,
}

/// Base class for render passes
abstract class RenderPass {
  final RenderPassType type;
  bool enabled;

  RenderPass(this.type, {this.enabled = true});

  void render(Canvas canvas, Size size, Scene3D scene);
}

/// Represents a post-processing effect
abstract class PostProcessEffect {
  void apply(ui.Image input, Canvas canvas, Size size);
}

/// Main render queue system
class RenderQueue {
  final Map<RenderPassType, List<Mesh>> _queues = {
    RenderPassType.opaque: [],
    RenderPassType.transparent: [],
  };

  void clear() {
    for (var queue in _queues.values) {
      queue.clear();
    }
  }

  void addMesh(Mesh mesh, RenderPassType type) {
    _queues[type]?.add(mesh);
  }

  List<Mesh> getMeshes(RenderPassType type) => _queues[type] ?? [];

  void sort(Matrix4 viewMatrix) {
    // Sort opaque front-to-back
    _queues[RenderPassType.opaque]?.sort((a, b) {
      final depthA = viewMatrix.transformed3(a.position).z;
      final depthB = viewMatrix.transformed3(b.position).z;
      return depthA.compareTo(depthB);
    });

    // Sort transparent back-to-front
    _queues[RenderPassType.transparent]?.sort((a, b) {
      final depthA = viewMatrix.transformed3(a.position).z;
      final depthB = viewMatrix.transformed3(b.position).z;
      return depthB.compareTo(depthA);
    });
  }
}
