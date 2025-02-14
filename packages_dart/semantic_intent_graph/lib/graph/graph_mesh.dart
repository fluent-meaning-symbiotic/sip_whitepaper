import 'package:flutter/material.dart';

import '../model/semantic_intent.dart';
import '../three_d/core/material.dart';
import '../three_d/core/mesh.dart';
import 'geometry/node_geometry.dart';
import 'graph_node.dart';

/// Visual representation of a graph node
class GraphNodeMesh extends Mesh {
  final GraphNode node;
  final SemanticIntent? intent;

  GraphNodeMesh({
    required this.node,
    this.intent,
    Color color = Colors.blue,
  }) : super(
          geometry: NodeGeometry(
            width: 100.0,
            height: intent?.contentHeight ?? 60.0,
            depth: 10.0,
          ),
          material: BasicMaterial(
            color: color,
            style: PaintingStyle.fill,
          ),
          position: node.position,
        );

  @override
  void update(double dt) {
    super.update(dt);
    position = node.position;
  }
}
