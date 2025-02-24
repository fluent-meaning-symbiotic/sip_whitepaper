import '../common_imports.dart';

/// Core MCP Protocol implementation
class McpProtocol {
  /// Creates a new MCP protocol instance
  McpProtocol({required this.version, this.transport = McpTransport.websocket});

  final String version;
  final McpTransport transport;
  final _toolRegistry = <String, McpTool>{};

  /// Registers a core MCP tool
  void registerTool(McpTool tool) {
    _toolRegistry[tool.name] = tool;
  }

  /// Gets a registered tool by name
  McpTool? getTool(String name) => _toolRegistry[name];

  /// Lists all available tools
  List<McpTool> listTools() => _toolRegistry.values.toList();

  /// Handles an MCP request
  Future<Map<String, dynamic>> handleRequest(
    Map<String, dynamic> request,
  ) async {
    final type = request['type'] as String?;

    switch (type) {
      case 'tools/list':
        return {'tools': listTools().map((t) => t.toJson()).toList()};
      case 'tools/call':
        final toolName = request['params']['name'] as String;
        final tool = getTool(toolName);
        if (tool == null) {
          throw McpException(
            McpErrorCode.unknownTool,
            'Tool not found: $toolName',
          );
        }
        return tool.execute(request['params']['arguments']);
      default:
        throw McpException(
          McpErrorCode.invalidRequest,
          'Unknown request type: $type',
        );
    }
  }
}

/// Base class for MCP tools
abstract class McpTool {
  McpTool({
    required this.name,
    required this.description,
    required this.inputSchema,
  });

  final String name;
  final String description;
  final Map<String, dynamic> inputSchema;

  /// Executes the tool with given arguments
  Future<Map<String, dynamic>> execute(Map<String, dynamic> arguments);

  /// Converts tool definition to JSON
  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'inputSchema': inputSchema,
  };
}

/// MCP protocol exception
class McpException implements Exception {
  McpException(this.code, this.message);

  final McpErrorCode code;
  final String message;

  Map<String, dynamic> toJson() => {'code': code.code, 'message': message};
}
