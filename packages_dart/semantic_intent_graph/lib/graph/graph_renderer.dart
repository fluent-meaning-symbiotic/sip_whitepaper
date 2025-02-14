import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import '../three_d/core/projection.dart';
import '../three_d/core/scene.dart';
import '../three_d/rendering/flutter_renderer.dart';
import '../three_d/rendering/render_utils.dart';
import 'graph_scene.dart';

/// Renderer specialized for graph visualization
class GraphRenderer extends FlutterRenderer {
  final Paint _edgePaint;
  final Paint _selectedPaint;
  Matrix4 _projectionMatrix = Matrix4.identity();

  GraphRenderer({
    Color edgeColor = Colors.grey,
    Color selectedColor = Colors.orange,
    double edgeWidth = 2.0,
  })  : _edgePaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = edgeWidth
          ..color = edgeColor,
        _selectedPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = edgeWidth * 1.5
          ..color = selectedColor;

  @override
  void render(Scene3D scene, Canvas canvas, Size size) {
    _updateProjection(size);
    super.render(scene, canvas, size);

    if (scene is GraphScene) {
      _renderHighlights(scene, canvas, size);
    }
  }

  void _updateProjection(Size size) {
    const fov = 45.0;
    const near = 0.1;
    const far = 1000.0;
    final aspectRatio = size.width / size.height;

    _projectionMatrix = Projection.perspective(
      fov: fov,
      aspectRatio: aspectRatio,
      near: near,
      far: far,
    );
  }

  void _renderHighlights(GraphScene scene, Canvas canvas, Size size) {
    final viewProjection = _projectionMatrix * scene.camera.viewMatrix;

    for (final node in scene.graphNodes.values) {
      if (node.selected) {
        final screenPos = _projectPoint(node.position, viewProjection, size);
        canvas.drawCircle(screenPos, 12, _selectedPaint);
      }
    }
  }

  Offset _projectPoint(Vector3 point, Matrix4 viewProjection, Size size) {
    return RenderUtils.projectVertices([point], viewProjection, size)[0];
  }
}
