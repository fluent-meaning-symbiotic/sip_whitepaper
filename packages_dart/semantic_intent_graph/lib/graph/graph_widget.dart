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
  bool _isDragging = false;
  Vector2? _lastMousePosition;
  int _activeButton = 0;

  static const _zoomSpeed = 0.001;
  static const _panSpeed = 0.5;

  @override
  void initState() {
    super.initState();
    _controls = OrbitControls(widget.scene.camera);
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

  void _handlePointerDown(PointerDownEvent event) {
    _activeButton = event.buttons;
    _lastMousePosition =
        Vector2(event.localPosition.dx, event.localPosition.dy);
    _isDragging = true;

    // Start orbit on left click without shift
    if (_activeButton == kPrimaryButton && !_isShiftPressed) {
      _controls.startDrag(_lastMousePosition!);
    }
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (!_isDragging || _lastMousePosition == null) return;

    final currentPosition =
        Vector2(event.localPosition.dx, event.localPosition.dy);
    final delta = (currentPosition - _lastMousePosition!) * _panSpeed;

    if (_isCtrlPressed) {
      // Zoom with any drag while Ctrl is pressed
      _controls.zoom(delta.y * _zoomSpeed * 100);
    } else if (_activeButton == kPrimaryButton) {
      if (_isShiftPressed) {
        // Pan with left drag + shift
        _controls.pan(delta);
      } else {
        // Orbit with left drag
        _controls.updateDrag(currentPosition);
      }
    } else if (_activeButton == kMiddleMouseButton ||
        _activeButton == kSecondaryButton) {
      // Pan with middle/right drag
      _controls.pan(delta);
    }

    if (!_isShiftPressed) {
      _controls.updateDrag(currentPosition);
    }

    _lastMousePosition = currentPosition;
    setState(() {}); // Trigger repaint
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (_activeButton == kPrimaryButton && !_isShiftPressed) {
      _controls.endDrag();
    }
    _isDragging = false;
    _lastMousePosition = null;
    _activeButton = 0;
  }

  void _handleMouseWheel(PointerScrollEvent event) {
    final scrollDelta = event.scrollDelta.dy;
    if (scrollDelta != 0) {
      _controls.zoom(scrollDelta * _zoomSpeed);
      setState(() {}); // Trigger repaint
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
        child: Listener(
          onPointerDown: _handlePointerDown,
          onPointerMove: _handlePointerMove,
          onPointerUp: _handlePointerUp,
          onPointerSignal: (event) {
            if (event is PointerScrollEvent) {
              _handleMouseWheel(event);
            }
          },
          child: CustomPaint(
            painter: _Graph3DPainter(
              scene: widget.scene,
              renderer: _renderer,
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
