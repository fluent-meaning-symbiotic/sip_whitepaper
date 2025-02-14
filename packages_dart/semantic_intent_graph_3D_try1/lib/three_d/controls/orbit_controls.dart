import 'dart:math' as math;

import 'package:vector_math/vector_math_64.dart' hide Colors;

import 'camera_controller.dart';

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

/// Spherical coordinates for orbit calculations
class Spherical {
  double radius;
  double phi; // polar angle from y (up) axis
  double theta; // azimuthal angle in x-z plane

  Spherical({
    this.radius = 1.0,
    this.phi = 0.0,
    this.theta = 0.0,
  });

  void setFromVector3(Vector3 v) {
    radius = v.length;
    if (radius == 0) {
      phi = 0;
      theta = 0;
      return;
    }

    // phi is the polar angle from y-axis (up)
    phi = math.acos(v.y / radius);
    // theta is the azimuthal angle in x-z plane
    theta = math.atan2(v.x, v.z);
  }

  Vector3 toVector3() {
    final sinPhiRadius = radius * math.sin(phi);
    return Vector3(
      sinPhiRadius * math.sin(theta),
      radius * math.cos(phi),
      sinPhiRadius * math.cos(theta),
    );
  }
}

/// Controls for orbiting around a target point
class OrbitControls extends CameraController {
  double rotateSpeed;
  double zoomSpeed;
  double panSpeed;
  double minDistance;
  double maxDistance;

  Vector2? _lastPosition;
  bool _isRotating = false;
  bool _isPanning = false;

  OrbitControls(
    super.camera, {
    this.rotateSpeed = 1.0,
    this.zoomSpeed = 1.0,
    this.panSpeed = 1.0,
    this.minDistance = 5.0,
    this.maxDistance = 100.0,
  });

  @override
  void startMove(Vector2 position) {
    _lastPosition = position;
    _isRotating = true;
  }

  void startPan(Vector2 position) {
    _lastPosition = position;
    _isPanning = true;
    _isRotating = false;
  }

  @override
  void endMove() {
    _lastPosition = null;
    _isRotating = false;
    _isPanning = false;
  }

  void endRotate() {
    _isRotating = false;
  }

  void endPan() {
    _isPanning = false;
  }

  @override
  void update(Vector2 input) {
    if (_lastPosition == null) return;

    final delta = input - _lastPosition!;
    _lastPosition = input;

    if (_isRotating) {
      _rotate(delta);
    } else if (_isPanning) {
      _pan(delta);
    }
  }

  void _rotate(Vector2 delta) {
    // Calculate the spherical coordinates
    final offset = camera.position - camera.target;
    final radius = offset.length;

    // Convert to spherical coordinates
    var theta = math.atan2(offset.x, offset.z);
    var phi = math.acos(offset.y / radius);

    // Apply rotation
    theta -= delta.x * rotateSpeed * 0.01;
    phi = (phi + delta.y * rotateSpeed * 0.01).clamp(0.1, math.pi - 0.1);

    // Convert back to Cartesian coordinates
    final newPosition = Vector3(
      radius * math.sin(phi) * math.sin(theta),
      radius * math.cos(phi),
      radius * math.sin(phi) * math.cos(theta),
    );

    camera.position = camera.target + newPosition;
    camera.updateView();
  }

  void _pan(Vector2 delta) {
    // Get camera's right and up vectors from view matrix
    final viewMatrix = camera.viewMatrix;
    final right =
        Vector3(viewMatrix.row0.x, viewMatrix.row0.y, viewMatrix.row0.z);
    final up = Vector3(viewMatrix.row1.x, viewMatrix.row1.y, viewMatrix.row1.z);

    final distance = (camera.position - camera.target).length;
    final panScale = distance * panSpeed * 0.002;

    final movement = right * (-delta.x * panScale) + up * (delta.y * panScale);
    camera.position += movement;
    camera.target += movement;
    camera.updateView();
  }

  @override
  void updateZoom(double delta) {
    final offset = camera.position - camera.target;
    final distance = offset.length;
    final direction = offset.normalized();

    // Calculate new distance with zoom
    final newDistance = (distance * math.exp(delta * zoomSpeed))
        .clamp(minDistance, maxDistance);

    camera.position = camera.target + direction * newDistance;
    camera.updateView();
  }

  @override
  void reset() {
    camera.position = Vector3(0, 0, 10);
    camera.target = Vector3.zero();
    camera.up = Vector3(0, 1, 0);
    camera.updateView();
  }
}
