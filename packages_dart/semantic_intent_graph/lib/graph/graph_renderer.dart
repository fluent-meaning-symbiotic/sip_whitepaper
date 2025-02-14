import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import '../three_d/core/scene.dart';
import '../three_d/rendering/flutter_renderer.dart';
import '../three_d/rendering/render_utils.dart';
import 'graph_scene.dart';

/// Renderer specialized for graph visualization
class GraphRenderer extends StandardFlutterRenderer {
  final Paint _edgePaint;
  final Paint _selectedPaint;

  GraphRenderer({
    Color edgeColor = Colors.grey,
    Color selectedColor = Colors.orange,
    double edgeWidth = 2.0,
    super.postProcessEffects,
  })  : _edgePaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = edgeWidth
          ..color = edgeColor,
        _selectedPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = edgeWidth * 1.5
          ..color = selectedColor;

  @override
  void renderScene(Scene3D scene, Canvas canvas, Size size) {
    // First render all meshes using standard pipeline
    super.renderScene(scene, canvas, size);

    // Then add our custom graph overlays
    if (scene is GraphScene) {
      _renderHighlights(scene, canvas, size);
      _renderEdges(scene, canvas, size);
    }
  }

  void _renderHighlights(GraphScene scene, Canvas canvas, Size size) {
    final viewProjection = projectionMatrix * scene.camera.viewMatrix;

    for (final node in scene.graphNodes.values) {
      if (node.isSelected) {
        final screenPos = _projectPoint(node.position, viewProjection, size);
        if (screenPos != null) {
          canvas.drawCircle(screenPos, 12, _selectedPaint);
        }
      }
    }
  }

  void _renderEdges(GraphScene scene, Canvas canvas, Size size) {
    final viewProjection = projectionMatrix * scene.camera.viewMatrix;

    for (final edge in scene.edges) {
      final sourceNode = scene.graphNodes[edge.sourceId];
      final targetNode = scene.graphNodes[edge.targetId];

      if (sourceNode == null || targetNode == null) continue;

      final screenPos1 =
          _projectPoint(sourceNode.position, viewProjection, size);
      final screenPos2 =
          _projectPoint(targetNode.position, viewProjection, size);

      if (screenPos1 != null && screenPos2 != null) {
        // Check if points are within valid drawing bounds
        if (_isValidDrawingPoint(screenPos1, size) &&
            _isValidDrawingPoint(screenPos2, size)) {
          canvas.drawLine(screenPos1, screenPos2, _edgePaint);
        }
      }
    }
  }

  bool _isValidDrawingPoint(Offset point, Size size) {
    // Add some padding to allow drawing slightly outside the visible area
    const padding = 1000.0;
    return point.dx.isFinite &&
        point.dy.isFinite &&
        point.dx >= -padding &&
        point.dx <= size.width + padding &&
        point.dy >= -padding &&
        point.dy <= size.height + padding;
  }

  Offset? _projectPoint(Vector3 point, Matrix4 viewProjection, Size size) {
    try {
      final projected =
          RenderUtils.projectVertices([point], viewProjection, size);
      if (projected.isEmpty) return null;

      final screenPoint = projected[0];
      if (!screenPoint.dx.isFinite || !screenPoint.dy.isFinite) return null;

      return screenPoint;
    } catch (e) {
      print('Error projecting point: $e');
      return null;
    }
  }
}
