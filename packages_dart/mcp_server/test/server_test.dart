import 'package:mcp_server/common_imports.dart';
import 'package:mcp_server/server.dart';
import 'package:mcp_server/tools/echo_tool.dart';
import 'package:test/test.dart';
import 'package:web_socket_channel/io.dart';

/// Helper function to wait for the server to be ready
Future<void> waitForServer(String host, int port) async {
  for (var i = 0; i < 50; i++) {
    try {
      final socket = await WebSocket.connect('ws://$host:$port');
      await socket.close();
      return;
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }
  throw TimeoutException('Server did not start within 5 seconds');
}

const _host = 'localhost';

/// Helper function to get a random available port
Future<int> getAvailablePort() async {
  final server = await ServerSocket.bind(_host, 0);
  final port = server.port;
  await server.close();
  return port;
}

void main() {
  group('WebSocket Server', () {
    late McpServer server;
    late int port;

    setUp(() async {
      port = await getAvailablePort();
      server = McpServer(
        host: _host,
        port: port,
        transport: McpTransport.websocket,
        version: '1.0',
      );
      server.registerTool(EchoTool());
      await server.start();
      await waitForServer(_host, port);
    });

    test('connects and lists tools', () async {
      final channel = IOWebSocketChannel.connect('ws://$_host:$port');
      addTearDown(() async {
        await channel.sink.close();
      });

      // Send tools/list request
      final request = {
        'type': 'tools/list',
        'id': '1',
        'context': {'workspace_root': '/test'},
      };
      channel.sink.add(json.encode(request));

      // Wait for response with timeout
      final response = await channel.stream.first.timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('No response from server'),
      );
      final data = json.decode(response as String) as Map<String, dynamic>;

      expect(data['id'], '1');
      expect(data['result']?['tools'], isA<List>());
      expect(data['result']?['tools'].length, 1);
      expect(data['result']?['tools'].first['name'], 'echo');
    });

    test('executes echo tool with progress updates', () async {
      final channel = IOWebSocketChannel.connect('ws://$_host:$port');
      final messages = <Map<String, dynamic>>[];

      // Listen for all messages
      final subscription = channel.stream.listen((message) {
        messages.add(json.decode(message as String) as Map<String, dynamic>);
      });

      addTearDown(() async {
        await subscription.cancel();
        await channel.sink.close();
      });

      // Send tools/call request
      final request = {
        'type': 'tools/call',
        'id': '1',
        'params': {'name': 'echo', 'message': 'test'},
        'context': {'workspace_root': '/test'},
      };
      channel.sink.add(json.encode(request));

      // Wait for all messages with timeout
      await Future.delayed(const Duration(milliseconds: 500)).timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('Test took too long'),
      );

      // Verify messages
      expect(messages, isNotEmpty);
      expect(
        messages.length,
        greaterThan(3),
      ); // At least 3 progress updates + response

      // Find progress updates
      final progressUpdates =
          messages.where((m) => m['type'] == 'progress').toList();
      expect(progressUpdates.length, 3);
      expect(progressUpdates.first['progress'], 0.0);
      expect(progressUpdates.last['progress'], 1.0);

      // Find final response
      final response = messages.firstWhere((m) => m['id'] == '1');
      expect(response['result']?['message'], 'test');
    });

    tearDown(() async {
      await server.stop();
    });
  });

  group('Stdio Server', () {
    test('communicates via stdio', () async {
      // Create stream controllers for input and output
      final inputController = StreamController<List<int>>();
      final outputController = StreamController<List<int>>();

      // Create a completer to track test completion
      final testCompleter = Completer<void>();

      // Override stdin and stdout for the test
      final testStdin = Stream.fromIterable([]);
      final testStdout = IOSink(outputController.sink);

      // Create a server instance with test streams
      final server = McpServer(
        host: _host,
        port: 0, // Port not used in stdio mode
        transport: McpTransport.stdio,
        version: '1.0',
        testStdin: inputController.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter()),
        testStdout: testStdout,
      );
      server.registerTool(EchoTool());

      try {
        // Start the server
        await server.start();

        // Send tools/list request
        final request = {
          'type': 'tools/list',
          'id': '1',
          'context': {'workspace_root': '/test'},
        };
        inputController.add(utf8.encode('${json.encode(request)}\n'));

        // Wait for response
        final response = await outputController.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .first
            .timeout(
              const Duration(seconds: 5),
              onTimeout: () => throw TimeoutException('No response received'),
            );

        final data = json.decode(response) as Map<String, dynamic>;
        expect(data['id'], '1');
        expect(data['result']?['tools'], isA<List>());
        expect(data['result']?['tools'].length, 1);
        expect(data['result']?['tools'].first['name'], 'echo');
      } finally {
        await inputController.close();
        await outputController.close();
        await server.stop();
      }
    });
  });
}
