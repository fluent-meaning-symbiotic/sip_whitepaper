import 'package:flutter/material.dart';

import '../three_d/core/geometry.dart';
import '../three_d/core/mesh.dart';
import 'graph_node.dart';
import 'materials/graph_materials.dart';

/// A mesh representing an edge between two graph nodes
class GraphEdgeMesh extends Mesh {
  final GraphNode source;
  final GraphNode target;

  GraphEdgeMesh({
    required this.source,
    required this.target,
    Color color = Colors.grey,
  }) : super(
          geometry: _createEdgeGeometry(source, target),
          material: EdgeMaterial(color: color),
        );

  static Geometry _createEdgeGeometry(GraphNode source, GraphNode target) {
    return Geometry(
      vertices: [source.position, target.position],
      // Use line indices instead of triangles for edges
      indices: [0, 1],
    );
  }

  void updateGeometry() {
    geometry.vertices
      ..clear()
      ..addAll([source.position, target.position]);
  }
}
