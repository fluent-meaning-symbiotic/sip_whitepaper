import 'package:flutter/material.dart';
import 'package:semantic_intent_graph/graph/graph_mesh.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import '../three_d/core/node.dart';
import '../three_d/physics/particle.dart';
import 'materials/graph_materials.dart';

/// A node in the graph with physics simulation capabilities
class GraphNode extends Node3D implements Particle {
  final String id;
  bool selected;
  GraphNodeMesh? mesh; // Reference to visual representation

  @override
  Vector3 velocity = Vector3.zero();

  @override
  double mass;

  @override
  double damping;

  GraphNode({
    required this.id,
    required Vector3 position,
    this.selected = false,
    this.mass = 1.0,
    this.damping = 0.95,
    super.rotation,
    super.scale,
  }) : super(position: position);

  void setSelected(bool value) {
    selected = value;
    if (mesh != null) {
      mesh!.material = NodeMaterial(
        color: Colors.blue,
        selected: selected,
      );
    }
  }

  @override
  void applyForce(Vector3 force) {
    velocity += force / mass;
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
    velocity *= damping;

    // Update mesh position
    if (mesh != null) {
      mesh!.position = position;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GraphNode && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
