import 'package:vector_math/vector_math_64.dart' hide Colors;

/// Represents a 3D transformation
class Transform {
  Vector3 position;
  Vector3 rotation;
  Vector3 scale;
  Matrix4? _cachedMatrix;
  bool _isDirty = true;

  Transform({
    Vector3? position,
    Vector3? rotation,
    Vector3? scale,
  })  : position = position ?? Vector3.zero(),
        rotation = rotation ?? Vector3.zero(),
        scale = scale ?? Vector3(1.0, 1.0, 1.0);

  void setPosition(Vector3 newPosition) {
    position = newPosition;
    _isDirty = true;
  }

  void setRotation(Vector3 newRotation) {
    rotation = newRotation;
    _isDirty = true;
  }

  void setScale(Vector3 newScale) {
    scale = newScale;
    _isDirty = true;
  }

  Matrix4 get matrix {
    if (_isDirty || _cachedMatrix == null) {
      _cachedMatrix = Matrix4.identity()
        ..translate(position)
        ..rotateX(rotation.x)
        ..rotateY(rotation.y)
        ..rotateZ(rotation.z)
        ..scale(scale.x, scale.y, scale.z);
      _isDirty = false;
    }
    return _cachedMatrix!;
  }
}
