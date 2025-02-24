# Model Context Protocol (MCP) Implementation in Dart

This is a Dart implementation of the Model Context Protocol (MCP), a protocol designed for communication between AI models and development tools.

## Features

- Full MCP 1.0 protocol support
- WebSocket and stdio transport modes
- Tool registration system
- Error handling and cancellation support
- Context and attachment handling

## Getting Started

### Prerequisites

- Dart SDK >=3.0.0

### Installation

Add this package to your project's dependencies:

```yaml
dependencies:
  mcp: ^1.0.0
```

### Usage

```dart
import 'package:mcp/server.dart';

void main() async {
  final server = McpServer(
    host: 'localhost',
    port: 8080,
    llmProvider: 'your_llm_provider',
    llmApiKey: 'your_api_key',
    version: '1.0.0',
  );

  // Register tools
  server.registerTool(YourCustomTool());

  // Start the server
  await server.start();
}
```

## Protocol Details

This implementation follows the MCP 1.0 specification, supporting:

- Tool registration and discovery
- Tool execution
- Cancellation
- Error handling
- Context propagation
- File attachments

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
