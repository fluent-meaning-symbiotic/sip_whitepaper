import 'dart:ui';

import '../core/renderer.dart';
import '../core/scene.dart';
import 'debug_overlay.dart';

/// A renderer wrapper that collects debug information
class DebugRenderer implements Renderer3D {
  final Renderer3D baseRenderer;
  final DebugStats stats;
  Stopwatch? _frameTimer;

  DebugRenderer({
    required this.baseRenderer,
    DebugStats? stats,
  }) : stats = stats ?? DebugStats();

  @override
  void render(Scene3D scene, Canvas canvas, Size size) {
    // Start timing before any work is done
    _frameTimer?.stop();
    _frameTimer = Stopwatch()..start();

    // Update debug statistics
    stats.updateFromScene(scene);

    // Perform actual rendering
    baseRenderer.render(scene, canvas, size);

    // Update frame time, ensure it's never 0 to avoid division issues
    _frameTimer?.stop();
    stats.frameTime = (_frameTimer?.elapsedMicroseconds ?? 0) / 1000.0;
    if (stats.frameTime < 0.001)
      stats.frameTime = 0.001; // Minimum 1 microsecond
  }

  @override
  void update(double dt) {
    baseRenderer.update(dt);
  }

  @override
  void dispose() {
    baseRenderer.dispose();
  }
}
