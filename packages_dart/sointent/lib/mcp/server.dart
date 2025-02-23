import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:sointent/common_imports.dart';
import 'package:web_socket_channel/io.dart';

/// MCP Server implementation for managing Semantic Intents
class McpServer {
  /// Creates a new MCP server instance
  McpServer({
    required this.host,
    required this.port,
    required this.llmProvider,
    required this.llmApiKey,
  });

  final String host;
  final int port;
  final String llmProvider;
  final String llmApiKey;

  HttpServer? _server;
  final _connections = <IOWebSocketChannel>{};
  final _toolRegistry = <String, McpTool>{};

  /// Starts the MCP server
  Future<void> start() async {
    _server = await HttpServer.bind(host, port);
    print('MCP Server listening on ws://$host:$port');

    await for (final request in _server!) {
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        try {
          final socket = await WebSocketTransformer.upgrade(request);
          final channel = IOWebSocketChannel(socket);
          _handleConnection(channel);
        } catch (e) {
          print('Error upgrading connection: $e');
        }
      }
    }
  }

  /// Stops the MCP server
  Future<void> stop() async {
    for (final conn in _connections) {
      await conn.sink.close();
    }
    await _server?.close();
    _connections.clear();
  }

  /// Registers an MCP tool
  void registerTool(final McpTool tool) {
    _toolRegistry[tool.name] = tool;
  }

  void _handleConnection(final IOWebSocketChannel channel) {
    _connections.add(channel);

    channel.stream.listen(
      (final message) async {
        try {
          final data = jsonDecode(message as String);
          final response = await _handleMessage(data);
          channel.sink.add(jsonEncode(response));
        } catch (e) {
          channel.sink.add(
            jsonEncode({
              'error': {'message': e.toString(), 'code': 'INTERNAL_ERROR'},
            }),
          );
        }
      },
      onDone: () => _connections.remove(channel),
      onError: (final error) {
        print('WebSocket error: $error');
        _connections.remove(channel);
      },
    );
  }

  Future<Map<String, dynamic>> _handleMessage(
    final Map<String, dynamic> message,
  ) async {
    // Validate message format
    if (!message.containsKey('type')) {
      throw Exception('Missing message type');
    }

    final type = message['type'] as String;
    switch (type) {
      case 'tool_call':
        return _handleToolCall(message);
      case 'cancel':
        return _handleCancel(message);
      default:
        throw Exception('Unknown message type: $type');
    }
  }

  Future<Map<String, dynamic>> _handleToolCall(
    final Map<String, dynamic> message,
  ) async {
    final toolName = message['tool'] as String?;
    if (toolName == null) {
      throw Exception('Missing tool name');
    }

    final tool = _toolRegistry[toolName];
    if (tool == null) {
      throw Exception('Unknown tool: $toolName');
    }

    final params = message['parameters'] as Map<String, dynamic>?;
    final context = McpContext.fromJson(
      message['context'] as Map<String, dynamic>? ?? {},
    );

    try {
      final result = await tool.execute(params ?? {}, context);
      return {'type': 'tool_response', 'tool': toolName, 'result': result};
    } catch (e) {
      return {
        'type': 'tool_response',
        'tool': toolName,
        'error': {'message': e.toString(), 'code': 'TOOL_ERROR'},
      };
    }
  }

  Future<Map<String, dynamic>> _handleCancel(
    final Map<String, dynamic> message,
  ) async {
    // TODO: Implement cancellation
    return {'type': 'cancel_response', 'status': 'ok'};
  }
}

/// Base class for MCP tools
abstract class McpTool {
  /// Creates a new MCP tool
  const McpTool();

  /// The name of the tool
  String get name;

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
