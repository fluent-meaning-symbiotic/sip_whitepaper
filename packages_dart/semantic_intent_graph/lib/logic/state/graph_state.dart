import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:semantic_intent_framework/semantic_intent_framework.dart';

class GraphState extends ChangeNotifier {
  final Map<String, SemanticIntent> _nodes;
  final Map<String, Set<String>> _edges;

  GraphState()
      : _nodes = {},
        _edges = {};

  UnmodifiableMapView<String, SemanticIntent> get nodes =>
      UnmodifiableMapView(_nodes);

  Set<String> getEdges(String nodeId) =>
      UnmodifiableSetView(_edges[nodeId] ?? <String>{});

  void addNode(SemanticIntent node) {
    if (_nodes.containsKey(node.id)) return;
    _nodes[node.id] = node;
    notifyListeners();
  }

  void removeNode(String nodeId) {
    if (!_nodes.containsKey(nodeId)) return;
    _nodes.remove(nodeId);
    _edges.remove(nodeId);
    for (final edges in _edges.values) {
      edges.remove(nodeId);
    }
    notifyListeners();
  }

  void addEdge(String sourceId, String targetId) {
    if (!_nodes.containsKey(sourceId) || !_nodes.containsKey(targetId)) return;
    _edges.putIfAbsent(sourceId, () => {}).add(targetId);
    notifyListeners();
  }

  void removeEdge(String sourceId, String targetId) {
    if (!_edges.containsKey(sourceId)) return;
    _edges[sourceId]?.remove(targetId);
    if (_edges[sourceId]?.isEmpty ?? false) {
      _edges.remove(sourceId);
    }
    notifyListeners();
  }

  void clear() {
    _nodes.clear();
    _edges.clear();
    notifyListeners();
  }
}
