import 'dart:async';

// ignore: depend_on_referenced_packages
import 'package:test/test.dart';

import '../state_accessor/state_accessor.dart';
import 'command.dart';

// Test implementation of SemanticCommand for testing
class TestCommand extends SemanticCommand {
  const TestCommand();
}

// Test implementation of SemanticSingleStateAccessorCommand
class TestStateCommand extends SemanticSingleStateAccessorCommand<String> {
  const TestStateCommand({required super.stateAccessor});
}

// Mock state accessor for testing
class MockStateAccessor extends SemanticCommandStateAccessor<String> {
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

// Mock implementations for testing
class MockCommand extends SemanticCommand {
  const MockCommand({this.value = ''});
  final String value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MockCommand &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

class MockStateCommand extends SemanticSingleStateAccessorCommand<String> {
  const MockStateCommand({required super.stateAccessor, this.value = ''});
  final String value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MockStateCommand &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

void main() {
  group('SemanticCommand', () {
    test('can be instantiated', () {
      final command = TestCommand();
      expect(command, isA<SemanticCommand>());
    });

    test('should be immutable', () {
      const command1 = MockCommand(value: 'test1');
      const command2 = MockCommand(value: 'test1');
      const command3 = MockCommand(value: 'test2');

      expect(command1, equals(command2));
      expect(command1, isNot(equals(command3)));
      expect(command1.value, equals('test1'));
    });
  });

  group('SemanticSingleStateAccessorCommand', () {
    late MockStateAccessor stateAccessor;
    late MockStateCommand command;

    setUp(() {
      stateAccessor = MockStateAccessor();
      command = MockStateCommand(stateAccessor: stateAccessor, value: 'test');
    });

    tearDown(() {
      stateAccessor.dispose();
    });

    test('should provide access to state', () {
      expect(command.stateAccessor, equals(stateAccessor));
      command.stateAccessor.update('new state');
      expect(command.stateAccessor.value, equals('new state'));
    });

    test('should be immutable despite state changes', () {
      final command2 =
          MockStateCommand(stateAccessor: stateAccessor, value: 'test');
      command.stateAccessor.update('changed');

      expect(command, equals(command2));
      expect(command.value, equals('test'));
      expect(command.stateAccessor.value, equals('changed'));
    });

    test('should handle state rollback', () {
      command.stateAccessor.update('initial');
      command.stateAccessor.update('changed');
      command.stateAccessor.rollback();
      expect(command.stateAccessor.value, equals('initial'));
    });

    test('should notify state changes', () async {
      final states = <String>[];
      final subscription = command.stateAccessor.changes!.listen(states.add);

      command.stateAccessor.update('first');
      command.stateAccessor.update('second');

      await Future<void>.delayed(Duration.zero);
      expect(states, equals(['first', 'second']));

      subscription.cancel();
    });
  });
}
