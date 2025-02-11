import 'base_state_accessor.dart';

export 'base_state_accessor.dart';
export 'single_state_accessor.dart';

class SemanticCommandStateAccessor<T>
    extends BaseSemanticCommandStateAccessor<T> {
  SemanticCommandStateAccessor({
    required this.value,
    required void Function(T newValue) update,
  }) : _update = update;
  final void Function(T newValue) _update;
  @override
  final T value;

  @override
  void update(T newValue) => _update(newValue);
}
