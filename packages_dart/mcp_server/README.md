````markdown
# Adding Tools to the MCP Server

This guide explains how to create and integrate new tools with the MCP (Model Context Protocol) server.

## 1. Understanding `McpTool`

The foundation for all tools is the `McpTool` abstract class (defined in `lib/core/protocol.dart`). Any new tool _must_ implement this class. Here's a breakdown:

```dart
abstract class McpTool {
  /// The unique name of the tool.
  String get name;

  /// A human-readable description of the tool.
  String get description;

  /// JSON schema describing the tool's input parameters.
  Map<String, dynamic> get inputSchema;

  /// JSON schema describing the tool's output.
  Map<String, dynamic> get outputSchema;

  /// Executes the tool's logic.
  ///
  /// [context]: The execution context (`McpContext`).
  /// [params]: Input parameters, validated against `inputSchema`.
  /// [cancellationToken]: Allows for cancellation of the tool.
  /// [onProgress]: Callback for reporting progress.
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
```
````

- **`name`**: A unique string identifier for your tool (e.g., `"file_writer"`, `"image_resizer"`). This name is used by clients to call the tool.
- **`description`**: A brief explanation of what your tool does.
- **`inputSchema`**: A JSON schema (as a Dart `Map`) that defines the expected input parameters for your tool. This schema is used for validation. See the JSON Schema documentation ([https://json-schema.org/](https://json-schema.org/)) for details on how to define schemas.
- **`outputSchema`**: A JSON schema describing the structure of the data your tool will return.
- **`execute`**: This is where the core logic of your tool resides.
  - `context`: Provides information about the execution environment (e.g., `workspaceRoot`).
  - `params`: A `Map` containing the input parameters, already validated against your `inputSchema`.
  - `cancellationToken`: An `CancellationToken` object. Your tool _must_ periodically check `cancellationToken.isCancelled` and, if `true`, stop processing and throw a `CancellationException`. This allows clients to cancel long-running operations.
  - `onProgress`: An optional callback function. If provided, your tool _should_ call this function periodically to report progress (a value between `0.0` and `1.0`, and a descriptive message).

## 2. Implementing a New Tool: Example (`FileWriterTool`)

Let's create a tool that writes content to a file.

```dart
import 'package:mcp_server/mcp_server.dart';

class FileWriterTool implements McpTool {
  @override
  String get name => 'file_writer';

  @override
  String get description => 'Writes content to a file.';

  @override
  Map<String, dynamic> get inputSchema => {
        'type': 'object',
        'properties': {
          'path': {
            'type': 'string',
            'description': 'The path to the file.',
          },
          'content': {
            'type': 'string',
            'description': 'The content to write.',
          },
        },
        'required': ['path', 'content'],
      };

  @override
  Map<String, dynamic> get outputSchema => {
        'type': 'object',
        'properties': {
          'success': {
            'type': 'boolean',
            'description': 'Whether the file was written successfully.',
          },
        },
        'required': ['success'],
      };

  @override
  Future<Map<String, dynamic>> execute(
    McpContext context,
    Map<String, dynamic> params,
    CancellationToken cancellationToken,
    void Function(double progress, String message)? onProgress,
  ) async {
    try {
      final filePath = params['path'] as String;
      final content = params['content'] as String;
      final fullPath = '${context.workspaceRoot}/$filePath';

      onProgress?.call(0.1, 'Starting file write...');

      // Simulate some work and check for cancellation
      await Future.delayed(const Duration(milliseconds: 50));
      cancellationToken.throwIfCancelled();

      final file = File(fullPath);
      await file.writeAsString(content);

      onProgress?.call(0.9, 'File write complete.');
      await Future.delayed(const Duration(milliseconds: 50));
      cancellationToken.throwIfCancelled();

      onProgress?.call(1.0, 'Finishing file write.');

      return {'success': true};
    } catch (e) {
      // It's good practice to re-throw CancellationException
      if (e is CancellationException) {
        rethrow;
      }
      // For other errors, return a result indicating failure.
      return {'success': false};
    }
  }
}
```

Key points:

- **Input Validation:** The `inputSchema` ensures that the client provides both `path` and `content` as strings.
- **Workspace Root:** The tool uses `context.workspaceRoot` to construct the full file path, ensuring that file operations are relative to the workspace.
- **Cancellation:** The code checks `cancellationToken.throwIfCancelled()` after potential blocking operations.
- **Progress Reporting:** The `onProgress` callback is used to provide feedback to the client.
- **Error Handling:** The `try...catch` block handles potential errors during file writing. It distinguishes between cancellation and other errors.

## 3. Registering the Tool

To make your tool available to the server, you need to register it in your `main` function (typically in `bin/mcp_server.dart`):

```dart
import 'package:mcp_server/mcp_server.dart';
import 'package:mcp_server/tools/echo_tool.dart';
// Import your new tool
import 'path/to/your/file_writer_tool.dart'; // Adjust the path

void main(List<String> arguments) async {
  // ... (Existing server setup code) ...

  final server = McpServer(
    host: host,
    port: port,
    transport: transport,
    version: version,
  );

  server.registerTool(EchoTool());
  server.registerTool(FileWriterTool()); // Register your new tool

  // ... (Rest of your main function) ...
}
```

## 4. Testing Your Tool

You can test your tool using the stdio interface or by writing integration tests. Here's a simple stdio example:

1.  **Run the server:** `dart bin/mcp_server.dart` (ensure `MCP_TRANSPORT` is set to `stdio` or not set, as it defaults to stdio).
2.  **Send a request (from another terminal or programmatically):**

    ```
    {"type": "tools/call", "id": "1", "params": {"name": "file_writer", "path": "test.txt", "content": "Hello, MCP!"}, "context": {"workspace_root": "/tmp"}}
    ```

    - **Important:** Adjust the `workspace_root` to a valid directory on your system. `/tmp` is commonly used for temporary files.

3.  **Observe the response:**

    ```
    {"id":"1","result":{"success":true}}
    ```

    You should also see a file named `test.txt` created in the `/tmp` directory (or your specified `workspace_root`) with the content "Hello, MCP!".

## 5. JSON Schema Examples

Here are some more JSON schema examples for different input types:

- **String (with length constraints):**

  ```dart
  {
    'type': 'string',
    'minLength': 5,
    'maxLength': 100,
  }
  ```

- **Number (integer):**

  ```dart
  {
    'type': 'integer',
    'minimum': 0,
    'maximum': 100,
  }
  ```

- **Number (floating-point):**

  ```dart
  {
    'type': 'number',
    'minimum': 0.0,
    'maximum': 1.0,
  }
  ```

- **Boolean:**

  ```dart
  {
    'type': 'boolean',
  }
  ```

- **Array of strings:**

  ```dart
  {
    'type': 'array',
    'items': {
      'type': 'string',
    },
    'minItems': 1,
  }
  ```

- **Object with nested properties:**

  ```dart
  {
    'type': 'object',
    'properties': {
      'name': {'type': 'string'},
      'age': {'type': 'integer'},
      'address': {
        'type': 'object',
        'properties': {
          'street': {'type': 'string'},
          'city': {'type': 'string'},
        },
        'required': ['street', 'city'],
      },
    },
    'required': ['name', 'age'],
  }
  ```

This comprehensive guide should enable you to create and integrate a wide variety of tools with your MCP server. Remember to follow best practices for error handling, cancellation, and progress reporting to ensure a robust and responsive system.

```

```
