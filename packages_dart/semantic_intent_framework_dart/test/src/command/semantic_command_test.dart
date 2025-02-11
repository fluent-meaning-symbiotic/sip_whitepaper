import 'dart:async';

import 'package:semantic_intent_framework_dart/semantic_intent_framework_dart.dart';
import 'package:test/test.dart';

// Test implementation of SemanticCommand for testing
class TestCommand extends SemanticCommand {
  const TestCommand();
}

// Test implementation of SemanticSingleStateAccessorCommand
class TestStateCommand extends SemanticSingleStateAccessorCommand<String> {
  const TestStateCommand({required super.stateAccessor});
}

// Mock state accessor for testing
class MockStateAccessor implements SemanticCommandStateAccessor<String> {
  String _value = '';
  String? _previousValue;
  final _controller = StreamController<String>.broadcast();

  @override
  String get value => _value;

  @override
  void update(String newValue) {
    _previousValue = _value;
    _value = newValue;
    _controller.add(newValue);
  }

  @override
  void rollback() {
    if (_previousValue != null) {
      _value = _previousValue!;
      _controller.add(_value);
    }
  }

  @override
  Stream<String> get changes => _controller.stream;

  void dispose() {
    _controller.close();
  }
}

void main() {
  group('SemanticCommand', () {
    test('can be instantiated', () {
      final command = TestCommand();
      expect(command, isA<SemanticCommand>());
    });
  });

  group('SemanticSingleStateAccessorCommand', () {
    late MockStateAccessor mockStateAccessor;
    late TestStateCommand command;

    setUp(() {
      mockStateAccessor = MockStateAccessor();
      command = TestStateCommand(stateAccessor: mockStateAccessor);
    });

    tearDown(() {
      mockStateAccessor.dispose();
    });

    test('can be instantiated with state accessor', () {
      expect(command, isA<SemanticSingleStateAccessorCommand<String>>());
      expect(command.stateAccessor, equals(mockStateAccessor));
    });

    test('can access and modify state through accessor', () {
      mockStateAccessor.update('test');
      expect(command.stateAccessor.value, equals('test'));

      command.stateAccessor.update('modified');
      expect(mockStateAccessor.value, equals('modified'));
    });

    test('can rollback to previous state', () {
      mockStateAccessor.update('initial');
      mockStateAccessor.update('modified');
      mockStateAccessor.rollback();
      expect(mockStateAccessor.value, equals('initial'));
    });

    test('can listen to state changes', () async {
      final states = <String>[];
      final subscription = mockStateAccessor.changes.listen(states.add);

      mockStateAccessor.update('first');
      mockStateAccessor.update('second');

      // Wait for async events to complete
      await Future.delayed(Duration.zero);

      expect(states, equals(['first', 'second']));
      subscription.cancel();
    });
  });
}
