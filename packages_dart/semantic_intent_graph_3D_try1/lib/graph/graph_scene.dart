import 'package:vector_math/vector_math_64.dart' hide Colors;

import '../three_d/core/mesh.dart';
import '../three_d/core/node.dart';
import '../three_d/core/scene.dart';
import '../three_d/physics/force_system.dart';
import 'semantic_intent_mesh.dart';

/// A specialized scene for displaying a 3D graph
class GraphScene extends Scene3D {
  final ForceSystem physics = ForceSystem();
  final Map<String, SemanticIntentMesh> _nodes = {};
  final List<SemanticRelationshipMesh> _edges = [];

  GraphScene() {
    print('Creating new GraphScene');
    // Initialize camera with default values
    camera.position = Vector3(0, 0, 50);
    camera.target = Vector3.zero();
    camera.up = Vector3(0, 1, 0);
    camera.updateView();
    print('Camera initialized at ${camera.position}');
    print('Camera view matrix:\n${camera.viewMatrix}');
  }

  @override
  List<Mesh> get meshes => [
        ..._nodes.values.map((node) => node.mesh),
        ..._edges,
      ];

  /// Adds a graph node with the given ID and position
  void addGraphNode(String id, Vector3 position) {
    if (_nodes.containsKey(id)) return;

    final node = SemanticIntentMesh(
      intentId: id,
      position: position,
    );

    _nodes[id] = node;
    addMesh(node.mesh);
    physics.addParticle(node);
  }

  /// Removes a graph node by ID
  void removeGraphNode(String id) {
    final node = _nodes.remove(id);
    if (node != null) {
      removeMesh(node.mesh);
      // Remove associated edges
      _edges.removeWhere((edge) {
        final shouldRemove = edge.sourceId == id || edge.targetId == id;
        if (shouldRemove) {
          removeMesh(edge);
        }
        return shouldRemove;
      });
      physics.removeParticle(node);
    }
  }

  @override
  void addNode(Node3D node) {
    super.addNode(node);
    if (node is SemanticIntentMesh) {
      final semanticNode = node as SemanticIntentMesh;
      _nodes[semanticNode.intentId] = semanticNode;
      physics.addParticle(semanticNode);
    }
  }

  @override
  void removeNode(Node3D node) {
    super.removeNode(node);
    if (node is SemanticIntentMesh) {
      final semanticNode = node as SemanticIntentMesh;
      _nodes.remove(semanticNode.intentId);
      physics.removeParticle(semanticNode);
    }
  }

  /// Adds an edge between two nodes
  void addEdge(String sourceId, String targetId) {
    if (!_nodes.containsKey(sourceId) || !_nodes.containsKey(targetId)) {
      return;
    }

    final sourceNode = _nodes[sourceId]!;
    final targetNode = _nodes[targetId]!;

    final edge = SemanticRelationshipMesh(
      sourceId: sourceId,
      targetId: targetId,
      start: sourceNode.position,
      end: targetNode.position,
    );

    _edges.add(edge);
    addMesh(edge);

    physics.addForce(SpringForce(
      particleA: sourceNode,
      particleB: targetNode,
      springConstant: 0.5,
      restLength: 20.0,
      damping: 0.3,
    ));
  }

  /// Removes an edge between two nodes
  void removeEdge(String sourceId, String targetId) {
    _edges.removeWhere((edge) {
      final shouldRemove =
          edge.sourceId == sourceId && edge.targetId == targetId;
      if (shouldRemove) {
        removeMesh(edge);
      }
      return shouldRemove;
    });
  }

  void setNodeSelected(String id, bool selected) {
    _nodes[id]?.setSelected(selected);
  }

  void setEdgeHighlighted(String sourceId, String targetId, bool highlighted) {
    for (final edge in _edges) {
      if (edge.sourceId == sourceId && edge.targetId == targetId) {
        edge.setHighlighted(highlighted);
        break;
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    physics.update(dt);

    // Update edge positions based on connected nodes
    for (final edge in _edges) {
      final sourceNode = _nodes[edge.sourceId];
      final targetNode = _nodes[edge.targetId];

      if (sourceNode != null && targetNode != null) {
        edge.updatePositions(sourceNode.position, targetNode.position);
      }
    }
  }

  /// Gets all graph nodes (unmodifiable)
  Map<String, SemanticIntentMesh> get graphNodes => Map.unmodifiable(_nodes);

  /// Gets all edges (unmodifiable)
  List<SemanticRelationshipMesh> get edges => List.unmodifiable(_edges);
}
