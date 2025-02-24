import 'package:mcp_server/common_imports.dart';
import 'package:mcp_server/core/cancellation.dart';
import 'package:mcp_server/core/protocol.dart';
import 'package:test/test.dart';

class TestTool implements McpTool {
  @override
  String get name => 'test';

  @override
  String get description => 'A test tool';

  @override
  Map<String, dynamic> get inputSchema => {
    'type': 'object',
    'properties': {
      'value': {'type': 'string'},
    },
    'required': ['value'],
  };

  @override
  Map<String, dynamic> get outputSchema => {
    'type': 'object',
    'properties': {
      'result': {'type': 'string'},
    },
    'required': ['result'],
  };

  @override
  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'input_schema': inputSchema,
    'output_schema': outputSchema,
  };

  @override
  Future<Map<String, dynamic>> execute(
    McpContext context,
    Map<String, dynamic> params,
    CancellationToken cancellationToken,
    void Function(double progress, String message)? onProgress,
  ) async {
    onProgress?.call(0.0, 'Starting');
    await Future.delayed(const Duration(milliseconds: 10));
    cancellationToken.throwIfCancelled();

    onProgress?.call(0.5, 'Processing');
    final value = params['value'] as String;
    await Future.delayed(const Duration(milliseconds: 10));
    cancellationToken.throwIfCancelled();

    onProgress?.call(1.0, 'Done');
    return {'result': 'Processed: $value'};
  }
}

void main() {
  late McpProtocol protocol;
  late TestTool tool;

  setUp(() {
    protocol = McpProtocol(version: '1.0', transport: McpTransport.websocket);
    tool = TestTool();
    protocol.registerTool(tool);
  });

  test('registers and lists tools', () {
    final tools = protocol.listTools();
    expect(tools.length, 1);
    expect(tools.first['name'], 'test');
  });

  test('handles tools/list request', () async {
    final request = McpRequest(
      type: 'tools/list',
      id: '1',
      context: McpContext(workspaceRoot: '/test'),
    );

    final response = await protocol.handleRequest(request);
    expect(response.error, isNull);
    expect(response.result?['tools'], isA<List>());
    expect(response.result?['tools'].length, 1);
  });

  test('handles tools/info request', () async {
    final request = McpRequest(
      type: 'tools/info',
      id: '1',
      params: {'name': 'test'},
      context: McpContext(workspaceRoot: '/test'),
    );

    final response = await protocol.handleRequest(request);
    expect(response.error, isNull);
    expect(response.result?['name'], 'test');
  });

  test('handles tools/call request', () async {
    final request = McpRequest(
      type: 'tools/call',
      id: '1',
      params: {'name': 'test', 'value': 'hello'},
      context: McpContext(workspaceRoot: '/test'),
    );

    final progressUpdates = <Map<String, dynamic>>[];
    final subscription = protocol.progressUpdates.listen(progressUpdates.add);

    final response = await protocol.handleRequest(request);
    await Future.delayed(
      const Duration(milliseconds: 50),
    ); // Wait for all progress updates
    subscription.cancel();

    expect(response.error, isNull);
    expect(response.result?['result'], 'Processed: hello');
    expect(progressUpdates.length, 3);
    expect(progressUpdates.first['progress'], 0.0);
    expect(progressUpdates.last['progress'], 1.0);
  });

  test('handles cancellation', () async {
    final request = McpRequest(
      type: 'tools/call',
      id: '1',
      params: {'name': 'test', 'value': 'hello'},
      context: McpContext(workspaceRoot: '/test'),
    );

    // Start the tool execution
    final responseFuture = protocol.handleRequest(request);

    // Wait a bit and send cancellation
    await Future.delayed(const Duration(milliseconds: 5));
    final cancelRequest = McpRequest(
      type: 'cancel',
      id: '2',
      params: {'task_id': (await responseFuture).result?['task_id']},
      context: McpContext(workspaceRoot: '/test'),
    );

    final cancelResponse = await protocol.handleRequest(cancelRequest);
    expect(cancelResponse.error, isNull);
    expect(cancelResponse.result?['cancelled'], true);
  });

  test('handles invalid request type', () async {
    final request = McpRequest(
      type: 'invalid',
      id: '1',
      context: McpContext(workspaceRoot: '/test'),
    );

    final response = await protocol.handleRequest(request);
    expect(response.error, isNotNull);
    expect(response.error?.code, McpErrorCode.invalidRequest.code);
  });

  test('handles unknown tool', () async {
    final request = McpRequest(
      type: 'tools/call',
      id: '1',
      params: {'name': 'unknown', 'value': 'hello'},
      context: McpContext(workspaceRoot: '/test'),
    );

    final response = await protocol.handleRequest(request);
    expect(response.error, isNotNull);
    expect(response.error?.code, McpErrorCode.unknownTool.code);
  });
}
