import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'graph_renderer.dart';
import 'graph_scene.dart';

class Graph3DComponent extends PositionComponent {
  final GraphScene scene;
  final GraphRenderer renderer;
  bool _initialized = false;

  Graph3DComponent({
    GraphScene? scene,
    GraphRenderer? renderer,
    super.position,
    super.size,
  })  : scene = scene ?? GraphScene(),
        renderer = renderer ?? GraphRenderer();

  @override
  void update(double dt) {
    scene.update(dt);
  }

  @override
  void render(Canvas canvas) {
    if (!_initialized) {
      _initializeDemo();
      _initialized = true;
    }
    renderer.render(scene, canvas, size.toSize());
  }

  void _initializeDemo() {
    // Add some test nodes and edges
    scene.addGraphNode('A', Vector3(-5, 0, 0));
    scene.addGraphNode('B', Vector3(5, 0, 0));
    scene.addGraphNode('C', Vector3(0, 5, 0));

    scene.addEdge('A', 'B');
    scene.addEdge('B', 'C');
    scene.addEdge('C', 'A');
  }
}
