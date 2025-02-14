import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

class GraphNode3D {
  final String id;
  Vector3 position;
  Vector3 velocity = Vector3.zero();
  final double radius;
  bool selected;
  Color color;

  GraphNode3D({
    required this.id,
    required this.position,
    this.radius = 1.0,
    this.selected = false,
    this.color = Colors.blue,
  });

  void applyForce(Vector3 force) {
    velocity += force;
  }

  void update(double dt) {
    position += velocity * dt;
    // Add damping to prevent infinite motion
    velocity *= 0.95;
  }

  Vector3 screenPosition(Matrix4 viewProjection, Size screenSize) {
    final projected = viewProjection.transformed3(position);
    return Vector3(
      (projected.x / projected.z * screenSize.width / 2) + screenSize.width / 2,
      (projected.y / projected.z * screenSize.height / 2) +
          screenSize.height / 2,
      projected.z,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GraphNode3D &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
