`````markdown:packages_dart/semantic_intent_framework_flutter/README.md
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

# semantic_intent_framework_flutter

Flutter extensions for the `semantic_intent_framework_dart` package, providing seamless integration with Flutter's reactive primitives.

## Features

- **`SemanticValueNotifierAccessor`**:  Provides a `SemanticCommandStateAccessor` implementation based on Flutter's `ValueNotifier`, enabling reactive state management in Flutter applications using the Semantic Intent Paradigm.

## Getting started

To use this package, ensure you have added `semantic_intent_framework_dart` and `semantic_intent_framework_flutter` as dependencies in your `pubspec.yaml` file.

````yaml
dependencies:
  semantic_intent_framework_dart: ^0.0.1 # Replace with the latest version
  semantic_intent_framework_flutter: ^0.0.1 # Replace with the latest version
`````

Then, import the necessary components in your Dart code:

```dart
import 'package:semantic_intent_framework_dart/semantic_intent_framework_dart.dart';
import 'package:semantic_intent_framework_flutter/semantic_intent_framework_flutter.dart';
```

## Usage

Here's a basic example demonstrating the usage of `SemanticValueNotifierAccessor`:

```dart
import 'package:flutter/widgets.dart';
import 'package:semantic_intent_framework_dart/semantic_intent_framework_dart.dart';
import 'package:semantic_intent_framework_flutter/semantic_intent_framework_flutter.dart';

void main() {
  final invoker = SemanticCommandInvoker();
  final counterNotifier = ValueNotifier(0);
  final counterStateAccessor = SemanticValueNotifierAccessor(counterNotifier);

  invoker.registerHandler<IncrementCounterCommand>(
      IncrementCounterHandler(invoker: invoker));

  final command = IncrementCounterCommand(stateAccessor: counterStateAccessor);
  invoker.invoke(command);

  print('Counter value: ${counterStateAccessor.value}'); // Output: Counter value: 1
}

// Define a Semantic Command
class IncrementCounterCommand extends SemanticSingleStateModifierCommand<int> {
  IncrementCounterCommand({required super.stateAccessor});
}

// Define a Semantic Command Handler
class IncrementCounterHandler extends SemanticCommandHandler<IncrementCounterCommand> {
  IncrementCounterHandler({required super.invoker});

  @override
  Future<void> execute(covariant IncrementCounterCommand command) async {
    command.stateAccessor.update(command.stateAccessor.value + 1);
  }
}
```

In this example, `SemanticValueNotifierAccessor` is used to manage a simple counter state. The `IncrementCounterCommand` and `IncrementCounterHandler` demonstrate how to modify this state reactively within the Semantic Intent Framework in a Flutter environment.

## Additional information

This package extends the core `semantic_intent_framework_dart` to provide Flutter-specific utilities. For core framework concepts, contributions, and issue reporting, please refer to the main project repository of `semantic_intent_framework_dart`. Further documentation and examples will be added as both frameworks evolve.
