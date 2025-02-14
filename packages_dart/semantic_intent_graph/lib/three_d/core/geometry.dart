import 'package:vector_math/vector_math_64.dart';

/// Represents the geometric data of a 3D object
class Geometry {
  /// Vertices in local space
  final List<Vector3> vertices;

  /// Indices defining triangles
  final List<int> indices;

  /// Normal vectors for lighting calculations
  List<Vector3> normals = [];

  /// UV coordinates for texturing
  final List<Vector2> uvs;

  Geometry({
    List<Vector3>? vertices,
    List<int>? indices,
    List<Vector2>? uvs,
  })  : vertices = vertices ?? [],
        indices = indices ?? [],
        uvs = uvs ?? [];

  /// Creates a copy of this geometry
  Geometry clone() => Geometry(
        vertices: vertices.map((v) => v.clone()).toList(),
        indices: List.from(indices),
        uvs: uvs.map((uv) => uv.clone()).toList(),
      );

  /// Computes vertex normals if not provided
  void computeNormals() {
    normals = List.filled(vertices.length, Vector3.zero());

    // Calculate face normals and accumulate
    for (var i = 0; i < indices.length; i += 3) {
      final v0 = vertices[indices[i]];
      final v1 = vertices[indices[i + 1]];
      final v2 = vertices[indices[i + 2]];

      final normal = (v1 - v0).cross(v2 - v0).normalized();

      normals[indices[i]] += normal;
      normals[indices[i + 1]] += normal;
      normals[indices[i + 2]] += normal;
    }

    // Normalize accumulated normals
    for (var i = 0; i < normals.length; i++) {
      if (normals[i].length > 0) {
        normals[i] = normals[i].normalized();
      }
    }
  }
}
