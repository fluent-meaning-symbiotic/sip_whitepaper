import 'package:mcp/server.dart';
import 'package:mcp/tools/echo_tool.dart';

void main() async {
  // Create and configure the MCP server
  final server = McpServer(
    host: 'localhost',
    port: 8080,
    llmProvider: 'demo',
    llmApiKey: 'demo',
    version: '1.0.0',
  );

  // Register the echo tool
  server.registerTool(EchoTool());

  // Start the server
  print('Starting MCP server...');
  await server.start();
  print('MCP server is running on ws://localhost:8080');

  // The server will continue running until stopped
  // You can test it using a WebSocket client or through stdio
}
