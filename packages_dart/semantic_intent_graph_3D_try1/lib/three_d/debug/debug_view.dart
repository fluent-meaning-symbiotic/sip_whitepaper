import 'package:flutter/material.dart';

import '../core/renderer.dart';
import '../core/scene.dart';
import 'debug_overlay.dart';
import 'debug_renderer.dart';

/// A widget that adds debug visualization to a 3D scene
class Debug3DView extends StatefulWidget {
  final Scene3D scene;
  final Renderer3D renderer;
  final Widget child;

  const Debug3DView({
    super.key,
    required this.scene,
    required this.renderer,
    required this.child,
  });

  @override
  State<Debug3DView> createState() => _Debug3DViewState();
}

class _Debug3DViewState extends State<Debug3DView> {
  late DebugRenderer _debugRenderer;
  DebugDisplayMode _displayMode = DebugDisplayMode.basic;

  @override
  void initState() {
    super.initState();
    _debugRenderer = DebugRenderer(baseRenderer: widget.renderer);
  }

  void _cycleDisplayMode() {
    setState(() {
      _displayMode = DebugDisplayMode
          .values[((_displayMode.index + 1) % DebugDisplayMode.values.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        DebugOverlay(
          stats: _debugRenderer.stats,
          displayMode: _displayMode,
          onDisplayModeChanged: _cycleDisplayMode,
        ),
      ],
    );
  }
}
