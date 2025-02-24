import '../common_imports.dart';
import 'cancellation.dart';

/// MCP error codes as defined in the specification
enum McpErrorCode {
  invalidRequest('INVALID_REQUEST'),
  unknownTool('UNKNOWN_TOOL'),
  toolError('TOOL_ERROR'),
  internalError('INTERNAL_ERROR'),
  cancelled('CANCELLED');

  final String code;
  const McpErrorCode(this.code);
}

/// Exception class for MCP-specific errors
class McpException implements Exception {
  final McpErrorCode code;
  final String message;

  McpException(this.code, [this.message = '']);

  Map<String, dynamic> toJson() => {'code': code.code, 'message': message};
}

/// Represents the execution context for MCP requests
class McpContext {
  final String workspaceRoot;
  final Map<String, String> attachments;

  McpContext({required this.workspaceRoot, this.attachments = const {}});

  Map<String, dynamic> toJson() => {
    'workspace_root': workspaceRoot,
    'attachments': attachments,
  };
}

/// Represents an incoming MCP request
class McpRequest {
  final String type;
  final String id;
  final Map<String, dynamic> params;
  final McpContext context;

  McpRequest({
    required this.type,
    required this.id,
    this.params = const {},
    required this.context,
  });

  factory McpRequest.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('type') ||
        !json.containsKey('id') ||
        !json.containsKey('context')) {
      throw McpException(
        McpErrorCode.invalidRequest,
        'Missing required fields',
      );
    }

    final type = json['type'];
    final id = json['id'];
    final contextJson = json['context'];

    if (type is! String ||
        id is! String ||
        contextJson is! Map<String, dynamic>) {
      throw McpException(McpErrorCode.invalidRequest, 'Invalid field types');
    }

    if (!contextJson.containsKey('workspace_root')) {
      throw McpException(
        McpErrorCode.invalidRequest,
        'Missing workspace_root in context',
      );
    }

    final workspaceRoot = contextJson['workspace_root'];
    if (workspaceRoot is! String) {
      throw McpException(
        McpErrorCode.invalidRequest,
        'Invalid workspace_root type',
      );
    }

    final attachmentsJson =
        contextJson['attachments'] as Map<String, dynamic>? ?? {};
    final attachments = Map<String, String>.fromEntries(
      attachmentsJson.entries.map((e) => MapEntry(e.key, e.value.toString())),
    );

    return McpRequest(
      type: type,
      id: id,
      params: (json['params'] as Map<String, dynamic>?) ?? {},
      context: McpContext(
        workspaceRoot: workspaceRoot,
        attachments: attachments,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'params': params,
    'context': context.toJson(),
  };
}

/// Represents an error in an MCP response
class McpError {
  final String code;
  final String message;
  final Map<String, dynamic>? data;
  final String? taskId;

  McpError({required this.code, required this.message, this.data, this.taskId});

  Map<String, dynamic> toJson() {
    final json = {'code': code, 'message': message};
    if (data != null) json['data'] = data;
    if (taskId != null) json['task_id'] = taskId;
    return json;
  }
}

/// Represents a response to an MCP request
class McpResponse {
  final String id;
  final Map<String, dynamic>? result;
  final McpError? error;

  McpResponse({required this.id, this.result, this.error});

  Map<String, dynamic> toJson() {
    final json = {'id': id};
    if (result != null) json['result'] = result;
    if (error != null) json['error'] = error!.toJson();
    return json;
  }
}

/// Abstract base class for MCP tools
abstract class McpTool {
  String get name;
  String get description;
  Map<String, dynamic> get inputSchema;
  Map<String, dynamic> get outputSchema;

  Future<Map<String, dynamic>> execute(
    McpContext context,
    Map<String, dynamic> params,
    CancellationToken cancellationToken,
    void Function(double progress, String message)? onProgress,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'input_schema': inputSchema,
    'output_schema': outputSchema,
  };
}

/// Core protocol implementation for MCP
class McpProtocol with ProgressReporting {
  final String version;
  final McpTransport transport;
  final Map<String, McpTool> _toolRegistry = {};
  final Map<String, CancellationToken> _activeTasks = {};

  McpProtocol({required this.version, required this.transport});

  /// Register a tool with the protocol
  void registerTool(McpTool tool) {
    if (_toolRegistry.containsKey(tool.name)) {
      throw McpException(
        McpErrorCode.toolError,
        'Tool ${tool.name} is already registered',
      );
    }
    _toolRegistry[tool.name] = tool;
  }

  /// Get a tool by name
  McpTool? getTool(String name) => _toolRegistry[name];

  /// List all registered tools
  List<Map<String, dynamic>> listTools() {
    return _toolRegistry.values.map((tool) => tool.toJson()).toList();
  }

  /// Handle an incoming MCP request
  Future<McpResponse> handleRequest(McpRequest request) async {
    try {
      switch (request.type) {
        case 'tools/list':
          return McpResponse(id: request.id, result: {'tools': listTools()});

        case 'tools/info':
          final toolName = request.params['name'];
          if (toolName is! String) {
            throw McpException(
              McpErrorCode.invalidRequest,
              'Tool name must be a string',
            );
          }

          final tool = getTool(toolName);
          if (tool == null) {
            throw McpException(
              McpErrorCode.unknownTool,
              'Tool $toolName not found',
            );
          }

          return McpResponse(id: request.id, result: tool.toJson());

        case 'tools/call':
          final toolName = request.params['name'];
          if (toolName is! String) {
            throw McpException(
              McpErrorCode.invalidRequest,
              'Tool name must be a string',
            );
          }

          final tool = getTool(toolName);
          if (tool == null) {
            throw McpException(
              McpErrorCode.unknownTool,
              'Tool $toolName not found',
            );
          }

          final taskId = const Uuid().v4();
          final cancellationToken = CancellationToken();
          _activeTasks[taskId] = cancellationToken;

          try {
            final result = await tool.execute(
              request.context,
              request.params,
              cancellationToken,
              (progress, message) => reportProgress(taskId, message, progress),
            );

            return McpResponse(
              id: request.id,
              result: {'task_id': taskId, ...result},
            );
          } on CancellationException {
            throw McpException(
              McpErrorCode.cancelled,
              'Task $taskId was cancelled',
            );
          } finally {
            _activeTasks.remove(taskId);
          }

        case 'cancel':
          final taskId = request.params['task_id'];
          if (taskId is! String) {
            throw McpException(
              McpErrorCode.invalidRequest,
              'Task ID must be a string',
            );
          }

          final token = _activeTasks[taskId];
          if (token != null) {
            token.cancel();
          }

          return McpResponse(id: request.id, result: {'cancelled': true});

        default:
          throw McpException(
            McpErrorCode.invalidRequest,
            'Unknown request type: ${request.type}',
          );
      }
    } on McpException catch (e) {
      return McpResponse(
        id: request.id,
        error: McpError(code: e.code.code, message: e.message),
      );
    } catch (e, stackTrace) {
      return McpResponse(
        id: request.id,
        error: McpError(
          code: McpErrorCode.internalError.code,
          message: 'Internal error: $e\n$stackTrace',
        ),
      );
    }
  }
}
