import '../server.dart';

/// A simple echo tool that demonstrates the MCP tool implementation
class EchoTool extends McpTool {
  @override
  String get name => 'echo';

  @override
  String get description => 'Echoes back the input message with a timestamp';

  @override
  Map<String, dynamic> get parameters => {
        'message': {
          'type': 'string',
          'description': 'The message to echo back',
          'required': true,
        },
      };

  @override
  Future<Map<String, dynamic>> execute(
    Map<String, dynamic> parameters,
    McpContext context,
  ) async {
    final message = parameters['message'] as String?;
    if (message == null) {
      throw Exception('Message parameter is required');
    }

    return {
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
      'workspace': context.workspaceRoot,
    };
  }
}
