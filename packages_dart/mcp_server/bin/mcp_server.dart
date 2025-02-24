import 'package:mcp_server/common_imports.dart';
import 'package:mcp_server/server.dart';
import 'package:mcp_server/tools/echo_tool.dart';

void main(List<String> arguments) async {
  // Get configuration from environment variables or use defaults
  final host = Platform.environment['MCP_HOST'] ?? 'localhost';
  final port = int.tryParse(Platform.environment['MCP_PORT'] ?? '') ?? 8080;
  final transport =
      String.fromEnvironment(
                'MCP_TRANSPORT',
                defaultValue: 'stdio',
              ).toLowerCase() ==
              'stdio'
          ? McpTransport.stdio
          : McpTransport.websocket;
  final version = Platform.environment['MCP_VERSION'] ?? '1.0';

  // Create and configure the server
  final server = McpServer(
    host: host,
    port: port,
    transport: transport,
    version: version,
  );
  final tools = [EchoTool()]; // Register the example echo tool
  server.registerTools(tools);

  // Start the server
  await server.start();

  // Print startup message
  if (transport == McpTransport.websocket) {
    print('MCP Server (v$version) listening on ws://$host:$port');
  } else {
    print('MCP Server (v$version) running in stdio mode');
  }

  // Automatically list tools on startup
  print(
    json.encode({
      'id': 'init-list',
      'result': {'tools': tools.map((tool) => tool.toJson()).toList()},
    }),
  );
}
