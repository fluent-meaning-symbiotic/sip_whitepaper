import 'package:vector_math/vector_math_64.dart' hide Colors;

/// A 3D camera with view matrix calculation
class Camera3D {
  Vector3 position;
  Vector3 target;
  Vector3 up;

  Camera3D({
    Vector3? position,
    Vector3? target,
    Vector3? up,
  })  : position = position ?? Vector3(0.0, 0.0, 10.0),
        target = target ?? Vector3(0.0, 0.0, 0.0),
        up = up ?? Vector3(0.0, 1.0, 0.0);

  Matrix4 get viewMatrix {
    final forward = (target - position).normalized();
    final right = forward.cross(up).normalized();
    final newUp = right.cross(forward).normalized();

    return Matrix4.identity()
      ..setValues(
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
        -right.dot(position),
        -newUp.dot(position),
        forward.dot(position),
        1.0,
      );
  }
}
