// Common imports and shared types for MCP server
export 'dart:async';
export 'dart:convert';

export 'package:universal_io/io.dart';
export 'package:uuid/uuid.dart';
export 'package:web_socket_channel/web_socket_channel.dart';

/// Transport type for MCP communication
enum McpTransport {
  /// WebSocket transport
  websocket,

  /// Standard input/output transport
  stdio,

  /// Server-Sent Events transport
  sse,
}
