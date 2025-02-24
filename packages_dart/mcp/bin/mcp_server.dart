import 'package:mcp_sip_dart/common_imports.dart';
import 'package:mcp_sip_dart/main.dart';

void main() async {
  await startMcpServer(
    config: const McpServerConfig(
      transport: McpTransport.stdio,
      llmMode: LlmMode.local,
    ),
  );
}
