import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Manages a render target for off-screen rendering
class RenderTarget {
  ui.PictureRecorder? _recorder;
  Canvas? _canvas;
  ui.Image? _image;
  final Size size;

  RenderTarget(this.size);

  /// Begin recording to this render target
  Canvas begin() {
    _recorder = ui.PictureRecorder();
    _canvas = Canvas(_recorder!);
    return _canvas!;
  }

  /// End recording and create image
  Future<ui.Image> end() async {
    if (_recorder == null || _canvas == null) {
      throw StateError('RenderTarget.begin() must be called before end()');
    }

    final picture = _recorder!.endRecording();
    _image = await picture.toImage(
      size.width.toInt(),
      size.height.toInt(),
    );

    _recorder = null;
    _canvas = null;

    return _image!;
  }

  /// Clean up resources
  void dispose() {
    _image?.dispose();
    _image = null;
    _recorder = null;
    _canvas = null;
  }
}
