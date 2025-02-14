import 'package:vector_math/vector_math_64.dart' hide Colors;

import '../../graph/graph_node.dart';
import '../core/node.dart';

class ForceDirectedLayout {
  final double repulsion;
  final double attraction;
  final double damping;

  ForceDirectedLayout({
    this.repulsion = 5.0,
    this.attraction = 0.5,
    this.damping = 0.95,
  });

  void applyForces(List<Node3D> nodes, List<(Node3D, Node3D)> edges) {
    // Apply repulsion between all nodes
    for (final node1 in nodes) {
      for (final node2 in nodes) {
        if (identical(node1, node2)) continue;
        _applyRepulsion(node1, node2);
      }
    }

    // Apply attraction along edges
    for (final (source, target) in edges) {
      _applyAttraction(source, target);
    }
  }

  void _applyRepulsion(Node3D node1, Node3D node2) {
    final delta = node1.position - node2.position;
    final distance = delta.length;
    if (distance < 0.0001) return;

    final force = delta.normalized() * (repulsion / (distance * distance));
    _applyForceToNode(node1, force);
    _applyForceToNode(node2, -force);
  }

  void _applyAttraction(Node3D source, Node3D target) {
    final delta = target.position - source.position;
    final force = delta * attraction;
    _applyForceToNode(source, force);
    _applyForceToNode(target, -force);
  }

  void _applyForceToNode(Node3D node, Vector3 force) {
    if (node is GraphNode) {
      node.applyForce(force);
    }
  }
}
