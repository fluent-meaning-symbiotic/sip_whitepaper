import 'package:vector_math/vector_math_64.dart';

import '../../three_d/core/geometry.dart';

/// Creates a rectangular geometry for graph nodes
class NodeGeometry extends Geometry {
  NodeGeometry({
    double width = 100.0,
    double height = 60.0,
    double depth = 10.0,
  }) {
    // Create a flat rectangular box
    final halfWidth = width / 2;
    final halfHeight = height / 2;
    final halfDepth = depth / 2;

    // Front face vertices
    vertices.addAll([
      Vector3(-halfWidth, -halfHeight, halfDepth), // Bottom-left
      Vector3(halfWidth, -halfHeight, halfDepth), // Bottom-right
      Vector3(halfWidth, halfHeight, halfDepth), // Top-right
      Vector3(-halfWidth, halfHeight, halfDepth), // Top-left
    ]);

    // Back face vertices (slight offset for depth)
    vertices.addAll([
      Vector3(-halfWidth, -halfHeight, -halfDepth), // Bottom-left
      Vector3(halfWidth, -halfHeight, -halfDepth), // Bottom-right
      Vector3(halfWidth, halfHeight, -halfDepth), // Top-right
      Vector3(-halfWidth, halfHeight, -halfDepth), // Top-left
    ]);

    // Front face
    indices.addAll([0, 1, 2, 0, 2, 3]);
    // Back face
    indices.addAll([5, 4, 7, 5, 7, 6]);
    // Top face
    indices.addAll([3, 2, 6, 3, 6, 7]);
    // Bottom face
    indices.addAll([4, 5, 1, 4, 1, 0]);
    // Right face
    indices.addAll([1, 5, 6, 1, 6, 2]);
    // Left face
    indices.addAll([4, 0, 3, 4, 3, 7]);

    computeNormals();
  }
}
