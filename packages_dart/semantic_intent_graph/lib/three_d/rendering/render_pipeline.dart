import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/mesh.dart';
import '../core/scene.dart';

/// Types of render passes
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

/// Queue for sorting meshes by render pass
class RenderQueue {
  final Map<RenderPassType, List<Mesh>> _queues = {};

  void addMesh(Mesh mesh, RenderPassType type) {
    _queues.putIfAbsent(type, () => []).add(mesh);
  }

  void clear() {
    _queues.clear();
  }

  void sort(Matrix4 viewMatrix) {
    // Sort meshes by distance from camera
    for (final queue in _queues.values) {
      queue.sort((a, b) {
        final aPos = a.position;
        final bPos = b.position;
        final aDist = aPos.distanceToSquared(viewMatrix.getTranslation());
        final bDist = bPos.distanceToSquared(viewMatrix.getTranslation());
        return aDist.compareTo(bDist);
      });
    }
  }

  List<Mesh> getMeshes(RenderPassType type) {
    return _queues[type] ?? [];
  }

  String get stats {
    return _queues
        .map((type, meshes) => MapEntry(type.name, meshes.length))
        .toString();
  }
}
