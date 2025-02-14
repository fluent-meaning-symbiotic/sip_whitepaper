import 'dart:math' as math;

import 'package:vector_math/vector_math_64.dart' hide Colors;

import '../core/camera.dart';

/// Extension on Matrix4 to add custom lookAt functionality
extension Matrix4Utils on Matrix4 {
  /// Creates a view matrix looking from [eye] position towards [target] with [up] direction
  void customLookAt(Vector3 eye, Vector3 target, Vector3 up) {
    final forward = (target - eye).normalized();
    final right = forward.cross(up).normalized();
    final newUp = right.cross(forward).normalized();

    setValues(
      right.x,
      newUp.x,
      -forward.x,
      0.0,
      right.y,
      newUp.y,
      -forward.y,
      0.0,
      right.z,
      newUp.z,
      -forward.z,
      0.0,
      -right.dot(eye),
      -newUp.dot(eye),
      forward.dot(eye),
      1.0,
    );
  }

  /// Creates a rotation matrix around an arbitrary axis
  static Matrix4 rotationAxis(Vector3 axis, double angle) {
    final c = math.cos(angle);
    final s = math.sin(angle);
    final oneMinusC = 1.0 - c;

    var x = axis.x;
    var y = axis.y;
    var z = axis.z;

    // Normalize axis
    final length = math.sqrt(x * x + y * y + z * z);
    if (length != 1.0) {
      final invLength = 1.0 / length;
      x *= invLength;
      y *= invLength;
      z *= invLength;
    }

    // Build rotation matrix
    return Matrix4(
      x * x * oneMinusC + c,
      y * x * oneMinusC + z * s,
      z * x * oneMinusC - y * s,
      0.0,
      x * y * oneMinusC - z * s,
      y * y * oneMinusC + c,
      z * y * oneMinusC + x * s,
      0.0,
      x * z * oneMinusC + y * s,
      y * z * oneMinusC - x * s,
      z * z * oneMinusC + c,
      0.0,
      0.0,
      0.0,
      0.0,
      1.0,
    );
  }
}

/// Controls for orbiting camera around a target point
class OrbitControls {
  final Camera3D camera;
  final double orbitSpeed;
  final double panSpeed;
  final double zoomSpeed;
  final double minDistance;
  final double maxDistance;
  final double minPolarAngle;
  final double maxPolarAngle;

  bool _isDragging = false;
  Vector2? _lastPosition;

  OrbitControls(
    this.camera, {
    this.orbitSpeed = 0.005,
    this.panSpeed = 0.01,
    this.zoomSpeed = 0.1,
    this.minDistance = 1.0,
    this.maxDistance = 100.0,
    this.minPolarAngle = 0.1,
    this.maxPolarAngle = math.pi - 0.1,
  });

  void startDrag(Vector2 position) {
    _isDragging = true;
    _lastPosition = position;
  }

  void updateDrag(Vector2 position) {
    if (!_isDragging || _lastPosition == null) return;

    final delta = position - _lastPosition!;
    _orbit(delta.x, delta.y);
    _lastPosition = position;
  }

  void endDrag() {
    _isDragging = false;
    _lastPosition = null;
  }

  void zoom(double amount) {
    final direction = (camera.target - camera.position).normalized();
    final distance = (camera.target - camera.position).length;
    final newDistance =
        (distance + amount * zoomSpeed).clamp(minDistance, maxDistance);
    camera.position = camera.target - direction * newDistance;
  }

  void pan(Vector2 delta) {
    final viewDir = camera.target - camera.position;
    final right = viewDir.cross(camera.up).normalized();
    final forward = camera.up.cross(right).normalized();

    final movement =
        right * (-delta.x * panSpeed) + forward * (-delta.y * panSpeed);
    camera.position += movement;
    camera.target += movement;
  }

  void _orbit(double deltaX, double deltaY) {
    final viewDir = camera.target - camera.position;
    final right = viewDir.cross(camera.up).normalized();

    // Rotate around vertical axis (Y)
    final rotationY = Matrix4.rotationY(-deltaX * orbitSpeed);
    final posFromTarget = camera.position - camera.target;
    final rotatedPos = rotationY.transform3(posFromTarget);
    camera.position = camera.target + rotatedPos;

    // Rotate around horizontal axis (right vector)
    final rotationX = Matrix4Utils.rotationAxis(right, -deltaY * orbitSpeed);
    final newPosition =
        camera.target + rotationX.transform3(camera.position - camera.target);

    // Check polar angle limits
    final polar = _getPolarAngle(newPosition);
    if (polar >= minPolarAngle && polar <= maxPolarAngle) {
      camera.position = newPosition;
    }
  }

  double _getPolarAngle(Vector3 position) {
    final dir = (position - camera.target).normalized();
    return math.acos(dir.y.clamp(-1.0, 1.0));
  }
}
