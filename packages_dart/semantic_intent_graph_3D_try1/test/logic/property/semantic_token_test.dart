import 'package:flutter_test/flutter_test.dart';
import 'package:semantic_intent_graph/logic/property/semantic_token.dart';

void main() {
  group('SemanticTokenCategory', () {
    const category = SemanticTokenCategory(
      name: 'test',
      description: 'Test category',
      tokens: {
        'token1': 'value1',
        'token2': 'value2',
      },
    );

    test('hasToken returns correct values', () {
      expect(category.hasToken('token1'), isTrue);
      expect(category.hasToken('token2'), isTrue);
      expect(category.hasToken('token3'), isFalse);
    });

    test('getToken returns correct values', () {
      expect(category.getToken('token1'), equals('value1'));
      expect(category.getToken('token2'), equals('value2'));
      expect(category.getToken('token3'), isNull);
    });

    test('equality works correctly', () {
      const sameCategory = SemanticTokenCategory(
        name: 'test',
        description: 'Test category',
        tokens: {
          'token1': 'value1',
          'token2': 'value2',
        },
      );

      const differentCategory = SemanticTokenCategory(
        name: 'different',
        description: 'Different category',
        tokens: {
          'token1': 'value1',
          'token2': 'value2',
        },
      );

      expect(category, equals(sameCategory));
      expect(category, isNot(equals(differentCategory)));
    });
  });

  group('SemanticTokenRegistry', () {
    late SemanticTokenRegistry registry;

    setUp(() {
      registry = SemanticTokenRegistry();
      registry.registerCategory(
        const SemanticTokenCategory(
          name: 'test',
          description: 'Test category',
          tokens: {
            'token1': 'value1',
            'token2': 'value2',
          },
        ),
      );
    });

    test('registerCategory adds category', () {
      registry.registerCategory(
        const SemanticTokenCategory(
          name: 'another',
          description: 'Another category',
          tokens: {'token3': 'value3'},
        ),
      );

      expect(registry.hasCategory('another'), isTrue);
      expect(registry.getCategory('another')?.name, equals('another'));
    });

    test('getCategory returns correct category', () {
      final category = registry.getCategory('test');
      expect(category?.name, equals('test'));
      expect(category?.description, equals('Test category'));
    });

    test('hasCategory returns correct values', () {
      expect(registry.hasCategory('test'), isTrue);
      expect(registry.hasCategory('nonexistent'), isFalse);
    });

    test('getToken returns correct values', () {
      expect(registry.getToken('test', 'token1'), equals('value1'));
      expect(registry.getToken('test', 'token2'), equals('value2'));
      expect(registry.getToken('test', 'token3'), isNull);
      expect(registry.getToken('nonexistent', 'token1'), isNull);
    });

    test('hasToken returns correct values', () {
      expect(registry.hasToken('test', 'token1'), isTrue);
      expect(registry.hasToken('test', 'token2'), isTrue);
      expect(registry.hasToken('test', 'token3'), isFalse);
      expect(registry.hasToken('nonexistent', 'token1'), isFalse);
    });

    test('categories returns all category names', () {
      expect(registry.categories, equals({'test'}));

      registry.registerCategory(
        const SemanticTokenCategory(
          name: 'another',
          description: 'Another category',
          tokens: {'token3': 'value3'},
        ),
      );

      expect(registry.categories, equals({'test', 'another'}));
    });

    test('getTokens returns all tokens in a category', () {
      expect(
        registry.getTokens('test'),
        equals({
          'token1': 'value1',
          'token2': 'value2',
        }),
      );
      expect(registry.getTokens('nonexistent'), isNull);
    });
  });

  group('DefaultSemanticTokens', () {
    test('createDefaultRegistry creates registry with all default categories',
        () {
      final registry = DefaultSemanticTokens.createDefaultRegistry();

      expect(registry.hasCategory('colors'), isTrue);
      expect(registry.hasCategory('spacing'), isTrue);
      expect(registry.hasCategory('fontSize'), isTrue);
      expect(registry.hasCategory('radius'), isTrue);
      expect(registry.hasCategory('animation'), isTrue);
    });

    test('colors category has correct tokens', () {
      final registry = DefaultSemanticTokens.createDefaultRegistry();
      final tokens = registry.getTokens('colors');

      expect(tokens?['primary'], equals('#007AFF'));
      expect(tokens?['secondary'], equals('#5856D6'));
      expect(tokens?['success'], equals('#34C759'));
      expect(tokens?['error'], equals('#FF3B30'));
    });

    test('spacing category has correct tokens', () {
      final registry = DefaultSemanticTokens.createDefaultRegistry();
      final tokens = registry.getTokens('spacing');

      expect(tokens?['small'], equals(8));
      expect(tokens?['medium'], equals(16));
      expect(tokens?['large'], equals(24));
    });

    test('fontSize category has correct tokens', () {
      final registry = DefaultSemanticTokens.createDefaultRegistry();
      final tokens = registry.getTokens('fontSize');

      expect(tokens?['body'], equals(14));
      expect(tokens?['title'], equals(16));
      expect(tokens?['headline'], equals(20));
    });

    test('radius category has correct tokens', () {
      final registry = DefaultSemanticTokens.createDefaultRegistry();
      final tokens = registry.getTokens('radius');

      expect(tokens?['none'], equals(0));
      expect(tokens?['small'], equals(4));
      expect(tokens?['medium'], equals(8));
      expect(tokens?['circular'], equals(9999));
    });

    test('animation category has correct tokens', () {
      final registry = DefaultSemanticTokens.createDefaultRegistry();
      final tokens = registry.getTokens('animation');

      expect(tokens?['fast'], equals(150));
      expect(tokens?['normal'], equals(250));
      expect(tokens?['slow'], equals(350));
    });
  });
}
