import 'dart:async';

import 'semantic_reactive_command.dart';

/// Use this to inject middleware into the stream of commands
/// before they are sent to the handler
typedef SemanticReactiveCommandTransformer<T extends SemanticReactiveCommand>
    = Stream<T> Function(Stream<T> commandStream);
