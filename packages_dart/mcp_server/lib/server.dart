import 'dart:developer' as developer;

import 'common_imports.dart';
import 'core/protocol.dart';

/// The main MCP server class that handles WebSocket and stdio communication
class McpServer {
  /// Host to bind to
  final String host;

  /// Port to listen on (for WebSocket transport)
  final int port;

  /// Transport type (websocket or stdio)
  final McpTransport transport;

  /// Protocol version
  final String version;

  /// Protocol implementation
  final McpProtocol _protocol;

  /// WebSocket server instance
  HttpServer? _server;

  /// Active WebSocket connections
  final _connections = <WebSocket>{};

  /// Stdio subscription
  StreamSubscription<String>? _stdioSubscription;

  /// Creates a new MCP server
  ///
  /// [host] specifies the host to bind to
  /// [port] specifies the port to listen on (for WebSocket transport)
  /// [transport] specifies the transport type (websocket or stdio)
  /// [version] specifies the protocol version
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

  /// Stop the server and cleanup resources
  Future<void> stop() async {
    // Stop accepting new connections
    await _server?.close();

    // Close all active connections
    for (final connection in _connections) {
      await connection.close();
    }
    _connections.clear();

    // Cancel stdio subscription
    await _stdioSubscription?.cancel();

    // Cleanup protocol
    await _protocol.dispose();

    developer.log('Server stopped', name: 'McpServer');
  }

  /// Start the WebSocket server
  Future<void> _startWebSocketServer() async {
    _server = await HttpServer.bind(host, port);
    developer.log(
      'WebSocket server listening on ws://$host:$port',
      name: 'McpServer',
    );

    await for (final request in _server!) {
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        try {
          final socket = await WebSocketTransformer.upgrade(request);
          _handleWebSocketConnection(socket);
        } catch (e, stackTrace) {
          developer.log(
            'Error upgrading WebSocket connection',
            error: e,
            stackTrace: stackTrace,
            name: 'McpServer',
          );
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
    _connections.add(socket);

    // Subscribe to progress updates
    final progressSubscription = _protocol.progressUpdates.listen(
      (update) => socket.add(json.encode(update)),
      onError: (error, stackTrace) {
        developer.log(
          'Error sending progress update',
          error: error,
          stackTrace: stackTrace,
          name: 'McpServer',
        );
      },
    );

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
        } catch (e, stackTrace) {
          developer.log(
            'Error processing message',
            error: e,
            stackTrace: stackTrace,
            name: 'McpServer',
          );

          final error = McpError(
            code: McpErrorCode.internalError.code,
            message: 'Error processing message: $e',
          );
          socket.add(json.encode({'error': error.toJson()}));
        }
      },
      onError: (error, stackTrace) {
        developer.log(
          'WebSocket error',
          error: error,
          stackTrace: stackTrace,
          name: 'McpServer',
        );
      },
      onDone: () {
        progressSubscription.cancel();
        _connections.remove(socket);
        developer.log('WebSocket connection closed', name: 'McpServer');
      },
      cancelOnError: true,
    );
  }

  /// Start the stdio server
  Future<void> _startStdioServer() async {
    developer.log('Starting stdio server', name: 'McpServer');

    // Subscribe to progress updates
    final progressSubscription = _protocol.progressUpdates.listen(
      (update) => stdout.writeln(json.encode(update)),
      onError: (error, stackTrace) {
        developer.log(
          'Error sending progress update',
          error: error,
          stackTrace: stackTrace,
          name: 'McpServer',
        );
      },
    );

    _stdioSubscription = stdin
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
          (line) async {
            try {
              final message = json.decode(line) as Map<String, dynamic>;
              final request = McpRequest.fromJson(message);
              final response = await _protocol.handleRequest(request);
              stdout.writeln(json.encode(response.toJson()));
            } catch (e, stackTrace) {
              developer.log(
                'Error processing message',
                error: e,
                stackTrace: stackTrace,
                name: 'McpServer',
              );

              final error = McpError(
                code: McpErrorCode.internalError.code,
                message: 'Error processing message: $e',
              );
              stdout.writeln(json.encode({'error': error.toJson()}));
            }
          },
          onError: (e, stackTrace) {
            developer.log(
              'Stdio error',
              error: e,
              stackTrace: stackTrace,
              name: 'McpServer',
            );
          },
          onDone: () {
            progressSubscription.cancel();
            developer.log('Stdio connection closed', name: 'McpServer');
          },
          cancelOnError: true,
        );
  }
}
