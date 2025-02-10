import 'package:flutter/widgets.dart';
import 'package:semantic_intent_framework_dart/semantic_intent_framework_dart.dart';
import 'package:semantic_intent_framework_flutter/semantic_intent_framework_flutter.dart';

void main() {
  final invoker = SemanticCommandInvoker();
  final helloWorldNotifier = ValueNotifier('Hello');
  final helloWorldStateAccessor =
      SemanticValueNotifierAccessor(helloWorldNotifier);

  invoker
      .registerHandler<HelloWorldCommand>(HelloWorldHandler(invoker: invoker));

  final command = HelloWorldCommand(
    code: 'world',
    stateAccessor: helloWorldStateAccessor,
  );
  invoker.invoke(command);
}

class HelloWorldCommand extends SemanticSingleStateAccessorCommand<String> {
  HelloWorldCommand({required this.code, required super.stateAccessor});
  final String code;
}

class HelloWorldHandler extends SemanticCommandHandler<HelloWorldCommand> {
  HelloWorldHandler({required super.invoker});
  @override
  Future<void> execute(covariant HelloWorldCommand command) async {
    command.stateAccessor
        .update('${command.stateAccessor.value} ${command.code}!');
    print(command.stateAccessor.value);
  }
}
