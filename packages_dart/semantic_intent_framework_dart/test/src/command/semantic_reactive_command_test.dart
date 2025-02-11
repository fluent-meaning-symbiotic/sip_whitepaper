import 'package:semantic_intent_framework_dart/semantic_intent_framework_dart.dart';
import 'package:test/test.dart';

// Test implementation of SemanticReactiveCommandStreamName
enum TestStreamName implements SemanticReactiveCommandStreamName {
  testStream,
  anotherStream
}

// Test implementation of SemanticReactiveCommand
class TestReactiveCommand extends SemanticReactiveCommand {
  const TestReactiveCommand({
    this.data = '',
  });

  final String data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestReactiveCommand &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;
}

void main() {
  group('SemanticReactiveCommand', () {
    test('can be instantiated', () {
      final command = TestReactiveCommand();
      expect(command, isA<SemanticReactiveCommand>());
    });

    test('can be instantiated with data', () {
      const data = 'test data';
      final command = TestReactiveCommand(data: data);
      expect(command.data, equals(data));
    });

    test('implements value equality', () {
      final command1 = TestReactiveCommand(data: 'test');
      final command2 = TestReactiveCommand(data: 'test');
      final command3 = TestReactiveCommand(data: 'different');

      expect(command1, equals(command2));
      expect(command1, isNot(equals(command3)));
    });
  });

  group('SemanticReactiveCommandStreamName', () {
    test('can be used as stream identifier', () {
      expect(
          TestStreamName.testStream, isA<SemanticReactiveCommandStreamName>());
      expect(TestStreamName.testStream, isA<Enum>());
    });

    test('has unique values', () {
      expect(TestStreamName.testStream,
          isNot(equals(TestStreamName.anotherStream)));
    });
  });
}
