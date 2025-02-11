import 'dart:async';

// ignore: depend_on_referenced_packages
import 'package:test/test.dart';

import '../../commands/reactive/reactive_command.dart';
import '../handler/reactive_command_handler.dart';
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
  MockReactiveHandler({required super.invoker});
  final handled = <MockReactiveCommand>[];
  final _controller = StreamController<MockReactiveCommand>.broadcast();
  SemanticReactiveCommandStreamName _streamName = MockStreamName.test;

  @override
  SemanticReactiveCommandStreamName get streamName => _streamName;

  set streamName(SemanticReactiveCommandStreamName value) {
    _streamName = value;
  }

  @override
  Future<void> execute(MockReactiveCommand command) async {
    handled.add(command);
    _controller.add(command);
  }

  Stream<MockReactiveCommand> get onCommandHandled => _controller.stream;

  Future<void> dispose() async {
    unsubscribe();
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
      handler = MockReactiveHandler(invoker: invoker);
    });

    tearDown(() async {
      await handler.dispose();
      await invoker.dispose();
    });

    test('should register handler and handle commands', () async {
      invoker.registerHandler<MockReactiveCommand>(handler);

      const command = MockReactiveCommand(value: 'test');
      invoker.push(MockStreamName.test, command);

      final received = await handler.onCommandHandled.first;
      expect(handler.handled.length, equals(1));
      expect(handler.handled.first.value, equals('test'));
      expect(received.value, equals('test'));
    });

    test('should register transformer and apply to commands', () async {
      invoker.registerHandler<MockReactiveCommand>(handler);
      invoker.addTransformer<MockReactiveCommand>(
          MockStreamName.test, mockTransformer);

      const command = MockReactiveCommand(value: 'test');
      invoker.push(MockStreamName.test, command);

      final received = await handler.onCommandHandled.first;
      expect(handler.handled.length, equals(1));
      expect(handler.handled.first.value, equals('TEST'));
      expect(received.value, equals('TEST'));
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

      final received = await handler.onCommandHandled.first;
      expect(handler.handled.length, equals(1));
      expect(handler.handled.first.value, equals('TEST'));
      expect(received.value, equals('TEST'));
    });

    test('should maintain stream isolation', () async {
      final handler1 = MockReactiveHandler(invoker: invoker);
      final handler2 = MockReactiveHandler(invoker: invoker)
        ..streamName = MockStreamName.error;

      invoker.registerHandler<MockReactiveCommand>(handler1);
      invoker.registerHandler<MockReactiveCommand>(handler2);

      const command1 = MockReactiveCommand(value: 'test1');
      const command2 = MockReactiveCommand(value: 'test2');

      // Create lists to collect processed commands
      final processed1 = <MockReactiveCommand>[];
      final processed2 = <MockReactiveCommand>[];

      final sub1 = handler1.onCommandHandled.listen(processed1.add);
      final sub2 = handler2.onCommandHandled.listen(processed2.add);

      // Push commands
      invoker.push(MockStreamName.test, command1);
      invoker.push(MockStreamName.error, command2);

      // Wait until both handlers have processed their commands
      while (processed1.isEmpty || processed2.isEmpty) {
        await Future<void>.delayed(Duration.zero);
      }

      await sub1.cancel();
      await sub2.cancel();

      expect(handler1.handled.length, equals(1));
      expect(handler1.handled.first.value, equals('test1'));
      expect(processed1.first.value, equals('test1'));

      expect(handler2.handled.length, equals(1));
      expect(handler2.handled.first.value, equals('test2'));
      expect(processed2.first.value, equals('test2'));

      await handler1.dispose();
      await handler2.dispose();
    });

    test('should handle transformer errors', () async {
      invoker.registerHandler<MockReactiveCommand>(handler);
      invoker.addTransformer<MockReactiveCommand>(
          MockStreamName.test, mockErrorTransformer);

      const command = MockReactiveCommand(value: 'test');

      // Create a completer to track error
      final errorCompleter = Completer<Object>();
      final subscription = handler.onCommandHandled.listen(
        (_) {},
        onError: (error) {
          if (!errorCompleter.isCompleted) {
            errorCompleter.complete(error);
          }
        },
      );

      try {
        invoker.push(MockStreamName.test, command);
        final error = await errorCompleter.future.timeout(
          Duration(seconds: 1),
          onTimeout: () => throw TimeoutException('No error received'),
        );
        expect(error, isA<FormatException>());
        expect(handler.handled.isEmpty, isTrue);
      } finally {
        await subscription.cancel();
      }
    });

    test('should apply transformers to specific streams only', () async {
      final handler1 = MockReactiveHandler(invoker: invoker);
      final handler2 = MockReactiveHandler(invoker: invoker)
        ..streamName = MockStreamName.error;

      invoker.registerHandler<MockReactiveCommand>(handler1);
      invoker.registerHandler<MockReactiveCommand>(handler2);

      // Register transformer only for test stream
      invoker.addTransformer<MockReactiveCommand>(
          MockStreamName.test, mockTransformer);

      const command = MockReactiveCommand(value: 'test');

      // Push to both streams
      invoker.push(MockStreamName.test, command);
      invoker.push(MockStreamName.error, command);

      // Wait for both handlers to process their commands
      final received1 = await handler1.onCommandHandled.first;
      final received2 = await handler2.onCommandHandled.first;

      expect(handler1.handled.length, equals(1));
      expect(handler1.handled.first.value, equals('TEST'));
      expect(received1.value, equals('TEST'));

      expect(handler2.handled.length, equals(1));
      expect(handler2.handled.first.value, equals('test'));
      expect(received2.value, equals('test'));

      await handler1.dispose();
      await handler2.dispose();
    });
  });
}
