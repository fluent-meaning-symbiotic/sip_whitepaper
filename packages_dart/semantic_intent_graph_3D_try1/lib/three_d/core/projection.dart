import 'dart:math' as math;

import 'package:vector_math/vector_math_64.dart' hide Colors;

/// Utility class for creating projection matrices
class Projection {
  /// Creates a perspective projection matrix
  static Matrix4 perspective({
    double fov = 45.0,
    required double aspectRatio,
    double near = 0.1,
    double far = 1000.0,
  }) {
    final fovRad = math.pi * fov / 180.0;
    final tanHalfFov = math.tan(fovRad / 2);

    return Matrix4.identity()
      ..setEntry(0, 0, 1 / (aspectRatio * tanHalfFov))
      ..setEntry(1, 1, 1 / tanHalfFov)
      ..setEntry(2, 2, -(far + near) / (far - near))
      ..setEntry(2, 3, -2 * far * near / (far - near))
      ..setEntry(3, 2, -1);
  }

  /// Creates an orthographic projection matrix
  static Matrix4 orthographic({
    required double left,
    required double right,
    required double bottom,
    required double top,
    required double near,
    required double far,
  }) {
    final matrix = Matrix4.identity();
    final rml = right - left;
    final tmb = top - bottom;
    final fmn = far - near;

    matrix.setEntry(0, 0, 2 / rml);
    matrix.setEntry(1, 1, 2 / tmb);
    matrix.setEntry(2, 2, -2 / fmn);
    matrix.setEntry(0, 3, -(right + left) / rml);
    matrix.setEntry(1, 3, -(top + bottom) / tmb);
    matrix.setEntry(2, 3, -(far + near) / fmn);

    return matrix;
  }
}
