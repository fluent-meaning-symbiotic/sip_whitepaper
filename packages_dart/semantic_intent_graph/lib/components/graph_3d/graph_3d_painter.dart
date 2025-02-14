import 'package:flutter/material.dart';

import 'camera_3d.dart';
import 'graph_node_3d.dart';
import 'graph_scene.dart';

class Graph3DPainter extends CustomPainter {
  final Camera3D camera;
  final Matrix4 projectionMatrix;
  final GraphScene scene;
  final Paint _nodePaint;
  final Paint _edgePaint;
  final Paint _selectedPaint;

  Graph3DPainter({
    required this.camera,
    required this.projectionMatrix,
    required this.scene,
  })  : _nodePaint = Paint()..style = PaintingStyle.fill,
        _edgePaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
        _selectedPaint = Paint()
          ..color = Colors.red
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0;

  void _drawEdge(
      Canvas canvas, GraphEdge edge, Matrix4 viewProjection, Size size) {
    final source = scene.nodes[edge.sourceId];
    final target = scene.nodes[edge.targetId];
    if (source == null || target == null) return;

    final sourceScreen = source.screenPosition(viewProjection, size);
    final targetScreen = target.screenPosition(viewProjection, size);

    if (sourceScreen.z > 0 && targetScreen.z > 0) {
      _edgePaint.color = edge.color;
      canvas.drawLine(
        Offset(sourceScreen.x, sourceScreen.y),
        Offset(targetScreen.x, targetScreen.y),
        _edgePaint,
      );
    }
  }

  void _drawNode(
      Canvas canvas, GraphNode3D node, Matrix4 viewProjection, Size size) {
    final screenPos = node.screenPosition(viewProjection, size);
    if (screenPos.z > 0) {
      _nodePaint.color = node.color;
      canvas.drawCircle(
        Offset(screenPos.x, screenPos.y),
        node.radius * 20 / screenPos.z, // Scale with depth
        node.selected ? _selectedPaint : _nodePaint,
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final viewProjection = projectionMatrix * camera.viewMatrix;

    // Draw edges first (behind nodes)
    for (final edge in scene.edges) {
      _drawEdge(canvas, edge, viewProjection, size);
    }

    // Draw nodes on top
    for (final node in scene.nodes.values) {
      _drawNode(canvas, node, viewProjection, size);
    }
  }

  @override
  bool shouldRepaint(Graph3DPainter oldDelegate) {
    return oldDelegate.camera != camera ||
        oldDelegate.projectionMatrix != projectionMatrix ||
        oldDelegate.scene != scene;
  }
}
