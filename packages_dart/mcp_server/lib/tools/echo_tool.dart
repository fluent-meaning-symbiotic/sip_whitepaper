import '../core/cancellation.dart';
import '../core/protocol.dart';

/// A simple tool that echoes back the input message
class EchoTool implements McpTool {
  @override
  String get name => 'echo';

  @override
  String get description => 'Echoes back the input message';

  @override
  Map<String, dynamic> get inputSchema => {
    'type': 'object',
    'properties': {
      'message': {'type': 'string', 'description': 'The message to echo back'},
    },
    'required': ['message'],
  };

  @override
  Map<String, dynamic> get outputSchema => {
    'type': 'object',
    'properties': {
      'message': {'type': 'string', 'description': 'The echoed message'},
    },
    'required': ['message'],
  };

  @override
  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'input_schema': inputSchema,
    'output_schema': outputSchema,
  };

  @override
  Future<Map<String, dynamic>> execute(
    McpContext context,
    Map<String, dynamic> params,
    CancellationToken cancellationToken,
    void Function(double progress, String message)? onProgress,
  ) async {
    // Check for cancellation before starting
    cancellationToken.throwIfCancelled();

    // Report starting progress
    onProgress?.call(0.0, 'Starting echo operation');

    // Simulate some work
    await Future.delayed(const Duration(milliseconds: 100));
    cancellationToken.throwIfCancelled();

    // Report mid progress
    onProgress?.call(0.5, 'Processing message');

    // Get the message from params
    final message = params['message'] as String;

    // Simulate more work
    await Future.delayed(const Duration(milliseconds: 100));
    cancellationToken.throwIfCancelled();

    // Report completion
    onProgress?.call(1.0, 'Echo complete');

    // Return the echoed message
    return {'message': message};
  }
}
