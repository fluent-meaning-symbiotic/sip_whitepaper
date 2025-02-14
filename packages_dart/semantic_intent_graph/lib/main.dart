import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import 'graph/graph_scene.dart';
import 'graph/graph_widget.dart';
import 'semantic/providers/semantic_intent_provider.dart';
import 'semantic/types/loaded_intent_data.dart';
import 'semantic/types/semantic_intent_types.dart';
import 'services/semantic_intent_loader.dart';
import 'three_d/controls/camera_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SemanticIntentProvider(
      child: MaterialApp(
        title: '3D Graph Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const DemoPage(),
      ),
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
  CameraMode _cameraMode = CameraMode.free;

  @override
  void initState() {
    super.initState();
    print('Initializing DemoPage');
    scene = GraphScene();
    _setupDemo();
  }

  void _setupDemo() {
    print('Setting up demo scene');
    // Create a simple graph with more visible initial positions
    scene.addGraphNode('A', Vector3(-10, 0, 0));
    scene.addGraphNode('B', Vector3(10, 0, 0));
    scene.addGraphNode('C', Vector3(0, 10, 0));
    scene.addGraphNode('D', Vector3(0, -10, 0));

    // Add some edges
    scene.addEdge('A', 'B');
    scene.addEdge('B', 'C');
    scene.addEdge('C', 'D');
    scene.addEdge('D', 'A');
    scene.addEdge('A', 'C');
    scene.addEdge('B', 'D');

    // Ensure camera is properly positioned
    scene.camera.position = Vector3(0, 0, 50); // Move camera further back
    scene.camera.target = Vector3.zero();
    scene.camera.up = Vector3(0, 1, 0);
  }

  @override
  Widget build(BuildContext context) {
    print('Building DemoPage');
    return Scaffold(
      appBar: AppBar(
        title: const Text('3D Graph Demo'),
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;
            final dimension =
                size.shortestSide * 0.9; // Use 90% of available space
            print('Available size: $size, using dimension: $dimension');

            return Container(
              width: dimension,
              height: dimension,
              color: Colors.black12,
              child: Graph3DWidget(
                scene: scene,
                key: ValueKey('${scene.hashCode}_${_cameraMode.toString()}'),
                cameraMode: _cameraMode,
              ),
            );
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _addRandomNode,
            tooltip: 'Add Random Node',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: _resetCamera,
            tooltip: 'Reset Camera',
            child: const Icon(Icons.refresh),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: _loadIntents,
            tooltip: 'Load Intents',
            child: const Icon(Icons.folder_open),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _cameraMode = _cameraMode == CameraMode.orbit
                    ? CameraMode.free
                    : CameraMode.orbit;
                print('Camera mode switched to: $_cameraMode');
              });
            },
            tooltip: _cameraMode == CameraMode.orbit
                ? 'Switch to Free Camera'
                : 'Switch to Orbit Camera',
            child: Icon(_cameraMode == CameraMode.orbit
                ? Icons.videogame_asset
                : Icons.panorama_photosphere),
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
    print('Starting _loadIntents...');

    final result = await FilePicker.platform.getDirectoryPath();
    print('Selected directory: $result');
    if (result == null) {
      print('No directory selected');
      return;
    }

    print('Loading intents from directory...');
    final intents = await SemanticIntentLoader.loadFromDirectory(result);
    print('Loaded ${intents.length} intents');

    // Get the registry from provider
    final registry =
        Provider.of<SemanticIntentRegistry>(context, listen: false);
    print('Got registry from provider');

    // Clear existing nodes
    scene = GraphScene();
    print('Cleared existing scene');

    // Add nodes for each intent and register them
    for (var i = 0; i < intents.length; i++) {
      final intent = intents[i];
      print('Processing intent: ${intent.path}');

      final angle = (i * 2 * math.pi) / intents.length;
      final radius = 10.0;
      final position = Vector3(
        math.cos(angle) * radius,
        math.sin(angle) * radius,
        i * 0.1,
      );

      // Create semantic intent
      final intentType = SemanticIntentType('loaded_${intent.path}');
      final intentData = LoadedIntentData(
        path: intent.path,
        position: position,
        meaning: 'Loaded intent from file system',
        description: 'Intent loaded from path: ${intent.path}',
        file: intent,
      );

      // Register the intent
      registry.registerIntent(intentType, intentData);
      print('Registered intent: ${intent.path}');

      // Add node to scene
      scene.addGraphNode(intent.path, position);
      print('Added node to scene: ${intent.path}');
    }

    // Add edges between consecutive nodes
    for (var i = 0; i < intents.length; i++) {
      final next = (i + 1) % intents.length;
      scene.addEdge(
        intents[i].path,
        intents[next].path,
      );
      print('Added edge: ${intents[i].path} -> ${intents[next].path}');
    }

    print('Calling setState...');
    setState(() {
      // Reset camera after loading new nodes
      scene.camera.position = Vector3(0, 0, 20);
      scene.camera.target = Vector3.zero();
      scene.camera.up = Vector3(0, 1, 0);
    });
    print('_loadIntents completed');
  }
}
