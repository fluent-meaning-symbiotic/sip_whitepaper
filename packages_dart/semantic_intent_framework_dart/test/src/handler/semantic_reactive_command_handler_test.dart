import 'dart:async';

import 'package:semantic_intent_framework_dart/semantic_intent_framework_dart.dart';
import 'package:test/test.dart';

// Test stream name enum
enum TestStreamName implements SemanticReactiveCommandStreamName {
  testStream,
  anotherStream
}

// Test reactive command
class TestReactiveCommand extends SemanticReactiveCommand {
  const TestReactiveCommand({this.value = ''});
  final String value;
}

// Test reactive handler
class TestReactiveHandler
    extends SemanticReactiveCommandHandler<TestReactiveCommand> {
  final List<String> handledValues = [];
  final List<TestReactiveCommand> handledCommands = [];

  @override
  SemanticReactiveCommandStreamName get streamName => TestStreamName.testStream;

  @override
  Future<void> handleCommand(TestReactiveCommand command) async {
    handledValues.add(command.value);
    handledCommands.add(command);
  }
}

void main() {
  group('SemanticReactiveCommandHandler', () {
    late TestReactiveHandler handler;
    late StreamController<TestReactiveCommand> commandController;

    setUp(() {
      handler = TestReactiveHandler();
      commandController = StreamController<TestReactiveCommand>.broadcast();
    });

    tearDown(() async {
      await commandController.close();
    });

    test('subscribes to command stream', () async {
      final subscription = handler.subscribe(commandController.stream);
      addTearDown(() => subscription.cancel());

      const command = TestReactiveCommand(value: 'test value');
      commandController.add(command);

      // Wait for async processing
      await Future.delayed(Duration.zero);

      expect(handler.handledValues, contains('test value'));
      expect(handler.handledCommands, contains(command));
    });

    test('handles multiple commands in sequence', () async {
      final subscription = handler.subscribe(commandController.stream);
      addTearDown(() => subscription.cancel());

      const commands = [
        TestReactiveCommand(value: 'first'),
        TestReactiveCommand(value: 'second'),
        TestReactiveCommand(value: 'third')
      ];

      for (final command in commands) {
        commandController.add(command);
      }

      // Wait for async processing
      await Future.delayed(Duration.zero);

      expect(handler.handledValues, equals(['first', 'second', 'third']));
      expect(handler.handledCommands, equals(commands));
    });

    test('provides correct stream name', () {
      expect(handler.streamName, equals(TestStreamName.testStream));
      expect(handler.streamName, isNot(equals(TestStreamName.anotherStream)));
    });

    test('subscription can be cancelled', () async {
      final subscription = handler.subscribe(commandController.stream);

      const command1 = TestReactiveCommand(value: 'before cancel');
      commandController.add(command1);

      // Wait for async processing
      await Future.delayed(Duration.zero);

      await subscription.cancel();

      const command2 = TestReactiveCommand(value: 'after cancel');
      commandController.add(command2);

      // Wait for async processing
      await Future.delayed(Duration.zero);

      expect(handler.handledValues, contains('before cancel'));
      expect(handler.handledValues, isNot(contains('after cancel')));
    });
  });
}
