import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import '../core/scene.dart';

/// Debug information display mode
enum DebugDisplayMode {
  none,
  basic,
  detailed,
  performance,
  all,
}

/// Debug statistics for the renderer
class DebugStats {
  int meshCount = 0;
  int vertexCount = 0;
  int triangleCount = 0;
  double frameTime = 0.0;
  Vector3 cameraPosition = Vector3.zero();
  Vector3 cameraTarget = Vector3.zero();

  void reset() {
    meshCount = 0;
    vertexCount = 0;
    triangleCount = 0;
  }

  void updateFromScene(Scene3D scene) {
    meshCount = scene.meshes.length;
    vertexCount = 0;
    triangleCount = 0;

    for (final mesh in scene.meshes) {
      vertexCount += mesh.geometry.vertices.length;
      triangleCount += mesh.geometry.indices.length ~/ 3;
    }

    cameraPosition = scene.camera.position;
    cameraTarget = scene.camera.target;
  }
}

/// Widget that displays debug information overlay
class DebugOverlay extends StatelessWidget {
  final DebugStats stats;
  final DebugDisplayMode displayMode;
  final VoidCallback? onDisplayModeChanged;

  const DebugOverlay({
    super.key,
    required this.stats,
    this.displayMode = DebugDisplayMode.basic,
    this.onDisplayModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (displayMode == DebugDisplayMode.none) return const SizedBox.shrink();

    return Positioned(
      left: 8,
      top: 8,
      child: DefaultTextStyle(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontFamily: 'monospace',
        ),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicStats(),
              if (displayMode == DebugDisplayMode.detailed ||
                  displayMode == DebugDisplayMode.all) ...[
                const SizedBox(height: 8),
                _buildDetailedStats(),
              ],
              if (displayMode == DebugDisplayMode.performance ||
                  displayMode == DebugDisplayMode.all) ...[
                const SizedBox(height: 8),
                _buildPerformanceStats(),
              ],
              const SizedBox(height: 8),
              _buildModeSelector(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Meshes: ${stats.meshCount}'),
        Text('Vertices: ${stats.vertexCount}'),
        Text('Triangles: ${stats.triangleCount}'),
      ],
    );
  }

  Widget _buildDetailedStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Camera Pos: ${_formatVector3(stats.cameraPosition)}'),
        Text('Camera Target: ${_formatVector3(stats.cameraTarget)}'),
      ],
    );
  }

  Widget _buildPerformanceStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Frame Time: ${stats.frameTime.toStringAsFixed(2)}ms'),
        Text(
            'FPS: ${stats.frameTime > 0 ? (1000 / stats.frameTime).round() : 0}'),
      ],
    );
  }

  Widget _buildModeSelector() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Mode: '),
        InkWell(
          onTap: onDisplayModeChanged,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(displayMode.name),
          ),
        ),
      ],
    );
  }

  String _formatVector3(Vector3 v) =>
      '(${v.x.toStringAsFixed(1)}, ${v.y.toStringAsFixed(1)}, ${v.z.toStringAsFixed(1)})';
}
