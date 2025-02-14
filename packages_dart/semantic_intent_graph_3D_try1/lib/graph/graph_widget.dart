import 'package:flutter/material.dart';
import 'package:semantic_intent_graph/three_d/debug/debug_view.dart';

import '../three_d/controls/camera_controller.dart';
import '../three_d/controls/camera_controller_widget.dart';
import 'graph_renderer.dart';
import 'graph_scene.dart';

/// A widget that displays a 3D graph with interactive controls
///
/// Controls:
/// - Orbit: Left mouse drag
/// - Pan: Middle mouse drag or Shift + left drag
/// - Zoom: Mouse wheel or Ctrl + drag
class Graph3DWidget extends StatefulWidget {
  final GraphScene scene;
  final bool enableControls;
  final bool enableSelection;
  final CameraMode cameraMode;

  const Graph3DWidget({
    super.key,
    required this.scene,
    this.enableControls = true,
    this.enableSelection = true,
    this.cameraMode = CameraMode.orbit,
  });

  @override
  State<Graph3DWidget> createState() => _Graph3DWidgetState();
}

class _Graph3DWidgetState extends State<Graph3DWidget> {
  late GraphRenderer _renderer;

  @override
  void initState() {
    super.initState();
    _renderer = GraphRenderer();
    print('Graph3DWidget initialized');
  }

  @override
  Widget build(BuildContext context) {
    print(
        'Building Graph3DWidget with ${widget.scene.graphNodes.length} nodes');
    print('Camera position: ${widget.scene.camera.position}');

    return Debug3DView(
      scene: widget.scene,
      renderer: _renderer,
      child: CameraControllerWidget(
        camera: widget.scene.camera,
        mode: widget.cameraMode,
        config: const CameraConfig(
          moveSpeed: 2.0,
          rotateSpeed: 1.0,
          zoomSpeed: 1.0,
          minDistance: 5.0,
          maxDistance: 100.0,
          damping: 0.9,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            print('Graph3DWidget constraints: $constraints');
            final size = constraints.biggest;
            return CustomPaint(
              size: size,
              painter: _Graph3DPainter(
                scene: widget.scene,
                renderer: _renderer,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Graph3DPainter extends CustomPainter {
  final GraphScene scene;
  final GraphRenderer renderer;

  const _Graph3DPainter({
    required this.scene,
    required this.renderer,
  });

  @override
  void paint(Canvas canvas, Size size) {
    print('_Graph3DPainter.paint: size=$size');
    renderer.render(scene, canvas, size);
  }

  @override
  bool shouldRepaint(covariant _Graph3DPainter oldDelegate) => true;
}
