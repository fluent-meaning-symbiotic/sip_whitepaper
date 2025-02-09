import 'package:semantic_intent_framework_dart/semantic_intent_framework_dart.dart';

void main() {
  final invoker = SemanticCommandInvoker();
  invoker.registerHandler<HelloWorldCommand>(HelloWorldHandler());

  final command = HelloWorldCommand(code: 'hello world');
  invoker.invoke(command);
}

class HelloWorldCommand extends SemanticCommand {
  HelloWorldCommand({required this.code});
  final String code;
}

class HelloWorldHandler implements SemanticCommandHandler<HelloWorldCommand> {
  @override
  Future<void> execute(covariant HelloWorldCommand command) {
    print(command.code);
    return Future.value();
  }
}
