import 'package:semantic_intent_framework_dart/semantic_intent_framework_dart.dart';
import 'package:test/test.dart';

// Test command for handler testing
class TestCommand extends SemanticCommand {
  const TestCommand({this.value = ''});
  final String value;
}

// Mock invoker for testing
class MockCommandInvoker extends SemanticCommandInvoker {
  final commands = <SemanticCommand>[];
  final handlers = <Type, SemanticCommandHandler>{};

  @override
  void invoke<T extends SemanticCommand>(T command) {
    commands.add(command);
    super.invoke(command);
  }

  @override
  void registerHandler<T extends SemanticCommand>(
      SemanticCommandHandler<T> handler) {
    handlers[T] = handler;
    super.registerHandler(handler);
  }
}

// Test handler implementation
class TestHandler extends SemanticCommandHandler<TestCommand> {
  TestHandler({required super.invoker});

  String? lastHandledValue;
  bool wasHandled = false;

  @override
  Future<void> execute(TestCommand command) async {
    lastHandledValue = command.value;
    wasHandled = true;
  }
}

void main() {
  group('SemanticCommandHandler', () {
    late MockCommandInvoker mockInvoker;
    late TestHandler handler;

    setUp(() {
      mockInvoker = MockCommandInvoker();
      handler = TestHandler(invoker: mockInvoker);
      mockInvoker.registerHandler(handler);
    });

    test('can execute commands', () async {
      const command = TestCommand(value: 'test value');
      await handler.execute(command);

      expect(handler.wasHandled, isTrue);
      expect(handler.lastHandledValue, equals('test value'));
    });

    test('handles multiple commands independently', () async {
      const command1 = TestCommand(value: 'first');
      const command2 = TestCommand(value: 'second');

      await handler.execute(command1);
      expect(handler.lastHandledValue, equals('first'));

      await handler.execute(command2);
      expect(handler.lastHandledValue, equals('second'));
    });

    test('handles empty value command', () async {
      const command = TestCommand();
      await handler.execute(command);

      expect(handler.wasHandled, isTrue);
      expect(handler.lastHandledValue, isEmpty);
    });

    test('has access to invoker', () {
      expect(handler.invoker, equals(mockInvoker));
    });

    test('registers handler with invoker', () {
      expect(mockInvoker.handlers[TestCommand], equals(handler));
    });

    test('invoker can invoke commands through handler', () {
      const command = TestCommand(value: 'invoked');
      mockInvoker.invoke(command);

      expect(handler.wasHandled, isTrue);
      expect(handler.lastHandledValue, equals('invoked'));
      expect(mockInvoker.commands, contains(command));
    });
  });
}
