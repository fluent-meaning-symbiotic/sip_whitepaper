import 'dart:math' as math;

import 'package:vector_math/vector_math_64.dart';

import 'camera_controller.dart';

/// Controller for free camera movement in 3D space
class FreeCameraController extends CameraController {
  final CameraConfig config;

  Vector2? _lastPosition;
  Vector3 _velocity = Vector3.zero();
  Vector3 _angularVelocity = Vector3.zero();
  bool _isMoving = false;

  // Euler angles for rotation
  double _pitch = 0.0;
  double _yaw = 0.0;

  FreeCameraController(
    super.camera, {
    this.config = const CameraConfig(),
  }) {
    // Initialize Euler angles from current camera orientation
    final forward = camera.target - camera.position;
    _yaw = math.atan2(forward.x, forward.z);
    _pitch = math.asin(forward.y / forward.length);
  }

  @override
  void startMove(Vector2 position) {
    _lastPosition = position;
    _isMoving = true;
  }

  @override
  void endMove() {
    _lastPosition = null;
    _isMoving = false;
  }

  @override
  void update(Vector2 input) {
    if (!_isMoving || _lastPosition == null) return;

    // Calculate movement delta
    final delta = input - _lastPosition!;
    _lastPosition = input;

    // Update rotation (yaw and pitch)
    _yaw -= delta.x * config.rotateSpeed * 0.01;
    _pitch = (_pitch + delta.y * config.rotateSpeed * 0.01)
        .clamp(-math.pi / 2 + 0.1, math.pi / 2 - 0.1);

    // Calculate forward and right vectors
    final forward = Vector3(
      math.sin(_yaw) * math.cos(_pitch),
      math.sin(_pitch),
      math.cos(_yaw) * math.cos(_pitch),
    );
    final right = Vector3(
      math.cos(_yaw),
      0,
      -math.sin(_yaw),
    );
    final up = forward.cross(right).normalized();

    // Update camera orientation
    camera.target = camera.position + forward;
    camera.up = up;
    camera.updateView();
  }

  @override
  void updateZoom(double delta) {
    // In free camera mode, zoom moves the camera forward/backward
    final forward = camera.target - camera.position;
    final direction = forward.normalized();

    // Calculate new position
    final movement = direction * delta * config.zoomSpeed;
    camera.position += movement;
    camera.target += movement;
    camera.updateView();
  }

  /// Move camera in world space
  void moveWorld(Vector3 movement) {
    print('Moving in world space: $movement'); // Debug log
    final scaledMovement = movement * config.moveSpeed;
    camera.position += scaledMovement;
    camera.target += scaledMovement;
    print('New camera position: ${camera.position}'); // Debug log
    print('New camera target: ${camera.target}'); // Debug log
    camera.updateView();
  }

  /// Move camera relative to its current orientation
  void moveLocal(Vector3 movement) {
    print('Moving in local space: $movement'); // Debug log
    // Calculate camera's local axes
    final forward = (camera.target - camera.position).normalized();
    final right = forward.cross(camera.up).normalized();
    final up = right.cross(forward).normalized();

    print('Camera axes:'); // Debug log
    print('  Forward: $forward'); // Debug log
    print('  Right: $right'); // Debug log
    print('  Up: $up'); // Debug log

    // Transform movement from local to world space
    final worldMovement =
        right * movement.x + up * movement.y + forward * movement.z;

    print('Transformed to world movement: $worldMovement'); // Debug log
    moveWorld(worldMovement);
  }

  @override
  void reset() {
    camera.position = Vector3(0, 0, 10);
    camera.target = Vector3.zero();
    camera.up = Vector3(0, 1, 0);
    camera.updateView();

    _pitch = 0.0;
    _yaw = 0.0;
    _velocity = Vector3.zero();
    _angularVelocity = Vector3.zero();
  }
}
