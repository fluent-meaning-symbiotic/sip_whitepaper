import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import '../three_d/controls/orbit_controls.dart';
import 'graph_renderer.dart';
import 'graph_scene.dart';

/// Controls:
/// - Orbit: Regular drag/swipe
/// - Pan: Shift + drag/swipe or two-finger scroll
/// - Zoom: Ctrl + two-finger scroll
class Graph3DWidget extends StatefulWidget {
  final GraphScene scene;
  final GraphRenderer? renderer;

  const Graph3DWidget({
    super.key,
    required this.scene,
    this.renderer,
  });

  @override
  State<Graph3DWidget> createState() => _Graph3DWidgetState();
}

class _Graph3DWidgetState extends State<Graph3DWidget> {
  late OrbitControls _controls;
  late GraphRenderer _renderer;
  Vector2? _lastPosition;
  bool _isShiftPressed = false;
  bool _isCtrlPressed = false;

  @override
  void initState() {
    super.initState();
    _controls = OrbitControls(widget.scene.camera);
    _renderer = widget.renderer ?? GraphRenderer();
  }

  void _handleKeyEvent(KeyEvent event) {
    setState(() {
      if (event.logicalKey == LogicalKeyboardKey.shiftLeft ||
          event.logicalKey == LogicalKeyboardKey.shiftRight) {
        _isShiftPressed = event is RawKeyDownEvent;
      } else if (event.logicalKey == LogicalKeyboardKey.controlLeft ||
          event.logicalKey == LogicalKeyboardKey.controlRight) {
        _isCtrlPressed = event is RawKeyDownEvent;
      }
    });
  }

  void _handlePointerDown(PointerDownEvent event) {
    _lastPosition = Vector2(event.localPosition.dx, event.localPosition.dy);
    if (!_isShiftPressed) {
      _controls.startDrag(_lastPosition!);
    }
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (_lastPosition == null) return;

    final currentPosition =
        Vector2(event.localPosition.dx, event.localPosition.dy);
    if (_isShiftPressed) {
      // Pan
      final delta = currentPosition - _lastPosition!;
      _controls.pan(delta);
    } else {
      // Orbit
      _controls.updateDrag(currentPosition);
    }
    _lastPosition = currentPosition;
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (!_isShiftPressed) {
      _controls.endDrag();
    }
    _lastPosition = null;
  }

  void _handleScaleStart(ScaleStartDetails details) {
    if (details.pointerCount == 2) {
      _lastPosition =
          Vector2(details.localFocalPoint.dx, details.localFocalPoint.dy);
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount != 2) return;

    final currentPosition = Vector2(
      details.localFocalPoint.dx,
      details.localFocalPoint.dy,
    );

    if (_isCtrlPressed) {
      // Zoom
      _controls.zoom((1 - details.scale) * 10);
    } else {
      // Pan with two fingers
      final delta = currentPosition - _lastPosition!;
      _controls.pan(delta);
    }

    _lastPosition = currentPosition;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (_, event) {
        _handleKeyEvent(event);
        return KeyEventResult.handled;
      },
      child: Listener(
        onPointerDown: _handlePointerDown,
        onPointerMove: _handlePointerMove,
        onPointerUp: _handlePointerUp,
        child: GestureDetector(
          onScaleStart: _handleScaleStart,
          onScaleUpdate: _handleScaleUpdate,
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

  _Graph3DPainter({
    required this.scene,
    required this.renderer,
  });

  @override
  void paint(Canvas canvas, Size size) {
    renderer.render(scene, canvas, size);
  }

  @override
  bool shouldRepaint(_Graph3DPainter oldDelegate) => true;
}
