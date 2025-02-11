import 'package:flutter/widgets.dart';
import 'package:semantic_intent_framework_dart/semantic_intent_framework_dart.dart';

/// ValueNotifier implementation
class SemanticValueNotifierAccessor<T>
    extends BaseSemanticCommandStateAccessor<T> {
  final ValueNotifier<T> notifier;

  SemanticValueNotifierAccessor(this.notifier);
  T? beforeUpdate;

  @override
  T get value => notifier.value;

  @override
  void update(T newValue) {
    beforeUpdate = notifier.value;
    notifier.value = newValue;
  }

  @override
  void rollback() {
    final v = beforeUpdate;
    if (v != null) notifier.value = v;
  }

  @override
  Stream<T>? get changes => null;
}

mixin SemanticValueNotifierAccessorMixin<T> on ValueNotifier<T> {
  BaseSemanticCommandStateAccessor<T> get accessor =>
      SemanticValueNotifierAccessor<T>(this);
}
