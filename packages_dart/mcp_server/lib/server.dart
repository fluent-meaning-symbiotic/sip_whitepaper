import 'common_imports.dart';
import 'core/protocol.dart';

/// The main MCP server class that handles WebSocket and stdio communication
class McpServer {
  final String host;
  final int port;
  final McpTransport transport;
  final String version;
  final McpProtocol _protocol;

  McpServer({
    required this.host,
    required this.port,
    required this.transport,
    required this.version,
  }) : _protocol = McpProtocol(version: version, transport: transport);

  /// Register a tool with the server
  void registerTool(McpTool tool) {
    _protocol.registerTool(tool);
  }

  /// Start the server
  Future<void> start() async {
    switch (transport) {
      case McpTransport.websocket:
        await _startWebSocketServer();
      case McpTransport.stdio:
        await _startStdioServer();
    }
  }

  /// Start the WebSocket server
  Future<void> _startWebSocketServer() async {
    final server = await HttpServer.bind(host, port);

    await for (final request in server) {
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        try {
          final socket = await WebSocketTransformer.upgrade(request);
          _handleWebSocketConnection(socket);
        } catch (e) {
          print('Error upgrading WebSocket connection: $e');
        }
      } else {
        request.response
          ..statusCode = HttpStatus.badRequest
          ..write('This is a WebSocket endpoint')
          ..close();
      }
    }
  }

  /// Handle a WebSocket connection
  void _handleWebSocketConnection(WebSocket socket) {
    socket.listen(
      (data) async {
        try {
          if (data is! String) {
            throw FormatException('Expected string data');
          }

          final message = json.decode(data) as Map<String, dynamic>;
          final request = McpRequest.fromJson(message);
          final response = await _protocol.handleRequest(request);
          socket.add(json.encode(response.toJson()));
        } catch (e) {
          final error = McpError(
            code: McpErrorCode.internalError.code,
            message: 'Error processing message: $e',
          );
          socket.add(json.encode({'error': error.toJson()}));
        }
      },
      onError: (error) {
        print('WebSocket error: $error');
      },
      onDone: () {
        print('WebSocket connection closed');
      },
    );
  }

  /// Start the stdio server
  Future<void> _startStdioServer() async {
    stdin
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
          (line) async {
            try {
              final message = json.decode(line) as Map<String, dynamic>;
              final request = McpRequest.fromJson(message);
              final response = await _protocol.handleRequest(request);
              stdout.writeln(json.encode(response.toJson()));
            } catch (e) {
              final error = McpError(
                code: McpErrorCode.internalError.code,
                message: 'Error processing message: $e',
              );
              stdout.writeln(json.encode({'error': error.toJson()}));
            }
          },
          onError: (error) {
            print('Stdio error: $error');
          },
          onDone: () {
            print('Stdio connection closed');
          },
        );
  }
}
