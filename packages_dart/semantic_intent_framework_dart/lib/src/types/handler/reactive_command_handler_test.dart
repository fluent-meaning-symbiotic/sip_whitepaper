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
  final _commandController = StreamController<TestReactiveCommand>.broadcast();

  @override
  SemanticReactiveCommandStreamName get streamName => TestStreamName.testStream;

  @override
  Future<void> handleCommand(TestReactiveCommand command) async {
    handledValues.add(command.value);
    handledCommands.add(command);
    _commandController.add(command);
  }

  Stream<TestReactiveCommand> get commandStream => _commandController.stream;

  Future<void> dispose() async {
    unsubscribe();
    await _commandController.close();
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
      await handler.dispose();
      await commandController.close();
    });

    test('subscribes to command stream', () async {
      handler.subscribe(commandController.stream);

      const command = TestReactiveCommand(value: 'test value');
      commandController.add(command);

      // Wait for the next command to be processed
      await handler.commandStream.first;

      expect(handler.handledValues, contains('test value'));
      expect(handler.handledCommands, contains(command));
    });

    test('handles multiple commands in sequence', () async {
      handler.subscribe(commandController.stream);

      const commands = [
        TestReactiveCommand(value: 'first'),
        TestReactiveCommand(value: 'second'),
        TestReactiveCommand(value: 'third')
      ];

      // Create a list to collect processed commands
      final processedCommands = <TestReactiveCommand>[];
      final subscription = handler.commandStream.listen(processedCommands.add);

      for (final command in commands) {
        commandController.add(command);
      }

      // Wait until we've processed all commands
      while (processedCommands.length < commands.length) {
        await Future<void>.delayed(Duration.zero);
      }
      await subscription.cancel();

      expect(handler.handledValues, equals(['first', 'second', 'third']));
      expect(handler.handledCommands, equals(commands));
    });

    test('provides correct stream name', () {
      expect(handler.streamName, equals(TestStreamName.testStream));
      expect(handler.streamName, isNot(equals(TestStreamName.anotherStream)));
    });

    test('unsubscribe stops command handling', () async {
      handler.subscribe(commandController.stream);

      const command1 = TestReactiveCommand(value: 'before unsubscribe');
      commandController.add(command1);

      // Wait for the command to be processed
      await handler.commandStream.first;

      handler.unsubscribe();

      const command2 = TestReactiveCommand(value: 'after unsubscribe');
      commandController.add(command2);

      // Give time for any potential processing
      await Future<void>.delayed(Duration.zero);

      expect(handler.handledValues, contains('before unsubscribe'));
      expect(handler.handledValues, isNot(contains('after unsubscribe')));
    });
  });
}
