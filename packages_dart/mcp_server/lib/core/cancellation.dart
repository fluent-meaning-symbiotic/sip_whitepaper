import 'dart:async';

/// Token for handling cancellation of long-running operations
class CancellationToken {
  bool _isCancelled = false;
  final _completer = Completer<void>();

  /// Whether cancellation has been requested
  bool get isCancelled => _isCancelled;

  /// Future that completes when cancellation is requested
  Future<void> get cancelled => _completer.future;

  /// Request cancellation
  void cancel() {
    if (!_isCancelled) {
      _isCancelled = true;
      _completer.complete();
    }
  }

  /// Throws a CancellationException if cancellation has been requested
  void throwIfCancelled() {
    if (_isCancelled) {
      throw CancellationException();
    }
  }
}

/// Exception thrown when an operation is cancelled
class CancellationException implements Exception {
  final String message;
  CancellationException([this.message = 'Operation cancelled']);

  @override
  String toString() => 'CancellationException: $message';
}

/// Mixin for reporting progress of long-running operations
mixin ProgressReporting {
  /// Report progress of a task
  void reportProgress(String taskId, String message, double progress) {
    // This is a placeholder - the actual implementation will be in the McpProtocol class
    // where it can send progress updates to the client
  }
}
