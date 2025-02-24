import 'dart:async';

/// Represents a token for cancelling operations
class CancellationToken {
  /// Creates a new [CancellationToken]
  CancellationToken() {
    _completer = Completer<void>();
  }

  late final Completer<void> _completer;
  bool _isCancelled = false;

  /// Whether the token has been cancelled
  bool get isCancelled => _isCancelled;

  /// Future that completes when the token is cancelled
  Future<void> get cancelled => _completer.future;

  /// Cancels the operation
  void cancel() {
    if (!_isCancelled) {
      _isCancelled = true;
      _completer.complete();
    }
  }

  /// Throws if the token has been cancelled
  void throwIfCancelled() {
    if (_isCancelled) {
      throw CancellationException();
    }
  }
}

/// Exception thrown when an operation is cancelled
class CancellationException implements Exception {
  @override
  String toString() => 'Operation was cancelled';
}

/// Mixin for adding progress reporting to tools
mixin ProgressReporting {
  /// Reports progress for a long-running operation
  void reportProgress(String message, double progress) {
    // TODO: Implement progress reporting through WebSocket
  }
}
