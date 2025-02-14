import 'dart:math';

import 'package:vector_math/vector_math_64.dart' hide Colors;

import 'geometry.dart';
import 'material.dart';
import 'node.dart';

/// A renderable 3D object with geometry and material
class Mesh extends Node3D {
  /// The geometric data of the mesh
  Geometry geometry;

  /// The material defining how to render
  Material material;

  /// Whether this mesh is visible
  @override
  bool visible;

  Mesh({
    required this.geometry,
    required this.material,
    super.position,
    super.rotation,
    super.scale,
    this.visible = true,
  });

  /// Creates a transformed copy of vertices for rendering
  List<Vector3> getTransformedVertices() {
    final transform = worldMatrix;
    return geometry.vertices.map((v) => transform.transformed3(v)).toList();
  }

  /// Tests if a point intersects with this mesh
  bool intersectsPoint(Vector3 point) {
    // Simple bounding sphere test for now
    final center = worldMatrix.getTranslation();
    final radius =
        scale.length * geometry.vertices.map((v) => v.length).reduce(max);

    return (point - center).length <= radius;
  }
}
