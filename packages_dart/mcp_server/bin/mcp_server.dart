import 'package:mcp_server/common_imports.dart';
import 'package:mcp_server/server.dart';
import 'package:mcp_server/tools/echo_tool.dart';

void main(List<String> arguments) async {
  // Get configuration from environment variables or use defaults
  final host = Platform.environment['MCP_HOST'] ?? 'localhost';
  final port = int.tryParse(Platform.environment['MCP_PORT'] ?? '') ?? 3234;

  // Determine transport type from environment variable
  final transportStr =
      Platform.environment['MCP_TRANSPORT']?.toLowerCase() ?? 'sse';
  final transport = switch (transportStr) {
    'stdio' => McpTransport.stdio,
    'sse' => McpTransport.sse,
    _ => McpTransport.websocket,
  };

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
  switch (transport) {
    case McpTransport.websocket:
      print('MCP Server (v$version) listening on ws://$host:$port');
    case McpTransport.sse:
      print(
        'MCP Server (v$version) listening on http://$host:$port (SSE mode)',
      );
    case McpTransport.stdio:
      print('MCP Server (v$version) running in stdio mode');
  }
}
