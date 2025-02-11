import 'dart:async';

// ignore: depend_on_referenced_packages
import 'package:test/test.dart';

import 'reactive_command.dart';
import 'transformer_command.dart';

// Mock implementations for testing
enum MockStreamName implements SemanticReactiveCommandStreamName {
  test('test'),
  error('error');

  const MockStreamName(this.name);
  final String name;

  @override
  String toString() => name;
}

class MockReactiveCommand extends SemanticReactiveCommand {
  const MockReactiveCommand({this.value = ''});
  final String value;
}

Stream<T> mockTransformer<T extends SemanticReactiveCommand>(Stream<T> input) {
  return input.map((command) {
    if (command is MockReactiveCommand) {
      return MockReactiveCommand(value: command.value.toUpperCase()) as T;
    }
    return command;
  });
}

Stream<T> mockErrorTransformer<T extends SemanticReactiveCommand>(
    Stream<T> input) {
  return input.map((command) {
    if (command is MockReactiveCommand) {
      throw FormatException('Test error');
    }
    return command;
  });
}

void main() {
  group('SemanticReactiveCommand', () {
    test('should be immutable', () {
      const command1 = MockReactiveCommand(value: 'test1');
      const command2 = MockReactiveCommand(value: 'test1');
      const command3 = MockReactiveCommand(value: 'test2');

      expect(command1, equals(command2));
      expect(command1, isNot(equals(command3)));
      expect(command1.value, equals('test1'));
    });
  });

  group('SemanticReactiveCommandTransformer', () {
    late StreamController<MockReactiveCommand> controller;
    late List<MockReactiveCommand> results;
    late SemanticReactiveCommandTransformer<MockReactiveCommand> transformer;

    setUp(() {
      controller = StreamController<MockReactiveCommand>();
      results = [];
      transformer = mockTransformer;
    });

    tearDown(() {
      controller.close();
    });

    test('should transform stream values', () async {
      final subscription = transformer(controller.stream).listen(results.add);

      controller.add(const MockReactiveCommand(value: 'test'));
      controller.add(const MockReactiveCommand(value: 'command'));

      await Future<void>.delayed(Duration.zero);
      expect(results.length, equals(2));
      expect(results[0].value, equals('TEST'));
      expect(results[1].value, equals('COMMAND'));

      subscription.cancel();
    });

    test('should compose transformers', () async {
      composed(Stream<MockReactiveCommand> input) =>
          mockTransformer(mockTransformer(input));

      final transformed = <MockReactiveCommand>[];
      final subscription = composed(controller.stream).listen(transformed.add);

      controller.add(const MockReactiveCommand(value: 'test'));
      controller.add(const MockReactiveCommand(value: 'command'));

      await Future<void>.delayed(Duration.zero);
      expect(transformed.length, equals(2));
      expect(transformed[0].value, equals('TEST'));
      expect(transformed[1].value, equals('COMMAND'));

      subscription.cancel();
    });

    test('should handle errors gracefully', () async {
      final errorTransformer = mockErrorTransformer<MockReactiveCommand>;
      final errors = <Object>[];

      final subscription = errorTransformer(controller.stream).listen(
        results.add,
        onError: errors.add,
      );

      controller.add(const MockReactiveCommand(value: 'test'));
      controller.add(const MockReactiveCommand(value: 'error'));

      await Future<void>.delayed(Duration.zero);
      expect(results.isEmpty, isTrue);
      expect(errors.length, equals(2));
      expect(errors.first, isA<FormatException>());

      subscription.cancel();
    });
  });
}
