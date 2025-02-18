import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';

/// Initialize golden tests
Future<void> initializeGoldenTests() async {
  await loadFonts();
}

/// Wrapper for golden test widgets
Widget Function(Widget?) goldenWrapper({final ThemeData? theme}) =>
    (final child) => MaterialApp(theme: theme, home: Material(child: child));
