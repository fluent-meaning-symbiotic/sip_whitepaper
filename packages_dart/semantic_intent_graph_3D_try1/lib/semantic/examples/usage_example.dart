import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart';

import '../types/semantic_intent_types.dart';

// Example semantic intent data class
class GraphNodeIntentData extends SemanticIntentData {
  final String nodeId;
  final Vector3 position;

  const GraphNodeIntentData({
    required this.nodeId,
    required this.position,
    required super.meaning,
    super.description,
    super.properties,
  });
}

// Example usage in a widget
class ExampleWidget extends StatelessWidget {
  const ExampleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final registry = context.watch<SemanticIntentRegistry>();

    // Register a new intent
    void addNodeIntent(String nodeId, Vector3 position) {
      final intentType = SemanticIntentType('node_$nodeId');
      final intentData = GraphNodeIntentData(
        nodeId: nodeId,
        position: position,
        meaning: 'Represents a node in the 3D graph',
        description: 'Node $nodeId at position $position',
      );

      registry.registerIntent(intentType, intentData);
    }

    // Query intents
    void queryNodeIntents() {
      final nodeIntents = registry.findIntentsByMeaning('node');
      for (final intentType in nodeIntents) {
        final data = registry.getIntent(intentType);
        if (data is GraphNodeIntentData) {
          print('Found node ${data.nodeId} at ${data.position}');
        }
      }
    }

    return Container(); // Your widget implementation
  }
}
