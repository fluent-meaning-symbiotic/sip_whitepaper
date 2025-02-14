import 'package:vector_math/vector_math_64.dart' hide Colors;

import '../three_d/core/mesh.dart';
import '../three_d/core/node.dart';
import '../three_d/core/scene.dart';
import '../three_d/physics/force_system.dart';
import 'graph_edge.dart';
import 'graph_mesh.dart';
import 'graph_node.dart';

/// A specialized scene for graph visualization with physics simulation
class GraphScene extends Scene3D {
  final ForceSystem physics = ForceSystem();
  final Map<String, GraphNode> _nodes = {};
  final Map<String, GraphEdgeMesh> _edges = {};

  @override
  List<Mesh> get meshes => [
        ..._nodes.values
            .where((node) => node.mesh != null)
            .map((node) => node.mesh!),
        ..._edges.values,
      ];

  /// Adds a graph node with the given ID and position
  void addGraphNode(String id, Vector3 position) {
    final node = GraphNode(id: id, position: position);
    final mesh = GraphNodeMesh(node: node);
    node.mesh = mesh; // Store mesh reference in node

    _nodes[id] = node;
    addMesh(mesh);
    physics.addParticle(node);
  }

  /// Removes a graph node by ID
  void removeGraphNode(String id) {
    final node = _nodes.remove(id);
    if (node == null) return;

    // Remove connected edges
    final edgesToRemove = _edges.entries
        .where((entry) =>
            entry.value.source.id == id || entry.value.target.id == id)
        .map((e) => e.key)
        .toList();

    for (final edgeId in edgesToRemove) {
      final edge = _edges.remove(edgeId);
      if (edge != null) {
        removeMesh(edge);
      }
    }

    // Remove node's mesh
    if (node.mesh != null) {
      removeMesh(node.mesh!);
    }

    physics.removeParticle(node);
    super.removeNode(node);
  }

  @override
  void addNode(Node3D node) {
    super.addNode(node);
    if (node is GraphNode) {
      _nodes[node.id] = node;
      physics.addParticle(node);
    }
  }

  @override
  void removeNode(Node3D node) {
    super.removeNode(node);
    if (node is GraphNode) {
      _nodes.remove(node.id);
      physics.removeParticle(node);
    }
  }

  /// Adds an edge between two nodes
  void addEdge(String sourceId, String targetId) {
    final source = _nodes[sourceId];
    final target = _nodes[targetId];
    if (source == null || target == null) return;

    final edgeId = '$sourceId-$targetId';
    if (_edges.containsKey(edgeId)) return;

    final edge = GraphEdgeMesh(source: source, target: target);
    _edges[edgeId] = edge;
    addMesh(edge);

    physics.addForce(SpringForce(
      particleA: source,
      particleB: target,
      springConstant: 0.5,
      restLength: 200.0,
      damping: 0.3,
    ));
  }

  /// Removes an edge between two nodes
  void removeEdge(String sourceId, String targetId) {
    final edgeId = '$sourceId-$targetId';
    final edge = _edges.remove(edgeId);
    if (edge != null) {
      removeMesh(edge);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    physics.update(dt);

    // Update edge geometries
    for (final edge in _edges.values) {
      edge.updateGeometry();
    }
  }

  /// Gets all graph nodes (unmodifiable)
  Map<String, GraphNode> get graphNodes => Map.unmodifiable(_nodes);

  /// Gets all edges (unmodifiable)
  List<GraphEdgeMesh> get edges => List.unmodifiable(_edges.values);
}
