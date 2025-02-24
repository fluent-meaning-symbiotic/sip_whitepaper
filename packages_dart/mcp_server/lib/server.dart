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

  /// Test stdin stream for testing
  final Stream<String>? _testStdin;

  /// Test stdout sink for testing
  final IOSink? _testStdout;

  /// Creates a new MCP server
  ///
  /// [host] specifies the host to bind to
  /// [port] specifies the port to listen on (for WebSocket transport)
  /// [transport] specifies the transport type (websocket or stdio)
  /// [version] specifies the protocol version
  /// [testStdin] optional test stdin stream for testing
  /// [testStdout] optional test stdout sink for testing
  McpServer({
    required this.host,
    required this.port,
    required this.transport,
    required this.version,
    Stream<String>? testStdin,
    IOSink? testStdout,
  }) : _testStdin = testStdin,
       _testStdout = testStdout,
       _protocol = McpProtocol(version: version, transport: transport);

  /// Register a tool with the server
  void registerTool(McpTool tool) {
    _protocol.registerTool(tool);
  }

  void registerTools(List<McpTool> tools) {
    for (final tool in tools) {
      _protocol.registerTool(tool);
    }
  }

  /// Start the server
  Future<void> start() async {
    developer.log('Starting server', name: 'McpServer');
    switch (transport) {
      case McpTransport.websocket:
        developer.log('Using WebSocket transport', name: 'McpServer');
        await _startWebSocketServer();
      case McpTransport.stdio:
        developer.log('Using stdio transport', name: 'McpServer');
        await _startStdioServer();
    }
    developer.log('Server started', name: 'McpServer');
  }

  /// Stop the server and cleanup resources
  Future<void> stop() async {
    developer.log('Stopping server', name: 'McpServer');

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
    developer.log('Binding WebSocket server to $host:$port', name: 'McpServer');

    try {
      _server = await HttpServer.bind(host, port);
      developer.log('WebSocket server bound successfully', name: 'McpServer');

      // Listen for requests
      _server!.listen(
        (request) async {
          developer.log('Received HTTP request', name: 'McpServer');
          if (WebSocketTransformer.isUpgradeRequest(request)) {
            try {
              developer.log(
                'Upgrading to WebSocket connection',
                name: 'McpServer',
              );
              final socket = await WebSocketTransformer.upgrade(request);
              developer.log(
                'WebSocket connection established',
                name: 'McpServer',
              );
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
            developer.log('Rejecting non-WebSocket request', name: 'McpServer');
            request.response
              ..statusCode = HttpStatus.badRequest
              ..write('This is a WebSocket endpoint')
              ..close();
          }
        },
        onError: (error, stackTrace) {
          developer.log(
            'Error handling HTTP request',
            error: error,
            stackTrace: stackTrace,
            name: 'McpServer',
          );
        },
        cancelOnError: false,
      );

      developer.log(
        'WebSocket server listening on ws://$host:$port',
        name: 'McpServer',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Error starting WebSocket server',
        error: e,
        stackTrace: stackTrace,
        name: 'McpServer',
      );
      rethrow;
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
      (update) {
        final line = json.encode(update);
        developer.log('Sending progress update: $line', name: 'McpServer');
        if (_testStdout != null) {
          _testStdout.writeln(line);
        } else {
          print(line);
        }
      },
      onError: (error, stackTrace) {
        developer.log(
          'Error sending progress update',
          error: error,
          stackTrace: stackTrace,
          name: 'McpServer',
        );
      },
    );

    // Create a completer to track server initialization
    final initCompleter = Completer<void>();

    try {
      final inputStream =
          _testStdin ??
          stdin.transform(utf8.decoder).transform(const LineSplitter());
      _stdioSubscription = inputStream.listen(
        (line) async {
          try {
            developer.log('Received message: $line', name: 'McpServer');
            final message = json.decode(line) as Map<String, dynamic>;
            final request = McpRequest.fromJson(message);
            final response = await _protocol.handleRequest(request);
            final responseJson = json.encode(response.toJson());
            developer.log('Sending response: $responseJson', name: 'McpServer');
            if (_testStdout != null) {
              _testStdout.writeln(responseJson);
            } else {
              print(responseJson);
            }
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
            if (_testStdout != null) {
              _testStdout.writeln(json.encode({'error': error.toJson()}));
            } else {
              print(json.encode({'error': error.toJson()}));
            }
          }
        },
        onError: (e, stackTrace) {
          developer.log(
            'Stdio error',
            error: e,
            stackTrace: stackTrace,
            name: 'McpServer',
          );
          if (!initCompleter.isCompleted) {
            initCompleter.completeError(e, stackTrace);
          }
        },
        onDone: () {
          progressSubscription.cancel();
          developer.log('Stdio connection closed', name: 'McpServer');
        },
        cancelOnError: true,
      );

      // Complete initialization after setting up listeners
      initCompleter.complete();
    } catch (e, stackTrace) {
      developer.log(
        'Error starting stdio server',
        error: e,
        stackTrace: stackTrace,
        name: 'McpServer',
      );
      if (!initCompleter.isCompleted) {
        initCompleter.completeError(e, stackTrace);
      }
      rethrow;
    }

    // Wait for initialization to complete
    await initCompleter.future;
    developer.log('Stdio server started successfully', name: 'McpServer');
  }
}
