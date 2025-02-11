import 'dart:async';

import 'package:test/test.dart';

import '../../commands/command/command.dart';
import '../handler/handler.dart';
import 'invoker.dart';

// Mock implementations for testing
class MockCommand extends SemanticCommand {
  const MockCommand({this.value = ''});
  final String value;
}

class MockHandler implements SemanticCommandHandler<MockCommand> {
  final handled = <MockCommand>[];
  final completer = Completer<void>();

  @override
  SemanticCommandInvoker get invoker => throw UnimplementedError();

  @override
  Future<void> execute(MockCommand command) async {
    handled.add(command);
    if (!completer.isCompleted) {
      completer.complete();
    }
  }
}

class ErrorMockHandler extends MockHandler {
  @override
  Future<void> execute(MockCommand command) async {
    throw Exception('Test error');
  }
}

void main() {
  group('SemanticCommandInvoker', () {
    late SemanticCommandInvoker invoker;
    late MockHandler handler;

    setUp(() {
      invoker = SemanticCommandInvoker();
      handler = MockHandler();
    });

    test('should register handler and invoke commands', () async {
      invoker.registerHandler(handler);

      const command = MockCommand(value: 'test');
      invoker.invoke(command);

      await handler.completer.future;
      expect(handler.handled.length, equals(1));
      expect(handler.handled.first.value, equals('test'));
    });

    test('should handle multiple commands in order', () async {
      invoker.registerHandler(handler);

      const command1 = MockCommand(value: 'first');
      const command2 = MockCommand(value: 'second');

      invoker.invoke(command1);
      invoker.invoke(command2);

      await handler.completer.future;
      expect(handler.handled.length, equals(2));
      expect(handler.handled[0].value, equals('first'));
      expect(handler.handled[1].value, equals('second'));
    });

    test('should handle errors gracefully', () async {
      final errorHandler = ErrorMockHandler();
      invoker.registerHandler(errorHandler);

      const command = MockCommand(value: 'test');

      // Create a future that will complete when the error is thrown
      final errorFuture = runZonedGuarded(
        () async => invoker.invoke(command),
        (error, stack) {
          expect(error, isA<Exception>());
          expect(error.toString(), contains('Test error'));
        },
      );

      await errorFuture;
    });

    test('should not invoke with wrong handler type', () async {
      final otherHandler = MockHandler();
      invoker.registerHandler(otherHandler);

      const command = MockCommand(value: 'test');
      invoker.invoke(command);

      await Future<void>.delayed(Duration.zero);
      expect(otherHandler.handled.length, equals(1));
    });

    test('should handle concurrent invocations', () async {
      invoker.registerHandler(handler);

      final commands = List.generate(
        5,
        (index) => MockCommand(value: 'test$index'),
      );

      for (final cmd in commands) {
        invoker.invoke(cmd);
      }

      await handler.completer.future;
      expect(handler.handled.length, equals(5));
      for (var i = 0; i < 5; i++) {
        expect(handler.handled[i].value, equals('test$i'));
      }
    });
  });
}
