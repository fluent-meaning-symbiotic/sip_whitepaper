import 'base_state_accessor.dart';

export 'base_state_accessor.dart';
export 'single_state_accessor.dart';

class SemanticCommandStateAccessor<T>
    extends BaseSemanticCommandStateAccessor<T> {
  SemanticCommandStateAccessor({
    required T Function() read,
    required void Function(T newValue) write,
  })  : _read = read,
        _write = write;
  final T Function() _read;
  final void Function(T newValue) _write;
  @override
  T get value => _read();

  @override
  void update(T newValue) => _write(newValue);
}
