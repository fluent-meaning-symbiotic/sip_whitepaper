import 'package:semantic_intent_framework_dart/semantic_intent_framework_dart.dart';
import 'package:test/test.dart';

// Test commands
class TestCommand extends SemanticCommand {
  const TestCommand({this.value = ''});
  final String value;
}

class AnotherTestCommand extends SemanticCommand {
  const AnotherTestCommand({this.data = ''});
  final String data;
}

// Test handlers
class TestHandler extends SemanticCommandHandler<TestCommand> {
  TestHandler({required super.invoker});

  final handledCommands = <TestCommand>[];

  @override
  Future<void> execute(TestCommand command) async {
    handledCommands.add(command);
  }
}

class AnotherTestHandler extends SemanticCommandHandler<AnotherTestCommand> {
  AnotherTestHandler({required super.invoker});

  final handledCommands = <AnotherTestCommand>[];

  @override
  Future<void> execute(AnotherTestCommand command) async {
    handledCommands.add(command);
  }
}

void main() {
  group('SemanticCommandInvoker', () {
    late SemanticCommandInvoker invoker;
    late TestHandler testHandler;
    late AnotherTestHandler anotherTestHandler;

    setUp(() {
      invoker = SemanticCommandInvoker();
      testHandler = TestHandler(invoker: invoker);
      anotherTestHandler = AnotherTestHandler(invoker: invoker);
    });

    test('registers handlers correctly', () {
      invoker.registerHandler(testHandler);
      invoker.registerHandler(anotherTestHandler);

      const testCommand = TestCommand(value: 'test');
      const anotherCommand = AnotherTestCommand(data: 'data');

      invoker.invoke(testCommand);
      invoker.invoke(anotherCommand);

      expect(testHandler.handledCommands, contains(testCommand));
      expect(anotherTestHandler.handledCommands, contains(anotherCommand));
    });

    test('throws exception when no handler is registered', () {
      const command = TestCommand(value: 'test');

      expect(
        () => invoker.invoke(command),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('No handler registered for command type'),
        )),
      );
    });

    test('handlers receive correct commands', () {
      invoker.registerHandler(testHandler);

      const commands = [
        TestCommand(value: 'first'),
        TestCommand(value: 'second'),
        TestCommand(value: 'third'),
      ];

      for (final command in commands) {
        invoker.invoke(command);
      }

      expect(testHandler.handledCommands, equals(commands));
    });

    test('multiple handlers work independently', () {
      invoker.registerHandler(testHandler);
      invoker.registerHandler(anotherTestHandler);

      const testCommands = [
        TestCommand(value: 'test1'),
        TestCommand(value: 'test2'),
      ];

      const anotherCommands = [
        AnotherTestCommand(data: 'data1'),
        AnotherTestCommand(data: 'data2'),
      ];

      for (final command in testCommands) {
        invoker.invoke(command);
      }

      for (final command in anotherCommands) {
        invoker.invoke(command);
      }

      expect(testHandler.handledCommands, equals(testCommands));
      expect(anotherTestHandler.handledCommands, equals(anotherCommands));
    });

    test('last registered handler for type is used', () {
      final firstHandler = TestHandler(invoker: invoker);
      final secondHandler = TestHandler(invoker: invoker);

      invoker.registerHandler(firstHandler);
      invoker.registerHandler(secondHandler);

      const command = TestCommand(value: 'test');
      invoker.invoke(command);

      expect(firstHandler.handledCommands, isEmpty);
      expect(secondHandler.handledCommands, contains(command));
    });
  });
}
