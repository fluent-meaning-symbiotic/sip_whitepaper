import 'package:flutter/material.dart';

import '../three_d/core/geometry.dart';
import '../three_d/core/material.dart';
import '../three_d/core/mesh.dart';
import 'graph_node.dart';

/// A mesh representing an edge between two graph nodes
class GraphEdgeMesh extends Mesh {
  final GraphNode source;
  final GraphNode target;

  GraphEdgeMesh({
    required this.source,
    required this.target,
    Color color = Colors.grey,
  }) : super(
          geometry: Geometry(), // Dynamic geometry updated each frame
          material: BasicMaterial(
            color: color,
            style: PaintingStyle.stroke,
            strokeWidth: 2.0,
          ),
        );

  /// Updates edge geometry based on node positions
  void updateGeometry() {
    geometry.vertices
      ..clear()
      ..addAll([source.position, target.position]);
  }
}
