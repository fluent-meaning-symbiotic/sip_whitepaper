import 'package:mcp_sip_dart/core/cancellation.dart';

import 'common_imports.dart';
import 'core/protocol.dart';

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
  }) {
    _protocol = McpProtocol(version: version, transport: transport);
    _tools = <String, McpTool>{};

    // Register standard MCP tools
    _registerStandardTools();

    // Register semantic intent tools
    // TODO: Register semantic intent specific tools
  }

  final String host;
  final int port;
  final LlmProvider llmProvider;
  final McpTransport transport;
  final String version;

  late final McpProtocol _protocol;
  late final Map<String, McpTool> _tools;
  HttpServer? _server;
  final _connections = <IOWebSocketChannel>{};
  final _activeTasks = <String, CancellationToken>{};

  /// Registers a tool with the server
  void registerTool(McpTool tool) {
    _tools[tool.name] = tool;
  }

  /// Gets all registered tools
  Map<String, McpTool> get tools => Map.unmodifiable(_tools);

  /// Gets a tool by name
  McpTool? getTool(String name) => _tools[name];

  /// Starts the MCP server
  Future<void> start() async {
    if (transport == McpTransport.stdio) {
      await _startStdioServer();
    } else {
      await _startWebSocketServer();
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
          _connections.add(channel);

          channel.stream.listen(
            (message) async {
              try {
                final response = await _handleMessage(message as String);
                channel.sink.add(jsonEncode(response));
              } catch (e) {
                channel.sink.add(jsonEncode(_formatError(e)));
              }
            },
            onDone: () => _connections.remove(channel),
            onError: (e) {
              print('WebSocket error: $e');
              _connections.remove(channel);
            },
          );
        } catch (e) {
          print('Failed to establish WebSocket connection: $e');
        }
      } else {
        request.response
          ..statusCode = HttpStatus.badRequest
          ..write('WebSocket upgrade required')
          ..close();
      }
    }
  }

  Future<void> _startStdioServer() async {
    stdin.transform(utf8.decoder).listen((message) async {
      try {
        final response = await _handleMessage(message);
        stdout.write(jsonEncode(response) + '\n');
      } catch (e) {
        stdout.write(jsonEncode(_formatError(e)) + '\n');
      }
    });
  }

  Future<Map<String, dynamic>> _handleMessage(String message) async {
    final request = jsonDecode(message) as Map<String, dynamic>;
    return _protocol.handleRequest(request);
  }

  Map<String, dynamic> _formatError(dynamic error) {
    if (error is McpException) {
      return {'error': error.toJson()};
    }
    return {
      'error': {
        'code': McpErrorCode.internalError.code,
        'message': error.toString(),
      },
    };
  }

  /// Stops the MCP server
  Future<void> stop() async {
    for (final connection in _connections) {
      await connection.sink.close();
    }
    _connections.clear();
    await _server?.close();
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
