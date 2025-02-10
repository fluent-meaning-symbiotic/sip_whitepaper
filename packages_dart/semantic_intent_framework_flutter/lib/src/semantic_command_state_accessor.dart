import 'package:flutter/widgets.dart';
import 'package:semantic_intent_framework_dart/semantic_intent_framework_dart.dart';

/// ValueNotifier implementation
class SemanticValueNotifierAccessor<T> extends SemanticCommandStateAccessor<T> {
  final ValueNotifier<T> notifier;

  const SemanticValueNotifierAccessor(this.notifier);

  @override
  T get value => notifier.value;

  @override
  void update(T newValue) => notifier.value = newValue;

  @override
  Stream<T>? get changes => null;
}
