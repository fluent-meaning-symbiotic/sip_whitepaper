import 'package:flutter/material.dart' hide Material;
import 'package:vector_math/vector_math_64.dart' hide Colors;

import '../graph/materials/graph_materials.dart';
import '../three_d/core/material.dart';
import '../three_d/core/mesh.dart';
import '../three_d/physics/particle.dart';

/// A specialized mesh for representing semantic intents as 3D boxes
class SemanticIntentMesh extends Particle {
  static const double defaultWidth = 10.0;
  static const double defaultHeight = 6.0;
  static const double defaultDepth = 2.0;

  final String intentId;
  bool isSelected = false;
  late final Mesh _mesh;

  SemanticIntentMesh({
    required this.intentId,
    required Vector3 position,
    Vector3? rotation,
    Vector3? scale,
  }) : super(position: position) {
    _mesh = Mesh(
      geometry: _createBoxGeometry(defaultWidth, defaultHeight, defaultDepth),
      material: _createBoxMaterial(),
      position: position,
      rotation: rotation,
      scale: scale,
    );
  }

  Mesh get mesh => _mesh;

  static MeshGeometry _createBoxGeometry(
      double width, double height, double depth) {
    final halfWidth = width / 2;
    final halfHeight = height / 2;
    final halfDepth = depth / 2;

    // Define vertices for a box
    final vertices = [
      // Front face
      Vector3(-halfWidth, -halfHeight, halfDepth),
      Vector3(halfWidth, -halfHeight, halfDepth),
      Vector3(halfWidth, halfHeight, halfDepth),
      Vector3(-halfWidth, halfHeight, halfDepth),
      // Back face
      Vector3(-halfWidth, -halfHeight, -halfDepth),
      Vector3(halfWidth, -halfHeight, -halfDepth),
      Vector3(halfWidth, halfHeight, -halfDepth),
      Vector3(-halfWidth, halfHeight, -halfDepth),
    ];

    // Define indices for triangles
    final indices = [
      // Front face
      0, 1, 2, 0, 2, 3,
      // Back face
      5, 4, 7, 5, 7, 6,
      // Top face
      3, 2, 6, 3, 6, 7,
      // Bottom face
      4, 5, 1, 4, 1, 0,
      // Right face
      1, 5, 6, 1, 6, 2,
      // Left face
      4, 0, 3, 4, 3, 7,
    ];

    return MeshGeometry(vertices: vertices, indices: indices);
  }

  static Material _createBoxMaterial() {
    return NodeMaterial(
      color: Colors.blue.withOpacity(0.7),
    );
  }

  void setSelected(bool selected) {
    if (isSelected != selected) {
      isSelected = selected;
      _mesh.material = NodeMaterial(
        color: Colors.blue.withOpacity(0.7),
        selected: selected,
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _mesh.position = position;
  }
}

/// A specialized mesh for representing relationships between semantic intents
class SemanticRelationshipMesh extends Mesh {
  final String sourceId;
  final String targetId;
  bool isHighlighted = false;
  MeshGeometry _geometry;

  SemanticRelationshipMesh({
    required this.sourceId,
    required this.targetId,
    required Vector3 start,
    required Vector3 end,
  })  : _geometry = _createArrowGeometry(start, end),
        super(
          geometry: _createArrowGeometry(start, end),
          material: _createArrowMaterial(),
        );

  @override
  MeshGeometry get geometry => _geometry;

  set geometry(MeshGeometry value) {
    _geometry = value;
  }

  static MeshGeometry _createArrowGeometry(Vector3 start, Vector3 end) {
    final direction = end - start;
    final length = direction.length;
    final normalized = direction.normalized();

    // Create arrow shaft
    final vertices = [start, end];

    // Create arrow head (simple for now)
    final headLength = length * 0.2; // 20% of total length
    final headBase = end - normalized.scaled(headLength);

    // Add perpendicular vectors for arrow head
    final perpendicular = _getPerpendicular(normalized);
    final headWidth = length * 0.1; // 10% of total length
    final headLeft = headBase + perpendicular.scaled(headWidth);
    final headRight = headBase - perpendicular.scaled(headWidth);

    vertices.addAll([headLeft, headRight]);

    // Define indices for lines
    final indices = [
      // Arrow shaft
      0, 1,
      // Arrow head
      1, 2,
      1, 3,
    ];

    return MeshGeometry(vertices: vertices, indices: indices);
  }

  static Vector3 _getPerpendicular(Vector3 v) {
    // Find a vector perpendicular to v
    if (v.x.abs() < v.y.abs()) {
      return Vector3(0, -v.z, v.y).normalized();
    } else {
      return Vector3(-v.z, 0, v.x).normalized();
    }
  }

  static Material _createArrowMaterial() {
    return EdgeMaterial(
      color: Colors.grey.withOpacity(0.7),
      strokeWidth: 1.5,
    );
  }

  void setHighlighted(bool highlighted) {
    if (isHighlighted != highlighted) {
      isHighlighted = highlighted;
      material = EdgeMaterial(
        color: highlighted ? Colors.orange : Colors.grey.withOpacity(0.7),
        strokeWidth: highlighted ? 2.5 : 1.5,
      );
    }
  }

  void updatePositions(Vector3 start, Vector3 end) {
    geometry = _createArrowGeometry(start, end);
  }
}
