import 'dart:math' hide Point;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'camera_3d.dart';
import 'graph_3d_painter.dart';
import 'graph_node_3d.dart';
import 'graph_scene.dart';

class Graph3DEngineComponent extends FlameGame {
  final Camera3D camera3D;
  final GraphScene scene;
  late Graph3DPainter _painter;
  late Matrix4 _projectionMatrix;

  Graph3DEngineComponent({
    Camera3D? camera,
    GraphScene? scene,
  })  : camera3D = camera ?? Camera3D(),
        scene = scene ?? GraphScene(),
        _projectionMatrix = Matrix4.identity();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _updateProjectionMatrix();
    _initializePainter();
    _addTestNodes();
  }

  void _initializePainter() {
    _painter = Graph3DPainter(
      camera: camera3D,
      projectionMatrix: _projectionMatrix,
      scene: scene,
    );
  }

  void _addTestNodes() {
    const nodeCount = 5;
    for (int i = 0; i < nodeCount; i++) {
      final angle = i * 2 * pi / nodeCount;
      final node = GraphNode3D(
        id: 'node_$i',
        position: Vector3(cos(angle) * 3, sin(angle) * 3, 0),
      );
      scene.addNode(node);

      if (i > 0) {
        scene.addEdge('node_${i - 1}', 'node_$i');
      }
    }
    // Connect last to first
    scene.addEdge('node_${nodeCount - 1}', 'node_0');
  }

  @override
  void render(Canvas canvas) {
    _painter.paint(canvas, canvasSize.toSize());
    super.render(canvas);
  }

  @override
  void update(double dt) {
    super.update(dt);
    camera3D.update(dt);
    scene.update(dt);
  }

  void _updateProjectionMatrix() {
    const fov = 45.0;
    const near = 0.1;
    const far = 1000.0;
    final aspectRatio = canvasSize.x / canvasSize.y;

    final fovRad = radians(fov);
    final tanHalfFov = tan(fovRad / 2);

    _projectionMatrix = Matrix4.identity()
      ..setEntry(0, 0, 1 / (aspectRatio * tanHalfFov))
      ..setEntry(1, 1, 1 / tanHalfFov)
      ..setEntry(2, 2, -(far + near) / (far - near))
      ..setEntry(2, 3, -2 * far * near / (far - near))
      ..setEntry(3, 2, -1);

    _initializePainter();
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    _updateProjectionMatrix();
  }
}
