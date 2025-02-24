import 'common_imports.dart';

/// Standard MCP error codes
enum McpErrorCode {
  /// Internal server error
  internalError('INTERNAL_ERROR'),

  /// Invalid request format
  invalidRequest('INVALID_REQUEST'),

  /// Unknown tool requested
  unknownTool('UNKNOWN_TOOL'),

  /// Tool execution error
  toolError('TOOL_ERROR'),

  /// Cancellation error
  cancelError('CANCEL_ERROR');

  const McpErrorCode(this.code);
  final String code;
}

/// MCP Server implementation for managing Semantic Intents
class McpServer {
  /// Creates a new MCP server instance
  McpServer({
    required this.host,
    required this.port,
    required this.llmProvider,
    required this.version,
    this.transport = McpTransport.websocket,
  });

  final String host;
  final int port;
  final LlmProvider llmProvider;
  final McpTransport transport;
  final String version;

  HttpServer? _server;
  final _connections = <IOWebSocketChannel>{};
  final _toolRegistry = <String, McpTool>{};
  final _activeTools = <String, McpTool>{};

  /// Starts the MCP server
  Future<void> start() async {
    if (transport == McpTransport.stdio) {
      await _startStdioServer();
    } else {
      await _startWebSocketServer();
    }
  }

  Map<String, dynamic> _createServerInfo() => {
    'version': version,
    'protocol': 'mcp-1.0',
    'tools':
        _toolRegistry.values
            .map(
              (tool) => {
                'name': tool.name,
                'description': tool.description,
                'parameters': tool.parameters,
              },
            )
            .toList(),
  };

  Map<String, dynamic> _createErrorResponse(
    McpErrorCode code,
    String message, [
    Map<String, dynamic>? details,
  ]) => {
    'type': 'error',
    'error': {
      'code': code.code,
      'message': message,
      if (details != null) 'details': details,
    },
  };

  Future<void> _startStdioServer() async {
    stdout.writeln(jsonEncode(_createServerInfo()));

    await for (final line in stdin
        .transform(utf8.decoder)
        .transform(const LineSplitter())) {
      try {
        final data = jsonDecode(line);
        final response = await _handleMessage(data);
        stdout.writeln(jsonEncode(response));
      } catch (e, stack) {
        stdout.writeln(
          jsonEncode(
            _createErrorResponse(McpErrorCode.internalError, e.toString(), {
              'stack': stack.toString(),
            }),
          ),
        );
      }
    }
  }

