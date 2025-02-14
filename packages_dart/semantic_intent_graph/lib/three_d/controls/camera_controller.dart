import 'package:vector_math/vector_math_64.dart';

import '../core/camera.dart';

/// Base class for camera controllers
abstract class CameraController {
  final Camera3D camera;

  CameraController(this.camera);

  /// Update camera based on input
  void update(Vector2 input);

  /// Handle zoom input
  void updateZoom(double delta);

  /// Start camera movement
  void startMove(Vector2 position);

  /// End camera movement
  void endMove();

  /// Reset camera to default position
  void reset();
}

/// Camera movement mode
enum CameraMode {
  /// Orbit around a target point (default)
  orbit,

  /// Free movement in 3D space
  free,
}

/// Configuration for camera controllers
class CameraConfig {
  /// Movement speed
  final double moveSpeed;

  /// Rotation speed
  final double rotateSpeed;

  /// Zoom speed
  final double zoomSpeed;

  /// Minimum zoom distance
  final double minDistance;

  /// Maximum zoom distance
  final double maxDistance;

  /// Damping factor for smooth movement
  final double damping;

  const CameraConfig({
    this.moveSpeed = 1.0,
    this.rotateSpeed = 1.0,
    this.zoomSpeed = 1.0,
    this.minDistance = 1.0,
    this.maxDistance = 1000.0,
    this.damping = 0.9,
  });
}
