import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import 'graph/graph_scene.dart';
import 'graph/graph_widget.dart';
import 'services/semantic_intent_loader.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '3D Graph Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  late GraphScene scene;

  @override
  void initState() {
    super.initState();
    scene = GraphScene();
    _setupDemo();
  }

  void _setupDemo() {
    // Create a simple graph
    scene.addGraphNode('A', Vector3(-5, 0, 0));
    scene.addGraphNode('B', Vector3(5, 0, 0));
    scene.addGraphNode('C', Vector3(0, 5, 0));
    scene.addGraphNode('D', Vector3(0, -5, 0));

    // Add some edges
    scene.addEdge('A', 'B');
    scene.addEdge('B', 'C');
    scene.addEdge('C', 'D');
    scene.addEdge('D', 'A');
    scene.addEdge('A', 'C');
    scene.addEdge('B', 'D');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3D Graph Demo'),
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Graph3DWidget(
            scene: scene,
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _addRandomNode,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: _resetCamera,
            child: const Icon(Icons.refresh),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: _loadIntents,
            child: const Icon(Icons.folder_open),
          ),
        ],
      ),
    );
  }

  void _addRandomNode() {
    final random = Vector3(
      (DateTime.now().millisecondsSinceEpoch % 10) - 5.0,
      (DateTime.now().millisecondsSinceEpoch % 7) - 3.5,
      0.0,
    );

    final id = 'N${scene.graphNodes.length + 1}';
    scene.addGraphNode(id, random);

    // Connect to a random existing node
    if (scene.graphNodes.isNotEmpty) {
      final existingId = scene.graphNodes.keys.elementAt(
        DateTime.now().millisecondsSinceEpoch % scene.graphNodes.length,
      );
      scene.addEdge(id, existingId);
    }

    setState(() {});
  }

  void _resetCamera() {
    setState(() {
      scene.camera.position = Vector3(0, 0, 20);
      scene.camera.target = Vector3.zero();
      scene.camera.up = Vector3(0, 1, 0);
    });
  }

  Future<void> _loadIntents() async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result == null) return;

    final intents = await SemanticIntentLoader.loadFromDirectory(result);
    setState(() {
      // Clear existing nodes
      scene = GraphScene();

      // Add nodes for each intent
      for (var i = 0; i < intents.length; i++) {
        final intent = intents[i];
        final angle = (i * 2 * math.pi) / intents.length;
        final radius = 10.0;
        final position = Vector3(
          math.cos(angle) * radius,
          math.sin(angle) * radius,
          i * 0.1, // Slight z-offset for each node
        );

        scene.addGraphNode(
          intent.path,
          position,
        );
      }

      // Add edges between consecutive nodes
      for (var i = 0; i < intents.length; i++) {
        final next = (i + 1) % intents.length;
        scene.addEdge(
          intents[i].path,
          intents[next].path,
        );
      }
    });
  }
}
