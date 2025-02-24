import 'common_imports.dart';
import 'llm/llm_provider.dart';
import 'server.dart';
import 'tools/create_intent.dart';
import 'tools/generate_artifacts.dart';
import 'tools/infer_property_type.dart';
import 'tools/modify_intent.dart';
import 'tools/refactor_intents.dart';
import 'tools/update_intent.dart';

/// Configuration for the MCP server
class McpServerConfig {
  /// Creates a new [McpServerConfig]
  const McpServerConfig({
    this.host = 'localhost',
    this.port = 8080,
    this.llmMode = LlmMode.local,
    this.llmConfig = const LlmConfig(),
    this.transport = McpTransport.websocket,
    this.version = '1.0.0',
  });

  /// The host to bind to
  final String host;

  /// The port to bind to
  final int port;

  /// The LLM mode to use
  final LlmMode llmMode;

  /// Configuration for the LLM provider
  final LlmConfig llmConfig;

  /// The transport mode to use
  final McpTransport transport;

  /// MCP protocol version
  final String version;
}

/// Configuration for LLM providers
class LlmConfig {
  /// Creates a new [LlmConfig]
  const LlmConfig({this.openAiBaseUrl = '', this.openAiModel = ''});

  /// The base URL for OpenAI/LM Studio
  final String openAiBaseUrl;

  /// The model ID to use
  final String openAiModel;
}

/// The mode for LLM operations
enum LlmMode {
  /// Use local template-based LLM
  local,

  /// Use OpenAI/LM Studio
  remote,
}

/// Starts the MCP server with the given configuration
Future<void> startMcpServer([
  final McpServerConfig config = const McpServerConfig(),
]) async {
  final server = McpServer(
    host: config.host,
    port: config.port,
    llmProvider: config.llmConfig.openAiBaseUrl,
    llmApiKey: config.llmConfig.openAiModel,
    transport: config.transport,
    version: config.version,
  );

  // Create LLM provider based on mode
  final llmProvider = switch (config.llmMode) {
    LlmMode.local => LocalLlmProvider(),
    LlmMode.remote => RemoteLlmProvider(
      client: AiClient(
        baseUrl: config.llmConfig.openAiBaseUrl,
        modelId: config.llmConfig.openAiModel,
      ),
    ),
  };

  // Register all tools with the same LLM provider
  server
    ..registerTool(CreateIntentTool(llmProvider: llmProvider))
    ..registerTool(ModifyIntentTool(llmProvider: llmProvider))
    ..registerTool(RefactorIntentsTool(llmProvider: llmProvider))
    ..registerTool(GenerateArtifactsTool(llmProvider: llmProvider))
    ..registerTool(UpdateIntentFromImplementationTool(llmProvider: llmProvider))
    ..registerTool(InferPropertyTypeTool(llmProvider: llmProvider));

  await server.start();
}
