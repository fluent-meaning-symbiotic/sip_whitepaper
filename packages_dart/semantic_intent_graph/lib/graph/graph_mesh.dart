import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import '../model/semantic_intent_file.dart';
import '../three_d/core/material.dart';
import '../three_d/core/mesh.dart';
import 'graph_node.dart';

/// Visual representation of a graph node
class GraphNodeMesh extends Mesh {
  final GraphNode node;
  final SemanticIntentFile? intent;
  static const double nodeSize = 20.0; // Make nodes bigger for testing

  GraphNodeMesh({
    required this.node,
    this.intent,
  }) : super(
          geometry: _createNodeGeometry(),
          material: BasicMaterial(
            color: Colors.blue,
            style: PaintingStyle.fill,
          ),
          position: node.position,
        );

  static MeshGeometry _createNodeGeometry() {
    // Create a simple square for testing
    return MeshGeometry(
      vertices: [
        Vector3(-nodeSize / 2, -nodeSize / 2, 0),
        Vector3(nodeSize / 2, -nodeSize / 2, 0),
        Vector3(nodeSize / 2, nodeSize / 2, 0),
        Vector3(-nodeSize / 2, nodeSize / 2, 0),
      ],
      indices: [0, 1, 2, 0, 2, 3], // Two triangles forming a square
    );
  }

  @override
  void update(double dt) {
    position = node.position;
  }
}
