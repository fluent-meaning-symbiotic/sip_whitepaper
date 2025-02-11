import 'dart:async';

import 'package:test/test.dart';

import '../../commands/reactive/reactive_command.dart';
import '../handler/reactive_handler.dart';
import 'reactive_invoker.dart';

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MockReactiveCommand &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

class MockReactiveHandler
    extends SemanticReactiveCommandHandler<MockReactiveCommand> {
  final handled = <MockReactiveCommand>[];
  final StreamController<void> _controller = StreamController<void>.broadcast();
  SemanticReactiveCommandStreamName _streamName = MockStreamName.test;

  @override
  SemanticReactiveCommandStreamName get streamName => _streamName;

  set streamName(SemanticReactiveCommandStreamName value) {
    _streamName = value;
  }

  @override
  Future<void> handleCommand(MockReactiveCommand command) async {
    handled.add(command);
    _controller.add(null);
  }

  Stream<void> get onCommandHandled => _controller.stream;

  Future<void> dispose() async {
    await _controller.close();
  }
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
  group('SemanticReactiveCommandInvoker', () {
    late SemanticReactiveCommandInvoker invoker;
    late MockReactiveHandler handler;

    setUp(() {
      invoker = SemanticReactiveCommandInvoker();
      handler = MockReactiveHandler();
    });

    tearDown(() async {
      await handler.dispose();
      await invoker.dispose();
    });

    test('should register handler and handle commands', () async {
      invoker.registerHandler<MockReactiveCommand>(handler);

      const command = MockReactiveCommand(value: 'test');
      invoker.push(MockStreamName.test, command);

      await handler.onCommandHandled.first;
      expect(handler.handled.length, equals(1));
      expect(handler.handled.first.value, equals('test'));
    });

    test('should register transformer and apply to commands', () async {
      invoker.registerHandler<MockReactiveCommand>(handler);
      invoker.addTransformer<MockReactiveCommand>(
          MockStreamName.test, mockTransformer);

      const command = MockReactiveCommand(value: 'test');
      invoker.push(MockStreamName.test, command);

      await handler.onCommandHandled.first;
      expect(handler.handled.length, equals(1));
      expect(handler.handled.first.value, equals('TEST'));
    });

    test('should apply transformers in registration order', () async {
      invoker.registerHandler<MockReactiveCommand>(handler);

      // First transformer: lowercase
      invoker.addTransformer<MockReactiveCommand>(
        MockStreamName.test,
        (stream) => stream
            .map((cmd) => MockReactiveCommand(value: cmd.value.toLowerCase())),
      );

      // Second transformer: uppercase
      invoker.addTransformer<MockReactiveCommand>(
          MockStreamName.test, mockTransformer);

      const command = MockReactiveCommand(value: 'Test');
      invoker.push(MockStreamName.test, command);

      await handler.onCommandHandled.first;
      expect(handler.handled.length, equals(1));
      expect(handler.handled.first.value, equals('TEST'));
    });

    test('should maintain stream isolation', () async {
      final handler1 = MockReactiveHandler();
      final handler2 = MockReactiveHandler()..streamName = MockStreamName.error;

      invoker.registerHandler<MockReactiveCommand>(handler1);
      invoker.registerHandler<MockReactiveCommand>(handler2);

      const command1 = MockReactiveCommand(value: 'test1');
      const command2 = MockReactiveCommand(value: 'test2');

      await Future.wait([
        invoker.push(MockStreamName.test, command1),
        invoker.push(MockStreamName.error, command2),
      ]);

      await Future.wait([
        handler1.onCommandHandled.first,
        handler2.onCommandHandled.first,
      ]);

      expect(handler1.handled.length, equals(1));
      expect(handler1.handled.first.value, equals('test1'));
      expect(handler2.handled.length, equals(1));
      expect(handler2.handled.first.value, equals('test2'));

      await handler1.dispose();
      await handler2.dispose();
    });

    test('should handle transformer errors gracefully', () async {
      invoker.registerHandler<MockReactiveCommand>(handler);
      invoker.addTransformer<MockReactiveCommand>(
          MockStreamName.test, mockErrorTransformer);

      const command = MockReactiveCommand(value: 'test');

      await expectLater(
        () => invoker.push(MockStreamName.test, command),
        throwsA(isA<FormatException>()),
      );

      expect(handler.handled.isEmpty, isTrue);
    });

    test('should apply transformers to specific streams only', () async {
      final handler1 = MockReactiveHandler();
      final handler2 = MockReactiveHandler()..streamName = MockStreamName.error;

      invoker.registerHandler<MockReactiveCommand>(handler1);
      invoker.registerHandler<MockReactiveCommand>(handler2);

      // Register transformer only for test stream
      invoker.addTransformer<MockReactiveCommand>(
          MockStreamName.test, mockTransformer);

      const command = MockReactiveCommand(value: 'test');

      await Future.wait([
        invoker.push(MockStreamName.test, command),
        invoker.push(MockStreamName.error, command),
      ]);

      await Future.wait([
        handler1.onCommandHandled.first,
        handler2.onCommandHandled.first,
      ]);

      expect(handler1.handled.length, equals(1));
      expect(handler1.handled.first.value, equals('TEST'));
      expect(handler2.handled.length, equals(1));
      expect(handler2.handled.first.value, equals('test'));

      await handler1.dispose();
      await handler2.dispose();
    });
  });
}