  Future<void> _startWebSocketServer() async {
    _server = await HttpServer.bind(host, port);
    print('MCP Server listening on ws://$host:$port');

    await for (final request in _server!) {
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        try {
          final socket = await WebSocketTransformer.upgrade(request);
          final channel = IOWebSocketChannel(socket);
          _handleConnection(channel);
        } catch (e, stack) {
          print('Error upgrading connection: $e\n$stack');
          request.response
            ..statusCode = HttpStatus.internalServerError
            ..write('WebSocket upgrade failed')
            ..close();
        }
      } else {
        request.response
          ..statusCode = HttpStatus.badRequest
          ..write('Expected WebSocket upgrade request')
          ..close();
      }
    }
  }

  void _handleConnection(IOWebSocketChannel channel) {
    _connections.add(channel);
    channel.sink.add(jsonEncode(_createServerInfo()));

    channel.stream.listen(
      (message) async {
        try {
          final data = jsonDecode(message as String);
          final response = await _handleMessage(data);
          channel.sink.add(jsonEncode(response));
        } catch (e, stack) {
          channel.sink.add(
            jsonEncode(
              _createErrorResponse(McpErrorCode.internalError, e.toString(), {
                'stack': stack.toString(),
              }),
            ),
          );
        }
      },
      onDone: () {
        _connections.remove(channel);
        channel.sink.close();
      },
      onError: (error, stack) {
        print('WebSocket error: $error\n$stack');
        _connections.remove(channel);
        channel.sink.close();
      },
      cancelOnError: true,
    );
  }

  Future<Map<String, dynamic>> _handleMessage(
    Map<String, dynamic> message,
  ) async {
    if (!message.containsKey('type')) {
      return _createErrorResponse(
        McpErrorCode.invalidRequest,
        'Missing message type',
      );
    }

    final type = message['type'] as String;
    try {
      return switch (type) {
        'tool_call' => await _handleToolCall(message),
        'cancel' => await _handleCancel(message),
        'ping' => {'type': 'pong', 'time': DateTime.now().toIso8601String()},
        _ => _createErrorResponse(
          McpErrorCode.invalidRequest,
          'Unknown message type: $type',
        ),
      };
    } catch (e, stack) {
      return _createErrorResponse(McpErrorCode.internalError, e.toString(), {
        'stack': stack.toString(),
      });
    }
  }

  Future<Map<String, dynamic>> _handleToolCall(
    Map<String, dynamic> message,
  ) async {
    final toolName = message['tool'] as String?;
    if (toolName == null) {
      return _createErrorResponse(
        McpErrorCode.invalidRequest,
        'Missing tool name',
      );
    }

    final tool = _toolRegistry[toolName];
    if (tool == null) {
      return _createErrorResponse(
        McpErrorCode.unknownTool,
        'Unknown tool: $toolName',
      );
    }

    final toolId =
        message['id'] as String? ??
        DateTime.now().microsecondsSinceEpoch.toString();
    _activeTools[toolId] = tool;

    try {
      final params = message['parameters'] as Map<String, dynamic>? ?? {};
      final context = McpContext.fromJson(
        message['context'] as Map<String, dynamic>? ?? {},
      );

      final result = await tool.execute(params, context);
      _activeTools.remove(toolId);

      return {
        'type': 'tool_response',
        'id': toolId,
        'tool': toolName,
        'result': result,
      };
    } catch (e, stack) {
      _activeTools.remove(toolId);
      return _createErrorResponse(
        McpErrorCode.toolError,
        'Tool execution failed: $e',
        {'stack': stack.toString()},
      );
    }
  }

  Future<Map<String, dynamic>> _handleCancel(
    Map<String, dynamic> message,
  ) async {
    final toolId = message['id'] as String?;
    if (toolId == null || !_activeTools.containsKey(toolId)) {
      return _createErrorResponse(
        McpErrorCode.cancelError,
        'Invalid or unknown tool ID: $toolId',
      );
    }

    _activeTools.remove(toolId);
    return {'type': 'cancel_response', 'id': toolId, 'status': 'cancelled'};
  }

  /// Stops the MCP server
  Future<void> stop() async {
    // Close all active WebSocket connections
    await Future.wait(_connections.map((channel) => channel.sink.close()));
    _connections.clear();

    // Cancel all active tools
    _activeTools.clear();

    // Close the HTTP server
    await _server?.close(force: true);
    _server = null;
  }

  /// Registers an MCP tool
  void registerTool(McpTool tool) {
    _toolRegistry[tool.name] = tool;
  }
}

/// Transport mode for MCP server
enum McpTransport {
  /// Use WebSocket transport
  websocket,

  /// Use stdio transport (for IDE integration)
  stdio,
}

/// Base class for MCP tools
abstract class McpTool {
  /// Creates a new MCP tool
  const McpTool();

  /// The name of the tool
  String get name;

  /// The description of the tool
  String get description => '';

  /// The parameters schema for the tool
  Map<String, dynamic> get parameters => {};

  /// Executes the tool with the given parameters and context
  Future<Map<String, dynamic>> execute(
    final Map<String, dynamic> parameters,
    final McpContext context,
  );
}

/// Context for MCP tool execution
class McpContext {
  /// Creates a new MCP context
  const McpContext({this.workspaceRoot = '', this.attachments = const {}});

  /// Creates a context from JSON
  factory McpContext.fromJson(final Map<String, dynamic> json) => McpContext(
    workspaceRoot: json['workspace_root'] as String? ?? '',
    attachments: (json['attachments'] as Map<String, dynamic>? ?? {}).map(
      (final key, final value) => MapEntry(key, base64Decode(value as String)),
    ),
  );

  /// The root directory of the workspace
  final String workspaceRoot;

  /// Map of file attachments
  final Map<String, List<int>> attachments;

  /// Converts the context to JSON
  Map<String, dynamic> toJson() => {
    'workspace_root': workspaceRoot,
    'attachments': attachments.map(
      (final key, final value) => MapEntry(key, base64Encode(value)),
    ),
  };
}
