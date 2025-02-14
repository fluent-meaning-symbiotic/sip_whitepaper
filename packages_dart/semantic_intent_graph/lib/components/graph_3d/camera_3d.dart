import 'package:semantic_intent_graph/three_d/controls/orbit_controls.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

/// A 3D camera that supports orbit, pan, and zoom controls.
class Camera3D {
  /// Current position of the camera in 3D space.
  late Vector3 position;

  /// Point the camera is looking at.
  late Vector3 target;

  /// Up vector for camera orientation.
  late Vector3 up;

  /// Speed of orbital rotation in radians per pixel.
  final double orbitSpeed;

  /// Speed of panning movement per pixel.
  final double panSpeed;

  /// Speed of zoom movement per scroll unit.
  final double zoomSpeed;

  bool _isDragging = false;
  Vector2? _lastDragPosition;

  /// Creates a camera with optional initial position, target, and settings.
  Camera3D({
    Vector3? position,
    Vector3? target,
    Vector3? up,
    this.orbitSpeed = 0.005,
    this.panSpeed = 0.01,
    this.zoomSpeed = 0.1,
  }) {
    this.position = position ?? Vector3(0.0, 0.0, 10.0);
    this.target = target ?? Vector3(0.0, 0.0, 0.0);
    this.up = up ?? Vector3(0.0, 1.0, 0.0);
  }

  /// Returns the view matrix for the current camera position and orientation.
  Matrix4 get viewMatrix =>
      Matrix4.identity()..customLookAt(position, target, up);

  /// Updates the camera state for the current frame.
  void update(double dt) {
    // Add camera movement logic here if needed
  }

  /// Starts a drag operation from the given screen position.
  void startDrag(Vector2 screenPosition) {
    _isDragging = true;
    _lastDragPosition = screenPosition;
  }

  /// Updates the camera based on the current drag position.
  void updateDrag(Vector2 screenPosition) {
    if (!_isDragging || _lastDragPosition == null) return;

    final delta = screenPosition - _lastDragPosition!;
    final viewDir = target - position;
    final right = viewDir.cross(up).normalized();

    // Rotate around vertical axis (Y)
    final rotationY = Matrix4.rotationY(-delta.x * orbitSpeed);
    final posFromTarget = position - target;
    final rotatedPos = rotationY.transform3(posFromTarget);
    position = target + rotatedPos;

    // Rotate around horizontal axis (right vector)
    final rotationX = Matrix4Utils.rotationAxis(right, -delta.y * orbitSpeed);
    final newPosition = target + rotationX.transform3(position - target);

    // Prevent camera from going below the ground plane
    if (newPosition.y > 0.5) {
      position = newPosition;
    }

    _lastDragPosition = screenPosition;
  }

  /// Ends the current drag operation.
  void endDrag() {
    _isDragging = false;
    _lastDragPosition = null;
  }

  /// Adjusts the camera zoom by the given amount.
  void zoom(double amount) {
    final direction = (target - position).normalized();
    final distance = (target - position).length;
    final newDistance = (distance + amount * zoomSpeed).clamp(1.0, 100.0);
    position = target - direction * newDistance;
  }

  /// Pans the camera by the given screen-space delta.
  void pan(Vector2 screenDelta) {
    final viewDir = target - position;
    final right = viewDir.cross(up).normalized();
    final forward = up.cross(right).normalized();

    final movement = right * (-screenDelta.x * panSpeed) +
        forward * (-screenDelta.y * panSpeed);
    position += movement;
    target += movement;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Camera3D &&
          runtimeType == other.runtimeType &&
          position == other.position &&
          target == other.target &&
          up == other.up;

  @override
  int get hashCode => Object.hash(position, target, up);
}
