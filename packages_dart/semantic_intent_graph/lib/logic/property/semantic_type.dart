import 'package:meta/meta.dart';

/// Base class for all semantic types in the system.
@immutable
abstract class SemanticType {
  final String name;
  final String description;

  const SemanticType({
    required this.name,
    required this.description,
  });

  /// Validates if a value matches this semantic type's requirements.
  bool validate(dynamic value);

  /// Converts a value to this semantic type's format.
  /// Throws [FormatException] if conversion is not possible.
  dynamic convert(dynamic value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemanticType &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          description == other.description;

  @override
  int get hashCode => name.hashCode ^ description.hashCode;

  @override
  String toString() => 'SemanticType(name: $name, description: $description)';
}

/// A semantic type for pixel-based positions.
class PixelPositionType extends SemanticType {
  const PixelPositionType()
      : super(
          name: 'PixelPositionType',
          description: 'Represents a position in pixel coordinates',
        );

  @override
  bool validate(dynamic value) {
    if (value is! Map<String, num>) return false;
    return value.containsKey('x') && value.containsKey('y');
  }

  @override
  Map<String, num> convert(dynamic value) {
    if (value is Map<String, num> && validate(value)) return value;
    throw FormatException('Cannot convert $value to PixelPositionType');
  }
}

/// A semantic type for color values.
class ColorType extends SemanticType {
  const ColorType()
      : super(
          name: 'ColorType',
          description: 'Represents a color value in hex format (#RRGGBB)',
        );

  @override
  bool validate(dynamic value) {
    if (value is! String) return false;
    return RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(value);
  }

  @override
  String convert(dynamic value) {
    if (value is String && validate(value)) return value;
    throw FormatException('Cannot convert $value to ColorType');
  }
}

/// A semantic type for game states.
class GameStateType extends SemanticType {
  const GameStateType()
      : super(
          name: 'GameStateType',
          description:
              'Represents a game state (e.g., playing, paused, game_over)',
        );

  static const validStates = {'playing', 'paused', 'game_over', 'menu'};

  @override
  bool validate(dynamic value) {
    if (value is! String) return false;
    return validStates.contains(value.toLowerCase());
  }

  @override
  String convert(dynamic value) {
    if (value is String && validate(value)) return value.toLowerCase();
    throw FormatException('Cannot convert $value to GameStateType');
  }
}

/// A semantic type for animation states.
class AnimationStateType extends SemanticType {
  const AnimationStateType()
      : super(
          name: 'AnimationStateType',
          description:
              'Represents an animation state (e.g., idle, running, jumping)',
        );

  static const validStates = {'idle', 'running', 'jumping', 'falling'};

  @override
  bool validate(dynamic value) {
    if (value is! String) return false;
    return validStates.contains(value.toLowerCase());
  }

  @override
  String convert(dynamic value) {
    if (value is String && validate(value)) return value.toLowerCase();
    throw FormatException('Cannot convert $value to AnimationStateType');
  }
}

/// A semantic type for 3D vectors.
class Vector3Type extends SemanticType {
  const Vector3Type()
      : super(
          name: 'Vector3Type',
          description: 'Represents a 3D vector with x, y, and z components',
        );

  @override
  bool validate(dynamic value) {
    if (value is! Map<String, num>) return false;
    return value.containsKey('x') &&
        value.containsKey('y') &&
        value.containsKey('z');
  }

  @override
  Map<String, num> convert(dynamic value) {
    if (value is Map<String, num> && validate(value)) return value;
    throw FormatException('Cannot convert $value to Vector3Type');
  }
}

/// A semantic type for intent references.
class IntentReferenceType extends SemanticType {
  const IntentReferenceType()
      : super(
          name: 'IntentReferenceType',
          description: 'Represents a reference to another semantic intent',
        );

  @override
  bool validate(dynamic value) {
    if (value is! String) return false;
    // UUID v4 format
    return RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')
        .hasMatch(value.toLowerCase());
  }

  @override
  String convert(dynamic value) {
    if (value is String && validate(value)) return value.toLowerCase();
    throw FormatException('Cannot convert $value to IntentReferenceType');
  }
}
