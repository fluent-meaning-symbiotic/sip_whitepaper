import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart';

import '../core/camera.dart';
import 'camera_controller.dart';
import 'free_camera.dart';
import 'orbit_controls.dart';

/// Widget that handles camera input and control
class CameraControllerWidget extends StatefulWidget {
  final Camera3D camera;
  final CameraMode mode;
  final CameraConfig config;
  final Widget child;

  const CameraControllerWidget({
    super.key,
    required this.camera,
    this.mode = CameraMode.orbit,
    this.config = const CameraConfig(),
    required this.child,
  });

  @override
  State<CameraControllerWidget> createState() => _CameraControllerWidgetState();
}

class _CameraControllerWidgetState extends State<CameraControllerWidget>
    with SingleTickerProviderStateMixin {
  late CameraController _controller;
  bool _isShiftPressed = false;
  bool _isCtrlPressed = false;
  bool _isAltPressed = false;
  final Set<LogicalKeyboardKey> _pressedKeys = {};
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _createController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _animationController.addListener(_handleContinuousMovement);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CameraControllerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode != widget.mode ||
        oldWidget.camera != widget.camera ||
        oldWidget.config != widget.config) {
      _createController();
    }
  }

  void _createController() {
    switch (widget.mode) {
      case CameraMode.orbit:
        final orbitControls = OrbitControls(widget.camera)
          ..rotateSpeed = widget.config.rotateSpeed
          ..zoomSpeed = widget.config.zoomSpeed
          ..panSpeed = widget.config.moveSpeed
          ..minDistance = widget.config.minDistance
          ..maxDistance = widget.config.maxDistance;
        _controller = orbitControls;
        break;
      case CameraMode.free:
        _controller = FreeCameraController(
          widget.camera,
          config: widget.config,
        );
        break;
    }
  }

  void _handleContinuousMovement() {
    if (widget.mode == CameraMode.free && _controller is FreeCameraController) {
      final freeCamera = _controller as FreeCameraController;
      var movement = Vector3.zero();

      // Accumulate movement from all pressed keys
      for (final key in _pressedKeys) {
        print('Processing pressed key: $key'); // Debug log
        switch (key) {
          case LogicalKeyboardKey.keyW:
            print('Adding forward movement'); // Debug log
            movement += Vector3(0, 0, -1);
            break;
          case LogicalKeyboardKey.keyS:
            print('Adding backward movement'); // Debug log
            movement += Vector3(0, 0, 1);
            break;
          case LogicalKeyboardKey.keyA:
            print('Adding left movement'); // Debug log
            movement += Vector3(-1, 0, 0);
            break;
          case LogicalKeyboardKey.keyD:
            print('Adding right movement'); // Debug log
            movement += Vector3(1, 0, 0);
            break;
          case LogicalKeyboardKey.keyQ:
            print('Adding down movement'); // Debug log
            movement += Vector3(0, -1, 0);
            break;
          case LogicalKeyboardKey.keyE:
            print('Adding up movement'); // Debug log
            movement += Vector3(0, 1, 0);
            break;
        }
      }

      // Apply movement if any keys are pressed
      if (movement != Vector3.zero()) {
        print('Applying movement: $movement'); // Debug log
        movement.normalize();
        movement.scale(0.5); // Reduce movement speed
        freeCamera.moveLocal(movement);
        setState(() {});
      }
    }
  }

  void _handleKeyEvent(KeyEvent event) {
    final isDown = event is KeyDownEvent;
    print(
        'Key event: ${event.logicalKey}, isDown: $isDown, event type: ${event.runtimeType}');

    if (isDown) {
      _pressedKeys.add(event.logicalKey);
    } else {
      _pressedKeys.remove(event.logicalKey);
    }

    if (event.logicalKey == LogicalKeyboardKey.shiftLeft ||
        event.logicalKey == LogicalKeyboardKey.shiftRight) {
      setState(() => _isShiftPressed = isDown);
      print('Shift pressed: $_isShiftPressed');
    } else if (event.logicalKey == LogicalKeyboardKey.controlLeft ||
        event.logicalKey == LogicalKeyboardKey.controlRight) {
      setState(() => _isCtrlPressed = isDown);
      print('Ctrl pressed: $_isCtrlPressed');
    } else if (event.logicalKey == LogicalKeyboardKey.altLeft ||
        event.logicalKey == LogicalKeyboardKey.altRight) {
      setState(() => _isAltPressed = isDown);
      print('Alt pressed: $_isAltPressed');
    }

    // Handle WASD movement for free camera
    if (widget.mode == CameraMode.free && _controller is FreeCameraController) {
      print(
          'Free camera mode active, controller type: ${_controller.runtimeType}');
      final freeCamera = _controller as FreeCameraController;
      if (isDown) {
        print('Processing key down: ${event.logicalKey}');
        switch (event.logicalKey) {
          case LogicalKeyboardKey.keyW:
            print('Moving forward');
            freeCamera.moveLocal(Vector3(0, 0, -1));
            setState(() {});
            break;
          case LogicalKeyboardKey.keyS:
            print('Moving backward');
            freeCamera.moveLocal(Vector3(0, 0, 1));
            setState(() {});
            break;
          case LogicalKeyboardKey.keyA:
            print('Moving left');
            freeCamera.moveLocal(Vector3(-1, 0, 0));
            setState(() {});
            break;
          case LogicalKeyboardKey.keyD:
            print('Moving right');
            freeCamera.moveLocal(Vector3(1, 0, 0));
            setState(() {});
            break;
          case LogicalKeyboardKey.keyQ:
            print('Moving down');
            freeCamera.moveLocal(Vector3(0, -1, 0));
            setState(() {});
            break;
          case LogicalKeyboardKey.keyE:
            print('Moving up');
            freeCamera.moveLocal(Vector3(0, 1, 0));
            setState(() {});
            break;
          default:
            print('Unhandled key: ${event.logicalKey}');
            break;
        }
      }
    } else {
      print(
          'Not in free camera mode or wrong controller type. Mode: ${widget.mode}, Controller: ${_controller.runtimeType}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final focusNode = FocusNode(debugLabel: 'CameraControllerFocus');
    return Focus(
      focusNode: focusNode,
      autofocus: true,
      canRequestFocus: true, // Ensure we can get focus
      descendantsAreFocusable: false, // Prevent children from taking focus
      onKeyEvent: (node, event) {
        print(
            'Key event type: ${event.runtimeType}, key: ${event.logicalKey}'); // Debug
        _handleKeyEvent(event);
        return KeyEventResult.handled;
      },
      child: GestureDetector(
        onTapDown: (_) => focusNode.requestFocus(),
        // Touch and trackpad gesture handling
        onScaleStart: (details) {
          if (_isShiftPressed || details.pointerCount > 1) {
            _controller.startMove(Vector2(
              details.localFocalPoint.dx,
              details.localFocalPoint.dy,
            ));
          } else {
            _controller.startMove(Vector2(
              details.localFocalPoint.dx,
              details.localFocalPoint.dy,
            ));
          }
        },
        onScaleUpdate: (details) {
          // Handle zoom with scale gesture (pinch)
          if (details.scale != 1.0) {
            final zoomDelta = math.log(details.scale);
            _controller.updateZoom(zoomDelta);
          }

          // Handle rotation and movement
          _controller.update(Vector2(
            details.localFocalPoint.dx,
            details.localFocalPoint.dy,
          ));

          setState(() {}); // Trigger repaint
        },
        onScaleEnd: (details) {
          _controller.endMove();
        },
        // Mouse handling
        child: Listener(
          onPointerDown: (event) {
            if (event.buttons == kPrimaryButton) {
              if (_isShiftPressed) {
                _controller.startMove(Vector2(
                  event.localPosition.dx,
                  event.localPosition.dy,
                ));
              } else {
                _controller.startMove(Vector2(
                  event.localPosition.dx,
                  event.localPosition.dy,
                ));
              }
            } else if (event.buttons == kMiddleMouseButton ||
                event.buttons == kSecondaryButton) {
              _controller.startMove(Vector2(
                event.localPosition.dx,
                event.localPosition.dy,
              ));
            }
          },
          onPointerMove: (event) {
            if (event.buttons != 0) {
              _controller.update(Vector2(
                event.localPosition.dx,
                event.localPosition.dy,
              ));
              setState(() {}); // Trigger repaint
            }
          },
          onPointerUp: (event) {
            _controller.endMove();
          },
          onPointerSignal: (event) {
            if (event is PointerScrollEvent) {
              // Handle trackpad two-finger scroll
              if (event.kind == PointerDeviceKind.trackpad) {
                if (_isShiftPressed) {
                  // Pan with two-finger scroll
                  _controller.startMove(Vector2(
                    event.position.dx,
                    event.position.dy,
                  ));
                  _controller.update(Vector2(
                    event.position.dx + event.scrollDelta.dx * 0.5,
                    event.position.dy + event.scrollDelta.dy * 0.5,
                  ));
                  _controller.endMove();
                } else {
                  // Zoom with two-finger vertical scroll
                  _controller.updateZoom(event.scrollDelta.dy * 0.01);
                }
              } else {
                // Regular mouse wheel zoom
                _controller.updateZoom(event.scrollDelta.dy * 0.005);
              }
              setState(() {});
            }
          },
          child: widget.child,
        ),
      ),
    );
  }
}
