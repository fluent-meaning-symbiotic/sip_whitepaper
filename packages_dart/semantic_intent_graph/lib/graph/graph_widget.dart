import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:semantic_intent_graph/three_d/debug/debug_view.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import '../three_d/controls/orbit_controls.dart';
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

  const Graph3DWidget({
    super.key,
    required this.scene,
    this.enableControls = true,
    this.enableSelection = true,
  });

  @override
  State<Graph3DWidget> createState() => _Graph3DWidgetState();
}

class _Graph3DWidgetState extends State<Graph3DWidget> {
  late OrbitControls _controls;
  late GraphRenderer _renderer;
  bool _isShiftPressed = false;
  bool _isCtrlPressed = false;

  @override
  void initState() {
    super.initState();
    _controls = OrbitControls(widget.scene.camera)
      ..rotateSpeed = 1.0
      ..zoomSpeed = 1.0
      ..panSpeed = 1.0
      ..minDistance = 5.0
      ..maxDistance = 100.0;
    _renderer = GraphRenderer();
    print('Graph3DWidget initialized');
  }

  void _handleKeyEvent(KeyEvent event) {
    final isDown = event is RawKeyDownEvent;
    if (event.logicalKey == LogicalKeyboardKey.shiftLeft ||
        event.logicalKey == LogicalKeyboardKey.shiftRight) {
      setState(() => _isShiftPressed = isDown);
    } else if (event.logicalKey == LogicalKeyboardKey.controlLeft ||
        event.logicalKey == LogicalKeyboardKey.controlRight) {
      setState(() => _isCtrlPressed = isDown);
    }
  }

  @override
  Widget build(BuildContext context) {
    print(
        'Building Graph3DWidget with ${widget.scene.graphNodes.length} nodes');
    print('Camera position: ${widget.scene.camera.position}');

    return Debug3DView(
      scene: widget.scene,
      renderer: _renderer,
      child: Focus(
        autofocus: true,
        onKeyEvent: (_, event) {
          _handleKeyEvent(event);
          return KeyEventResult.handled;
        },
        child: GestureDetector(
          // Touch and trackpad gesture handling
          onScaleStart: (details) {
            if (_isShiftPressed || details.pointerCount > 1) {
              _controls.startPan(Vector2(
                details.localFocalPoint.dx,
                details.localFocalPoint.dy,
              ));
            } else {
              _controls.startRotate(Vector2(
                details.localFocalPoint.dx,
                details.localFocalPoint.dy,
              ));
            }
          },
          onScaleUpdate: (details) {
            // Handle zoom with scale gesture (pinch)
            if (details.scale != 1.0) {
              final zoomDelta = math.log(details.scale);
              _controls.updateZoom(zoomDelta);
            }

            // Handle rotation and pan
            _controls.update(Vector2(
              details.localFocalPoint.dx,
              details.localFocalPoint.dy,
            ));

            setState(() {}); // Trigger repaint
          },
          onScaleEnd: (details) {
            _controls.endRotate();
            _controls.endPan();
            _controls.endZoom();
          },
          // Mouse handling
          child: Listener(
            onPointerDown: (event) {
              if (event.buttons == kPrimaryButton) {
                if (_isShiftPressed) {
                  _controls.startPan(Vector2(
                    event.localPosition.dx,
                    event.localPosition.dy,
                  ));
                } else {
                  _controls.startRotate(Vector2(
                    event.localPosition.dx,
                    event.localPosition.dy,
                  ));
                }
              } else if (event.buttons == kMiddleMouseButton ||
                  event.buttons == kSecondaryButton) {
                _controls.startPan(Vector2(
                  event.localPosition.dx,
                  event.localPosition.dy,
                ));
              }
            },
            onPointerMove: (event) {
              if (event.buttons != 0) {
                _controls.update(Vector2(
                  event.localPosition.dx,
                  event.localPosition.dy,
                ));
                setState(() {}); // Trigger repaint
              }
            },
            onPointerUp: (event) {
              _controls.endRotate();
              _controls.endPan();
            },
            onPointerSignal: (event) {
              if (event is PointerScrollEvent) {
                // Handle trackpad two-finger scroll
                if (event.kind == PointerDeviceKind.trackpad) {
                  if (_isShiftPressed) {
                    // Pan with two-finger scroll
                    _controls.startPan(Vector2(
                      event.position.dx,
                      event.position.dy,
                    ));
                    _controls.update(Vector2(
                      event.position.dx + event.scrollDelta.dx * 0.5,
                      event.position.dy + event.scrollDelta.dy * 0.5,
                    ));
                    _controls.endPan();
                  } else {
                    // Zoom with two-finger vertical scroll
                    _controls.updateZoom(event.scrollDelta.dy * 0.01);
                  }
                } else {
                  // Regular mouse wheel zoom
                  _controls.updateZoom(event.scrollDelta.dy * 0.005);
                }
                setState(() {});
              }
            },
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
