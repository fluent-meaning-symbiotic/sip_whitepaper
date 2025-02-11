export 'single_state_accessor.dart';

/// Generic state accessor that can work with any state management solution
abstract class SemanticCommandStateAccessor<T> {
  const SemanticCommandStateAccessor();

  /// Get current state value
  T get value;

  /// Update state value
  void update(T newValue);

  /// Optional: return state, before update
  void rollback() => throw UnimplementedError();

  /// Optional: Subscribe to state changes
  Stream<T>? get changes => null;
}
