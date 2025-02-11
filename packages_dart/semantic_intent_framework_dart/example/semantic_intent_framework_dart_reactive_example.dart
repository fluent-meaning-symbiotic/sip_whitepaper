import 'dart:async';

import 'package:semantic_intent_framework_dart/semantic_intent_framework_dart.dart';

enum Streams implements SemanticReactiveCommandStreamName {
  test,
  error,
}

void main() {
  final invoker = SemanticReactiveCommandInvoker();
  invoker
      .registerHandler<HelloWorldCommand>(HelloWorldHandler(invoker: invoker));
  final transformer =
      StreamTransformer<HelloWorldCommand, HelloWorldCommand>.fromHandlers(
    handleData: (command, sink) {
      sink.add(HelloWorldCommand(code: '${command.code}llo'));
    },
  );
  invoker.addTransformer<HelloWorldCommand>(
    Streams.test,
    (stream) => stream.transform(transformer),
  );

  final command = HelloWorldCommand(code: 'he');
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
  Future<void> execute(HelloWorldCommand command) async {
    print('${command.code} world!');
  }

  @override
  SemanticReactiveCommandStreamName get streamName => Streams.test;
}
