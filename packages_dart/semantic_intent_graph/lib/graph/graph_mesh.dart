import 'package:flutter/material.dart';

import '../three_d/core/material.dart';
import '../three_d/core/mesh.dart';
import 'geometry/node_geometry.dart';
import 'graph_node.dart';

/// Visual representation of a graph node
class GraphNodeMesh extends Mesh {
  final GraphNode node;

  GraphNodeMesh({
    required this.node,
    Color color = Colors.blue,
    double radius = 1.0,
  }) : super(
          geometry: NodeGeometry(radius: radius),
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
