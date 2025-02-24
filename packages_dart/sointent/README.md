# Model Context Protocol (MCP) for Cursor

The Model Context Protocol (MCP) enables AI agents to interact with your codebase through a standardized interface. This implementation provides a WebSocket-based server that integrates with Cursor's AI capabilities.

## Features

- 🔄 **Bi-directional Communication**: WebSocket-based protocol for real-time interaction
- 🛠️ **Standardized Tools**: Pre-built tools for common operations
- 🧠 **Multiple LLM Modes**: Support for both local and remote LLM providers
- 🤖 **AI-Powered Type Inference**: Smart property type inference using AI
- 📁 **File Management**: Safe file system operations with backups
- ✨ **Semantic Intent Focus**: Built around the Semantic Intent Paradigm

## Getting Started

### Prerequisites

- Dart SDK 3.7 or higher
- Flutter 3.29 or higher (for UI components)
- Cursor IDE with MCP support

### Installation

1. Add the package to your `pubspec.yaml`:

   ```yaml
   dependencies:
     sointent:
       path: path/to/sointent
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

### Running the Server

1. **Local Mode** (Template-based, no external dependencies):

   ```dart
   await startMcpServer(const McpServerConfig(
     llmMode: LlmMode.local,
   ));
   ```

2. **Remote Mode** (OpenAI/LM Studio):
   ```dart
   await startMcpServer(const McpServerConfig(
     llmMode: LlmMode.remote,
     llmConfig: LlmConfig(
       openAiBaseUrl: 'https://api.openai.com/v1',
       openAiModel: 'gpt-4',
     ),
   ));
   ```

## Cursor Integration

1. Open Cursor and navigate to your project
2. Start the MCP server
3. Connect Cursor to the server:
   - Settings > AI > Model Context Protocol
   - Set WebSocket URL: `ws://localhost:8080`

## Available Tools

### 1. Create Intent

Creates new semantic intents from natural language descriptions:

```json
{
  "tool": "create_intent",
  "parameters": {
    "description": "A point type with x and y coordinates",
    "path": "lib/intents/point_type_intent.yaml"
  }
}
```

### 2. Modify Intent

Modifies existing semantic intents:

```json
{
  "tool": "modify_intent",
  "parameters": {
    "path": "lib/intents/point_type_intent.yaml",
    "changes": "Add z coordinate for 3D support"
  }
}
```

### 3. Refactor Intents

Refactors multiple semantic intents:

```json
{
  "tool": "refactor_intents",
  "parameters": {
    "paths": [
      "lib/intents/point_type_intent.yaml",
      "lib/intents/line_type_intent.yaml"
    ],
    "changes": "Update coordinate system to use double precision"
  }
}
```

### 4. Generate Artifacts

Generates implementation artifacts from intents:

```json
{
  "tool": "generate_artifacts",
  "parameters": {
    "path": "lib/intents/point_type_intent.yaml",
    "type": "code"
  }
}
```

### 5. Update Intent from Implementation

Updates intents based on implementation changes:

```json
{
  "tool": "update_intent_from_implementation",
  "parameters": {
    "path": "lib/intents/point_type_intent.yaml",
    "code": "class PointType { ... }"
  }
}
```

### 6. Infer Property Type

Infers semantic types for properties using AI:

```json
{
  "tool": "infer_property_type",
  "parameters": {
    "property_name": "age",
    "description": "User's age in years",
    "context": "Part of a UserProfile type"
  }
}
```

## Best Practices

1. **Semantic Intent First**: Always start with a clear semantic intent before implementation
2. **Version Control**: Keep semantic intents under version control
3. **Validation**: Use semantic validations to ensure intent consistency
4. **Testing**: Generate and maintain tests for all semantic intents
5. **Documentation**: Keep semantic descriptions clear and up-to-date

## Learn More

- [Cursor MCP Documentation](https://docs.cursor.com/context/model-context-protocol)
- [Semantic Intent Paradigm](https://github.com/yourusername/sointent)
- [WebSocket Protocol](https://developer.mozilla.org/en-US/docs/Web/API/WebSocket)

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
