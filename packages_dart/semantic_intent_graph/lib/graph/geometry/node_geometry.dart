import 'dart:math' as math;

import 'package:vector_math/vector_math_64.dart';

import '../../three_d/core/geometry.dart';

/// Creates a circular geometry for graph nodes
class NodeGeometry extends Geometry {
  NodeGeometry({
    double radius = 1.0,
    int segments = 16,
  }) {
    // Create circle vertices
    final vertices = <Vector3>[];
    final indices = <int>[];

    // Center vertex
    vertices.add(Vector3(0, 0, 0));

    // Circle vertices
    for (var i = 0; i < segments; i++) {
      final angle = i * 2 * math.pi / segments;
      vertices.add(Vector3(
        math.cos(angle) * radius,
        math.sin(angle) * radius,
        0,
      ));
    }

    // Create triangles
    for (var i = 1; i <= segments; i++) {
      indices.addAll([
        0, // center
        i, // current vertex
        i < segments ? i + 1 : 1, // next vertex (wrap around)
      ]);
    }

    this.vertices.addAll(vertices);
    this.indices.addAll(indices);
    computeNormals();
  }
}
