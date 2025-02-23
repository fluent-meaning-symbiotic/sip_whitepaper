import 'package:sointent/common_imports.dart';
import 'package:sointent/mcp/server.dart';
import 'package:sointent/mcp/tools/create_intent.dart';

/// Starts the MCP server
Future<void> startMcpServer() async {
  final server = McpServer(
    host: 'localhost',
    port: 8080,
    llmProvider: Envs.openAiBaseUrl,
    llmApiKey: Envs.openApiModel,
  );

  // Register tools
  server.registerTool(CreateIntentTool(llmClient: AiClient.instance));

  // TODO: Register other tools
  // server.registerTool(ModifyIntentTool(...));
  // server.registerTool(RefactorIntentsTool(...));
  // server.registerTool(GenerateArtifactsTool(...));
  // server.registerTool(UpdateIntentFromImplementationTool(...));

  await server.start();
}
