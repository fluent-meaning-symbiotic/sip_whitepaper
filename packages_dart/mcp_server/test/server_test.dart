import 'package:mcp_server/common_imports.dart';
import 'package:mcp_server/server.dart';
import 'package:mcp_server/tools/echo_tool.dart';
import 'package:test/test.dart';
import 'package:web_socket_channel/io.dart';

void main() {
  group('WebSocket Server', () {
    late McpServer server;
    const port = 8081;

    setUp(() async {
      server = McpServer(
        host: 'localhost',
        port: port,
        transport: McpTransport.websocket,
        version: '1.0',
      );
      server.registerTool(EchoTool());
      await server.start();
    });

    test('connects and lists tools', () async {
      final channel = IOWebSocketChannel.connect('ws://localhost:$port');

      // Send tools/list request
      final request = {
        'type': 'tools/list',
        'id': '1',
        'context': {'workspace_root': '/test'},
      };
      channel.sink.add(json.encode(request));

      // Wait for response
      final response = await channel.stream.first;
      final data = json.decode(response as String) as Map<String, dynamic>;

      expect(data['id'], '1');
      expect(data['result']?['tools'], isA<List>());
      expect(data['result']?['tools'].length, 1);
      expect(data['result']?['tools'].first['name'], 'echo');

      await channel.sink.close();
    });

    test('executes echo tool with progress updates', () async {
      final channel = IOWebSocketChannel.connect('ws://localhost:$port');
      final messages = <Map<String, dynamic>>[];

      // Listen for all messages
      final subscription = channel.stream.listen((message) {
        messages.add(json.decode(message as String) as Map<String, dynamic>);
      });

      // Send tools/call request
      final request = {
        'type': 'tools/call',
        'id': '1',
        'params': {'name': 'echo', 'message': 'test'},
        'context': {'workspace_root': '/test'},
      };
      channel.sink.add(json.encode(request));

      // Wait for all messages (progress updates + final response)
      await Future.delayed(const Duration(milliseconds: 300));
      await channel.sink.close();
      await subscription.cancel();

      // Verify messages
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
      // Start the server process with stdio transport
      final process = await Process.start(
        Platform.resolvedExecutable,
        [Platform.script.resolve('bin/mcp_server.dart').toFilePath()],
        environment: {'MCP_TRANSPORT': 'stdio'},
      );

      try {
        // Send tools/list request
        final request = {
          'type': 'tools/list',
          'id': '1',
          'context': {'workspace_root': '/test'},
        };
        process.stdin.writeln(json.encode(request));

        // Wait for response
        final response =
            await process.stdout
                .transform(utf8.decoder)
                .transform(const LineSplitter())
                .first;
        final data = json.decode(response) as Map<String, dynamic>;

        expect(data['id'], '1');
        expect(data['result']?['tools'], isA<List>());
        expect(data['result']?['tools'].length, 1);
        expect(data['result']?['tools'].first['name'], 'echo');
      } finally {
        process.kill();
      }
    });
  });
}
