import 'package:semantic_intent_framework_dart/semantic_intent_framework_dart.dart';

enum Streams implements SemanticReactiveCommandStreamName {
  test,
  error,
}

void main() {
  final invoker = SemanticReactiveCommandInvoker();
  invoker
      .registerHandler<HelloWorldCommand>(HelloWorldHandler(invoker: invoker));

  final command = HelloWorldCommand(code: 'hello world');
  invoker.push(Streams.test, command);
}

class HelloWorldCommand extends SemanticReactiveCommand {
  HelloWorldCommand({required this.code});
  final String code;
}

class HelloWorldHandler
    extends SemanticReactiveCommandHandler<HelloWorldCommand> {
  HelloWorldHandler({required super.invoker});
  @override
  Future<void> execute(covariant HelloWorldCommand command) {
    print(command.code);
    return Future.value();
  }

  @override
  Future<void> handleCommand(HelloWorldCommand command) async {
    print(command.code);
  }

  @override
  SemanticReactiveCommandStreamName get streamName => Streams.test;
}
