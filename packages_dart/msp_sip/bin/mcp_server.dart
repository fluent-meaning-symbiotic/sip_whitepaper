import 'package:mcp_sip_dart/common_imports.dart';

Future<void> main() async {
  print('Starting MCP server in stdio mode...');

  await startMcpServer(
    config: const McpServerConfig(
      transport: McpTransport.stdio,
      llmMode: LlmMode.local,
      version: '1.0.0',
    ),
  );
}
