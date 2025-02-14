import 'package:vector_math/vector_math_64.dart';

import '../core/camera.dart';
import '../core/mesh.dart';
import '../core/node.dart';

/// Manages the scene graph and rendering
class Scene3D {
  final List<Node3D> _nodes = [];
  final Camera3D camera;
  final List<Mesh> _meshes = [];

  Scene3D()
      : camera = Camera3D(
          position: Vector3(0, 0, 10),
          target: Vector3(0, 0, 0),
          up: Vector3(0, 1, 0),
        ) {
    // Camera is automatically initialized with default values
    // and view matrix is updated in its constructor
  }

  /// Gets all meshes in the scene
  List<Mesh> get meshes => List.unmodifiable(_meshes);

  /// Gets visible meshes for rendering
  List<Mesh> getVisibleMeshes() {
    // TODO: Implement frustum culling
    return meshes;
  }

  /// Adds a mesh to the scene
  void addMesh(Mesh mesh) {
    _meshes.add(mesh);
  }

  /// Removes a mesh from the scene
  void removeMesh(Mesh mesh) {
    _meshes.remove(mesh);
  }

  /// Adds a node to the scene
  void addNode(Node3D node) {
    _nodes.add(node);
  }

  /// Removes a node from the scene
  void removeNode(Node3D node) {
    _nodes.remove(node);
  }

  /// Updates the scene
  void update(double dt) {
    // Update all nodes
    for (final node in _nodes) {
      node.update(dt);
    }

    // Update all meshes
    for (final mesh in _meshes) {
      mesh.update(dt);
    }

    // Ensure camera view matrix is up to date
    camera.updateView();
  }

  void _updateSpatialIndex() {
    // Implement octree or similar structure
  }
}
