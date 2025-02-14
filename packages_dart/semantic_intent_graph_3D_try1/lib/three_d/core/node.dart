import 'package:vector_math/vector_math_64.dart' hide Colors;

/// Base class for all 3D scene nodes
class Node3D {
  Vector3 position;
  Vector3 rotation;
  Vector3 scale;
  bool visible;
  List<Node3D> children = [];
  Node3D? parent;

  Node3D({
    Vector3? position,
    Vector3? rotation,
    Vector3? scale,
    this.visible = true,
  })  : position = position ?? Vector3.zero(),
        rotation = rotation ?? Vector3.zero(),
        scale = scale ?? Vector3(1.0, 1.0, 1.0);

  Matrix4 get worldMatrix {
    return Matrix4.identity()
      ..translate(position)
      ..rotateX(rotation.x)
      ..rotateY(rotation.y)
      ..rotateZ(rotation.z)
      ..scale(scale.x, scale.y, scale.z);
  }

  void update(double dt) {
    // Override in subclasses
  }

  void addChild(Node3D child) {
    children.add(child);
    child.parent = this;
  }

  void removeChild(Node3D child) {
    children.remove(child);
    child.parent = null;
  }
}
