/// Common imports for the MCP package
///
/// This file contains all common imports used throughout the package.
/// It helps reduce code duplication and maintains consistency.

// Dart core imports
export 'dart:async';
export 'dart:convert';
export 'dart:io';

// External package imports
export 'package:web_socket_channel/io.dart';
export 'package:web_socket_channel/web_socket_channel.dart';
export 'package:yaml/yaml.dart';

export 'llm/llm.dart';
export 'main.dart';
// Local exports
export 'server.dart';
export 'tools/tools.dart';

/// Transport types for MCP
enum McpTransport {
  /// WebSocket transport
  websocket,

  /// Standard input/output transport
  stdio,
}

/// LLM provider interface
abstract class LlmProvider {
  Future<String> complete(String prompt);
}
