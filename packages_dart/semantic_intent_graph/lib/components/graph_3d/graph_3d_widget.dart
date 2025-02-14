import 'package:flame/game.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'graph_3d_engine_component.dart';

class Graph3DWidget extends StatefulWidget {
  const Graph3DWidget({super.key});

  @override
  State<Graph3DWidget> createState() => _Graph3DWidgetState();
}

class _Graph3DWidgetState extends State<Graph3DWidget> {
  late final Graph3DEngineComponent _game;
  bool _isCtrlPressed = false;
  bool _isShiftPressed = false;

  @override
  void initState() {
    super.initState();
    _game = Graph3DEngineComponent();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (_, event) {
        if (event.logicalKey.keyLabel == 'Control') {
          _isCtrlPressed = event is KeyDownEvent;
        }
        if (event.logicalKey.keyLabel == 'Shift') {
          _isShiftPressed = event is KeyDownEvent;
        }
        return KeyEventResult.handled;
      },
      child: Listener(
        onPointerSignal: (PointerSignalEvent event) {
          if (event is PointerScrollEvent) {
            if (_isCtrlPressed) {
              // Ctrl + Scroll = Zoom
              _game.camera3D.zoom(event.scrollDelta.dy);
            } else {
              // Regular scroll = Pan
              _game.camera3D.pan(Vector2(
                    event.scrollDelta.dx,
                    event.scrollDelta.dy,
                  ) *
                  0.05); // Reduced sensitivity for smoother panning
            }
          }
        },
        child: GestureDetector(
          onPanStart: (details) {
            _game.camera3D.startDrag(Vector2(
              details.localPosition.dx,
              details.localPosition.dy,
            ));
          },
          onPanUpdate: (details) {
            if (_isShiftPressed) {
              // Shift + Drag = Pan
              _game.camera3D.pan(Vector2(
                details.delta.dx,
                details.delta.dy,
              ));
            } else {
              // Regular Drag = Orbit
              _game.camera3D.updateDrag(Vector2(
                details.localPosition.dx,
                details.localPosition.dy,
              ));
            }
          },
          onPanEnd: (_) {
            _game.camera3D.endDrag();
          },
          child: GameWidget.controlled(gameFactory: () => _game),
        ),
      ),
    );
  }
}
