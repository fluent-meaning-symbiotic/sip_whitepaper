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

/// Controls for orbiting camera around a target point
class OrbitControls {
  final Camera3D camera;

  // Configuration
  double rotateSpeed = 1.0;
  double zoomSpeed = 1.0;
  double panSpeed = 1.0;

  double minDistance = 1.0;
  double maxDistance = double.infinity;
  double minPolarAngle = 0.0;
  double maxPolarAngle = math.pi;

  bool enableRotate = true;
  bool enableZoom = true;
  bool enablePan = true;

  // Internal state
  final Vector3 _target = Vector3.zero();
  final Spherical _spherical = Spherical();
  final Spherical _sphericalDelta = Spherical();
  final Vector3 _panOffset = Vector3.zero();
  double _scale = 1.0;

  Vector2? _rotateStart;
  Vector2? _rotateEnd;
  Vector2? _panStart;
  Vector2? _panEnd;
  double _zoomStart = 0.0;

  bool _isRotating = false;
  bool _isPanning = false;
  bool _isZooming = false;

  OrbitControls(this.camera) {
    _updateSpherical();
  }

  void _updateSpherical() {
    final offset = camera.position - _target;
    _spherical.setFromVector3(offset);
  }

  void startRotate(Vector2 position) {
    if (!enableRotate) return;
    _isRotating = true;
    _rotateStart = position;
    _rotateEnd = position;
  }

  void startPan(Vector2 position) {
    if (!enablePan) return;
    _isPanning = true;
    _panStart = position;
    _panEnd = position;
  }

  void startZoom(double position) {
    if (!enableZoom) return;
    _isZooming = true;
    _zoomStart = position;
  }

  void update(Vector2 position) {
    if (_isRotating) {
      _rotateEnd = position;
      _handleRotate();
    }
    if (_isPanning) {
      _panEnd = position;
      _handlePan();
    }
    _updateCamera();
  }

  void updateZoom(double delta) {
    if (!enableZoom) return;
    _scale *= math.pow(0.95, delta * zoomSpeed);
    _scale = _scale.clamp(
      minDistance / _spherical.radius,
      maxDistance / _spherical.radius,
    );
    _updateCamera();
  }

  void endRotate() {
    _isRotating = false;
    _rotateStart = null;
    _rotateEnd = null;
  }

  void endPan() {
    _isPanning = false;
    _panStart = null;
    _panEnd = null;
  }

  void endZoom() {
    _isZooming = false;
  }

  void _handleRotate() {
    if (_rotateStart == null || _rotateEnd == null) return;

    final Vector2 delta = _rotateEnd! - _rotateStart!;

    // Rotating up and down along phi
    _sphericalDelta.phi -= 2 * math.pi * delta.y * rotateSpeed / 800;

    // Rotating left and right along theta
    _sphericalDelta.theta -= 2 * math.pi * delta.x * rotateSpeed / 800;

    _rotateStart = _rotateEnd;
  }

  void _handlePan() {
    if (_panStart == null || _panEnd == null) return;

    final Vector2 delta = _panEnd! - _panStart!;

    // Get the camera's right and up vectors
    final Vector3 forward = (_target - camera.position).normalized();
    final Vector3 right = forward.cross(camera.up).normalized();
    final Vector3 up = right.cross(forward).normalized();

    // Scale the movement by the distance to target for consistent speed
    final distance = (_target - camera.position).length;
    final panScale = distance * panSpeed / 400;

    _panOffset.addScaled(right, -delta.x * panScale);
    _panOffset.addScaled(up, delta.y * panScale);

    _panStart = _panEnd;
  }

  void _updateCamera() {
    // Apply rotation
    _spherical.phi += _sphericalDelta.phi;
    _spherical.theta += _sphericalDelta.theta;

    // Restrict phi to avoid the camera flipping upside down
    _spherical.phi = _spherical.phi.clamp(minPolarAngle, maxPolarAngle);

    // Restrict radius
    _spherical.radius *= _scale;
    _spherical.radius = _spherical.radius.clamp(minDistance, maxDistance);

    // Move target by pan offset
    _target.add(_panOffset);

    // Calculate new camera position
    final offset = _spherical.toVector3();
    camera.position = _target + offset;
    camera.target = _target;

    // Reset deltas
    _sphericalDelta.phi = 0;
    _sphericalDelta.theta = 0;
    _panOffset.setZero();
    _scale = 1;

    // Update camera view matrix
    camera.updateView();
  }
}
