import 'package:flutter/material.dart';

class PathEditorTool {
  PathEditorTool._();
  static final _validSegmentPattern = RegExp(r'^[a-zA-Z0-9_\-]+$');

  static String addSegment(
    final String path,
    final String segment, [
    final int? position,
  ]) {
    if (!_validSegmentPattern.hasMatch(segment)) {
      throw ArgumentError('Invalid segment: $segment');
    }

    final segments = path.split('/');

    if (position != null) {
      segments.insert(position, segment);
    } else {
      segments.add(segment);
    }

    return _validateAndNormalizePath(segments.join('/'));
  }

  static String removeSegment(final String path, final int position) {
    final segments = path.split('/');

    if (position < 0 || position >= segments.length) {
      throw RangeError('Invalid position: $position');
    }

    segments.removeAt(position);
    return _validateAndNormalizePath(segments.join('/'));
  }

  static String reorderSegment(
    final String path,
    final int oldPosition,
    final int newPosition,
  ) {
    final segments = path.split('/');

    if (oldPosition < 0 ||
        oldPosition >= segments.length ||
        newPosition < 0 ||
        newPosition >= segments.length) {
      throw RangeError('Invalid position');
    }

    final segment = segments.removeAt(oldPosition);
    segments.insert(newPosition, segment);

    return _validateAndNormalizePath(segments.join('/'));
  }

  static String _validateAndNormalizePath(final String path) {
    final segments = path.split('/')..removeWhere((final s) => s.isEmpty);

    if (segments.isEmpty || segments[0] != 'lib') {
      throw ArgumentError('Path must start with lib/');
    }

    if (segments.length < 2) {
      throw ArgumentError('Path must have at least 2 segments');
    }

    final lastSegment = segments.last;
    if (!lastSegment.endsWith('.dart') && !lastSegment.endsWith('.yaml')) {
      throw ArgumentError('Path must end with .dart or .yaml');
    }

    return segments.join('/');
  }
}

class PathValidationRules {
  static bool validStructure(final String path) {
    try {
      PathEditorTool._validateAndNormalizePath(path);
      return true;
    } catch (e) {
      return false;
    }
  }

  static bool nonEmpty(final String path) {
    final segments = path.split('/')..removeWhere((final s) => s.isEmpty);
    return segments.length >= 2 && segments[0] == 'lib';
  }
}

class PathEditorState extends ChangeNotifier {
  PathEditorState(final String initialPath) : _currentPath = initialPath {
    _undoStack.add(initialPath);
  }
  final List<String> _undoStack = [];
  final List<String> _redoStack = [];
  String _currentPath;

  String get currentPath => _currentPath;

  void updatePath(final String newPath) {
    if (newPath != _currentPath) {
      _undoStack.add(_currentPath);
      _redoStack.clear();
      _currentPath = newPath;
      notifyListeners();
    }
  }

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  void undo() {
    if (canUndo) {
      _redoStack.add(_currentPath);
      _currentPath = _undoStack.removeLast();
      notifyListeners();
    }
  }

  void redo() {
    if (canRedo) {
      _undoStack.add(_currentPath);
      _currentPath = _redoStack.removeLast();
      notifyListeners();
    }
  }
}
