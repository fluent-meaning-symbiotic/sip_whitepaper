import 'dart:math' as math;

import 'package:vector_math/vector_math_64.dart' hide Colors;

/// A 3D camera with position, target, and up vector
class Camera3D {
  Vector3 position;
  Vector3 target;
  Vector3 up;
  final Matrix4 viewMatrix = Matrix4.identity();
  final Matrix4 projectionMatrix = Matrix4.identity();

  Camera3D({
    required this.position,
    required this.target,
    required this.up,
  }) {
    updateView();
  }

  /// Updates the view matrix based on current camera parameters
  void updateView() {
    viewMatrix.setFrom(makeViewMatrix(position, target, up));
  }

  /// Updates the projection matrix
  void updateProjection({
    double fov = 45.0,
    double aspectRatio = 1.0,
    double near = 0.1,
    double far = 1000.0,
  }) {
    final fovRad = fov * (math.pi / 180.0);
    final tanHalfFov = math.tan(fovRad / 2);

    projectionMatrix.setZero();
    projectionMatrix.setEntry(0, 0, 1.0 / (aspectRatio * tanHalfFov));
    projectionMatrix.setEntry(1, 1, 1.0 / tanHalfFov);
    projectionMatrix.setEntry(2, 2, -(far + near) / (far - near));
    projectionMatrix.setEntry(2, 3, -(2 * far * near) / (far - near));
    projectionMatrix.setEntry(3, 2, -1);
  }

  /// Creates a view matrix looking from [eye] position towards [target] with [up] direction
  Matrix4 makeViewMatrix(Vector3 eye, Vector3 target, Vector3 up) {
    final z = (eye - target)..normalize();
    final x = up.cross(z)..normalize();
    final y = z.cross(x)..normalize();

    final view = Matrix4.identity();
    view.setEntry(0, 0, x.x);
    view.setEntry(0, 1, x.y);
    view.setEntry(0, 2, x.z);
    view.setEntry(1, 0, y.x);
    view.setEntry(1, 1, y.y);
    view.setEntry(1, 2, y.z);
    view.setEntry(2, 0, z.x);
    view.setEntry(2, 1, z.y);
    view.setEntry(2, 2, z.z);
    view.setEntry(0, 3, -x.dot(eye));
    view.setEntry(1, 3, -y.dot(eye));
    view.setEntry(2, 3, -z.dot(eye));

    return view;
  }

  /// Gets the combined view-projection matrix
  Matrix4 get viewProjectionMatrix =>
      projectionMatrix.clone()..multiply(viewMatrix);
}
