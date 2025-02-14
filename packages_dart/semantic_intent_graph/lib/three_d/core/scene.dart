import '../../graph/graph_node.dart';
import '../core/camera.dart';
import '../core/mesh.dart';
import '../core/node.dart';

/// Manages the scene graph and rendering
class Scene3D {
  final List<Node3D> nodes = [];
  final Camera3D camera;
  final List<Mesh> _meshes = [];

  Scene3D({Camera3D? camera}) : camera = camera ?? Camera3D();

  void addNode(Node3D node) {
    nodes.add(node);
    if (node is Mesh) {
      _meshes.add(node);
    }
  }

  void removeNode(Node3D node) {
    nodes.remove(node);
    if (node is Mesh) {
      _meshes.remove(node);
    }
  }

  void update(double dt) {
    for (final node in nodes) {
      if (node is GraphNode) {
        node.update(dt);
      }
    }
  }

  List<Mesh> getVisibleMeshes() => _meshes.where((m) => m.visible).toList();

  List<Mesh> get meshes => List.unmodifiable(_meshes);

  void addMesh(Mesh mesh) {
    _meshes.add(mesh);
  }

  void removeMesh(Mesh mesh) {
    _meshes.remove(mesh);
  }
}
