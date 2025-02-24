import 'package:test/test.dart';

import '../../lib/llm/llm_provider.dart';

void main() {
  group('LocalLlmProvider', () {
    const provider = LocalLlmProvider();

    test('should create SemanticTypeIntent', () async {
      final response = await provider.processMessage(
        'Generate a semantic intent YAML for: point type with x and y coordinates',
        [],
      );

      expect(response.hasError, false);
      expect(response.content, contains('type: SemanticTypeIntent'));
      expect(response.content, contains('name: PointTypeIntent'));

      // Verify semantic properties are inferred
      expect(response.content, contains('semantic_properties:'));
      expect(response.content, contains('x: double'));
      expect(response.content, contains('y: double'));
    });

    test('should generate type implementation', () async {
      const yaml = '''
semantic_intent:
  version: 1
  name: PointTypeIntent
  type: SemanticTypeIntent
  meaning: "A point type with x and y coordinates"
  description: |
    Represents a 2D point with x and y coordinates.
    
  semantic_properties:
    x: double
    y: double
  semantic_validations:
    - "x and y must be finite numbers"
  output_artifacts:
    - lib/types/point_type.dart
  llm_prompts: {}''';

      final response = await provider.processMessage(
        '''Generate code for semantic intent:
$yaml''',
        [],
      );

      expect(response.hasError, false);
      expect(response.content, contains('class PointType'));
      expect(response.content, contains('final double x;'));
      expect(response.content, contains('final double y;'));
      expect(response.content, contains('@override\nString toString()'));
      expect(response.content, contains('@override\nbool operator =='));
      expect(response.content, contains('@override\nint get hashCode'));

      // Verify constructor
      expect(response.content, contains('const PointType({'));
      expect(response.content, contains('required this.x,'));
      expect(response.content, contains('required this.y,'));

      // Verify toString implementation
      expect(response.content, contains("toString() => 'PointType("));
      expect(response.content, contains(r'x: $x'));
      expect(response.content, contains(r'y: $y'));

      // Verify equality implementation
      expect(response.content, contains('x == other.x'));
      expect(response.content, contains('y == other.y'));
    });

    test('should handle type inference', () async {
      final response = await provider.processMessage(
        'Generate a semantic intent YAML for: user data type with name, age, and isActive status',
        [],
      );

      expect(response.hasError, false);
      expect(response.content, contains('type: SemanticTypeIntent'));
      expect(response.content, contains('name: UserDataTypeIntent'));

      // Verify semantic properties are inferred
      expect(response.content, contains('semantic_properties:'));
      expect(response.content, contains('name: string'));
      expect(response.content, contains('age: int'));
      expect(response.content, contains('isActive: bool'));
    });
  });
}
