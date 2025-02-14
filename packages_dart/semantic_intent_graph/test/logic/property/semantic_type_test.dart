import 'package:flutter_test/flutter_test.dart';
import 'package:semantic_intent_graph/logic/property/semantic_type.dart';

void main() {
  group('PixelPositionType', () {
    const type = PixelPositionType();

    test('validates correct format', () {
      expect(type.validate({'x': 100, 'y': 200}), isTrue);
    });

    test('rejects invalid format', () {
      expect(type.validate({'x': 100}), isFalse);
      expect(type.validate({'y': 200}), isFalse);
      expect(type.validate({'z': 300}), isFalse);
      expect(type.validate('invalid'), isFalse);
    });

    test('converts valid value', () {
      final value = {'x': 100, 'y': 200};
      expect(type.convert(value), equals(value));
    });

    test('throws on invalid conversion', () {
      expect(() => type.convert({'x': 100}), throwsFormatException);
      expect(() => type.convert('invalid'), throwsFormatException);
    });
  });

  group('ColorType', () {
    const type = ColorType();

    test('validates correct format', () {
      expect(type.validate('#FF0000'), isTrue);
      expect(type.validate('#00FF00'), isTrue);
      expect(type.validate('#0000FF'), isTrue);
    });

    test('rejects invalid format', () {
      expect(type.validate('FF0000'), isFalse);
      expect(type.validate('#FF00'), isFalse);
      expect(type.validate('#FF00000'), isFalse);
      expect(type.validate('#GG0000'), isFalse);
      expect(type.validate(123), isFalse);
    });

    test('converts valid value', () {
      const value = '#FF0000';
      expect(type.convert(value), equals(value));
    });

    test('throws on invalid conversion', () {
      expect(() => type.convert('FF0000'), throwsFormatException);
      expect(() => type.convert(123), throwsFormatException);
    });
  });

  group('GameStateType', () {
    const type = GameStateType();

    test('validates correct states', () {
      expect(type.validate('playing'), isTrue);
      expect(type.validate('PAUSED'), isTrue);
      expect(type.validate('game_over'), isTrue);
      expect(type.validate('menu'), isTrue);
    });

    test('rejects invalid states', () {
      expect(type.validate('invalid'), isFalse);
      expect(type.validate(''), isFalse);
      expect(type.validate(123), isFalse);
    });

    test('converts valid states to lowercase', () {
      expect(type.convert('PLAYING'), equals('playing'));
      expect(type.convert('Paused'), equals('paused'));
    });

    test('throws on invalid conversion', () {
      expect(() => type.convert('invalid'), throwsFormatException);
      expect(() => type.convert(123), throwsFormatException);
    });
  });

  group('AnimationStateType', () {
    const type = AnimationStateType();

    test('validates correct states', () {
      expect(type.validate('idle'), isTrue);
      expect(type.validate('RUNNING'), isTrue);
      expect(type.validate('jumping'), isTrue);
      expect(type.validate('falling'), isTrue);
    });

    test('rejects invalid states', () {
      expect(type.validate('walking'), isFalse);
      expect(type.validate(''), isFalse);
      expect(type.validate(123), isFalse);
    });

    test('converts valid states to lowercase', () {
      expect(type.convert('IDLE'), equals('idle'));
      expect(type.convert('Running'), equals('running'));
    });

    test('throws on invalid conversion', () {
      expect(() => type.convert('walking'), throwsFormatException);
      expect(() => type.convert(123), throwsFormatException);
    });
  });

  group('Vector3Type', () {
    const type = Vector3Type();

    test('validates correct format', () {
      expect(type.validate({'x': 1, 'y': 2, 'z': 3}), isTrue);
    });

    test('rejects invalid format', () {
      expect(type.validate({'x': 1, 'y': 2}), isFalse);
      expect(type.validate({'x': 1, 'z': 3}), isFalse);
      expect(type.validate({'y': 2, 'z': 3}), isFalse);
      expect(type.validate('invalid'), isFalse);
    });

    test('converts valid value', () {
      final value = {'x': 1, 'y': 2, 'z': 3};
      expect(type.convert(value), equals(value));
    });

    test('throws on invalid conversion', () {
      expect(() => type.convert({'x': 1, 'y': 2}), throwsFormatException);
      expect(() => type.convert('invalid'), throwsFormatException);
    });
  });

  group('IntentReferenceType', () {
    const type = IntentReferenceType();

    test('validates correct format', () {
      expect(
        type.validate('123e4567-e89b-42d3-a456-556642440000'),
        isTrue,
      );
    });

    test('rejects invalid format', () {
      expect(type.validate('123e4567'), isFalse);
      expect(type.validate('not-a-uuid'), isFalse);
      expect(type.validate(''), isFalse);
      expect(type.validate(123), isFalse);
    });

    test('converts valid value to lowercase', () {
      const value = '123E4567-E89B-42D3-A456-556642440000';
      expect(
        type.convert(value),
        equals('123e4567-e89b-42d3-a456-556642440000'),
      );
    });

    test('throws on invalid conversion', () {
      expect(() => type.convert('not-a-uuid'), throwsFormatException);
      expect(() => type.convert(123), throwsFormatException);
    });
  });
}
