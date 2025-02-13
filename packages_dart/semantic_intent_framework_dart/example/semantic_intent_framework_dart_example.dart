import 'package:semantic_intent_framework_dart/semantic_intent_framework_dart.dart';

void main() {
  final invoker = SemanticCommandInvoker();
  invoker.registerHandler(HelloWorldHandler(invoker: invoker));

  final command = HelloWorldCommand(code: 'hello world');
  invoker.invoke(command);
}

class HelloWorldCommand extends SemanticCommand {
  HelloWorldCommand({required this.code});
  final String code;
}

class HelloWorldHandler extends SemanticCommandHandler<HelloWorldCommand> {
  HelloWorldHandler({required super.invoker});
  @override
  Future<void> execute(covariant HelloWorldCommand command) {
    print(command.code);
    return Future.value();
  }
}
