import 'dart:math';

import 'package:vector_math/vector_math_64.dart' hide Colors;

import 'material.dart';
import 'node.dart';

/// A renderable 3D object with geometry and material
class Mesh extends Node3D {
  /// The geometric data of the mesh
  final MeshGeometry geometry;

  /// The material defining how to render
  Material material;

  /// Whether this mesh is visible
  @override
  bool visible = true;

  Mesh({
    required this.geometry,
    required this.material,
    Vector3? position,
    Vector3? rotation,
    Vector3? scale,
  }) : super(
          position: position ?? Vector3.zero(),
          rotation: rotation ?? Vector3.zero(),
          scale: scale ?? Vector3(1, 1, 1),
        );

  Matrix4 get transformationMatrix {
    final matrix = Matrix4.identity();

    // Apply transformations in order: Scale -> Rotate -> Translate
    matrix.scale(scale.x, scale.y, scale.z);

    matrix.rotateX(rotation.x);
    matrix.rotateY(rotation.y);
    matrix.rotateZ(rotation.z);

    matrix.setTranslation(position);

    return matrix;
  }

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

  // Add frustum culling
  bool isVisible(Matrix4 viewProjection) {
    // Implement frustum culling check
    return true;
  }
}

class MeshGeometry {
  final List<Vector3> vertices;
  final List<int> indices;

  const MeshGeometry({
    required this.vertices,
    required this.indices,
  });
}
