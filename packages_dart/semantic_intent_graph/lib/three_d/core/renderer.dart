import 'package:flutter/material.dart';

import 'scene.dart';

/// Abstract base class for 3D renderers
abstract class Renderer3D {
  /// Renders the scene using the provided canvas and size
  void render(Scene3D scene, Canvas canvas, Size size);

  /// Updates any renderer-specific state
  void update(double dt);

  /// Disposes of any resources
  void dispose();
}
