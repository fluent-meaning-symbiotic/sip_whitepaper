<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

**Semantic Intent Framework for Dart**

[![pub package](https://img.shields.io/pub/packages/semantic_intent_framework_dart.svg)](https://pub.dev/packages/semantic_intent_framework_dart)
[![Dart CI](https://github.com/your_org/semantic_intent_framework_dart/actions/workflows/dart.yml/badge.svg)](https://github.com/your_org/semantic_intent_framework_dart/actions/workflows/dart.yml)
[![codecov](https://codecov.io/gh/your_org/semantic_intent_framework_dart/branch/main/graph/badge.svg?token=YOUR_TOKEN)](https://codecov.io/gh/your_org/semantic_intent_framework_dart)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

## Description

This Dart package provides a lightweight framework for implementing the Semantic Intent Paradigm in Dart and Flutter applications. It offers a structured approach to building applications by focusing on semantic commands and handlers, promoting clear separation of concerns and improved maintainability. The framework is designed to be extensible and adaptable, supporting both standard command handling and reactive command streams.

## Features

- **Semantic Command Pattern**: Define application logic as immutable semantic commands, enhancing clarity and testability.
- **Command Handlers**: Decouple command execution logic into dedicated handlers, promoting modular design.
- **Command Invoker**: Centralized command dispatch mechanism to invoke handlers and manage command flow.
- **State Management**: Abstract state access through `SemanticCommandStateAccessor`, enabling flexible state management solutions.
- **Reactive Command Streams**: Built-in support for reactive programming with command streams and transformers for handling asynchronous and event-driven scenarios.
- **Extensibility**: Designed to be easily extended and customized to fit various application needs and architectures.
- **Testability**: Encourages test-driven development with clear interfaces and decoupled components.

## Getting started

### Prerequisites

- Dart SDK installed on your machine.
- Flutter SDK installed if you are developing Flutter applications.

### Installation

Add `semantic_intent_framework_dart` as a dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  semantic_intent_framework_dart: latest_version # Replace with the latest version from pub.dev
```

Run `flutter pub get` or `dart pub get` in your terminal to fetch the dependencies.

## Usage

### Basic Command Handling

1.  **Define a Semantic Command**: Create a class that extends `SemanticCommand`.

    ```dart
    class HelloWorldCommand extends SemanticCommand {
      const HelloWorldCommand({required this.code});
      final String code;
    }
    ```

2.  **Implement a Command Handler**: Create a handler class that extends `SemanticCommandHandler<YourCommand>`.

    ```dart
    class HelloWorldHandler extends SemanticCommandHandler<HelloWorldCommand> {
      HelloWorldHandler({required super.invoker});

      @override
      Future<void> execute(HelloWorldCommand command) async {
        print(command.code);
      }
    }
    ```

3.  **Register Handler and Invoke Command**: Use `SemanticCommandInvoker` to register the handler and invoke commands.

    ```dart
    import 'package:semantic_intent_framework_dart/semantic_intent_framework_dart.dart';

    void main() {
      final invoker = SemanticCommandInvoker();
      invoker.registerHandler<HelloWorldCommand>(HelloWorldHandler(invoker: invoker));

      final command = HelloWorldCommand(code: 'Hello, Semantic Intent Framework!');
      invoker.invoke(command);
    }
    ```

### Reactive Command Handling

1.  **Define a Reactive Command**: Create a class that extends `SemanticReactiveCommand`.

    ```dart
    class ReactiveHelloWorldCommand extends SemanticReactiveCommand {
      const ReactiveHelloWorldCommand({required this.code});
      final String code;
    }
    ```

2.  **Implement a Reactive Command Handler**: Create a handler that extends `SemanticReactiveCommandHandler<YourReactiveCommand>` and specify the `streamName`.

    ```dart
    import 'package:semantic_intent_framework_dart/semantic_intent_framework_dart.dart';

    enum Streams implements SemanticReactiveCommandStreamName {
      helloWorldStream,
    }

    class ReactiveHelloWorldHandler extends SemanticReactiveCommandHandler<ReactiveHelloWorldCommand> {
      ReactiveHelloWorldHandler({required super.invoker});

      @override
      SemanticReactiveCommandStreamName get streamName => Streams.helloWorldStream;

      @override
      Future<void> handleCommand(ReactiveHelloWorldCommand command) async {
        print('Reactive Command handled: ${command.code}');
      }
    }
    ```

3.  **Register Reactive Handler and Push Command**: Use `SemanticReactiveCommandInvoker` to register the reactive handler and push commands to the specified stream.

    ```dart
    import 'package:semantic_intent_framework_dart/semantic_intent_framework_dart.dart';

    enum Streams implements SemanticReactiveCommandStreamName {
      helloWorldStream,
    }

    void main() {
      final reactiveInvoker = SemanticReactiveCommandInvoker();
      reactiveInvoker.registerHandler<ReactiveHelloWorldCommand>(ReactiveHelloWorldHandler(invoker: reactiveInvoker));

      final command = ReactiveHelloWorldCommand(code: 'Hello from Reactive Command!');
      reactiveInvoker.push(Streams.helloWorldStream, command);
    }
    ```

### State Management

For commands that need to interact with state, use `SemanticSingleStateAccessorCommand` and `SemanticCommandStateAccessor`.

1.  **Create a State Accessor**: Implement a class that extends `SemanticCommandStateAccessor<StateType>`.

    ```dart
    class CounterStateAccessor extends SemanticCommandStateAccessor<int> {
      int _counter = 0;

      @override
      int get value => _counter;

      @override
      void update(int newValue) {
        _counter = newValue;
      }
    }
    ```

2.  **Use State Accessor in Command and Handler**: Inject the state accessor into your commands and handlers.

    ```dart
    class IncrementCounterCommand extends SemanticSingleStateAccessorCommand<int> {
      const IncrementCounterCommand({required super.stateAccessor});
    }

    class IncrementCounterHandler extends SemanticCommandHandler<IncrementCounterCommand> {
      IncrementCounterHandler({required super.invoker});

      @override
      Future<void> execute(IncrementCounterCommand command) async {
        final currentState = command.stateAccessor.value;
        command.stateAccessor.update(currentState + 1);
        print('Counter incremented to: ${command.stateAccessor.value}');
      }
    }
    ```

## Additional information

This framework is built to facilitate development following the **Semantic Intent Paradigm**, emphasizing clarity, maintainability, and testability in your Dart and Flutter applications.

For more detailed information, examples, and contribution guidelines, please refer to the [project repository](https://github.com/your_org/semantic_intent_framework_dart).

Feel free to contribute to the package by submitting issues, feature requests, or pull requests. Your feedback and contributions are highly appreciated!

License: [MIT](LICENSE)
Copyright 2024 [Your Organization/Name]
