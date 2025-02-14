import 'package:flutter/material.dart';

import 'graph_node_3d.dart';

class GraphEdge {
  final String sourceId;
  final String targetId;
  final Color color;

  const GraphEdge({
    required this.sourceId,
    required this.targetId,
    this.color = Colors.grey,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GraphEdge &&
          runtimeType == other.runtimeType &&
          sourceId == other.sourceId &&
          targetId == other.targetId;

  @override
  int get hashCode => sourceId.hashCode ^ targetId.hashCode;
}

class GraphScene {
  final Map<String, GraphNode3D> nodes = {};
  final List<GraphEdge> edges = [];

  void addNode(GraphNode3D node) {
    nodes[node.id] = node;
  }

  void addEdge(String sourceId, String targetId) {
    edges.add(GraphEdge(sourceId: sourceId, targetId: targetId));
  }

  void update(double dt) {
    // Simple force-directed layout
    _applyForces();

    // Update node positions
    for (final node in nodes.values) {
      node.update(dt);
    }
  }

  void _applyForces() {
    const repulsion = 5.0;
    const attraction = 0.5;

    // Apply repulsion between all nodes
    for (final node1 in nodes.values) {
      for (final node2 in nodes.values) {
        if (node1.id == node2.id) continue;

        final delta = node1.position - node2.position;
        final distance = delta.length;
        if (distance < 0.0001) continue;

        final force = delta.normalized() * (repulsion / (distance * distance));
        node1.applyForce(force);
        node2.applyForce(-force);
      }
    }

    // Apply attraction along edges
    for (final edge in edges) {
      final source = nodes[edge.sourceId];
      final target = nodes[edge.targetId];
      if (source == null || target == null) continue;

      final delta = target.position - source.position;
      final distance = delta.length;
      final force = delta * attraction;

      source.applyForce(force);
      target.applyForce(-force);
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GraphScene &&
          runtimeType == other.runtimeType &&
          nodes.length == other.nodes.length &&
          edges.length == other.edges.length;

  @override
  int get hashCode => nodes.hashCode ^ edges.hashCode;
}
