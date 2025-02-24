Okay, here's a detailed, step-by-step specification for creating a Dart-based MCP server, focusing on the core protocol implementation without any semantic intent-specific logic. This is written as a task list for another AI agent, minimizing the need for external context.

**Overall Goal:** Implement a fully compliant MCP 1.0 server in Dart, handling WebSocket and stdio transports, tool registration, request/response processing, cancellation, and error handling.

**Task List:**

1.  **Project Setup (if not already done):**

    - Create a new Dart project: `dart create -t console-full mcp_server`
    - Add necessary dependencies to `pubspec.yaml`:
      - `web_socket_channel`: For WebSocket communication.
      - `universal_io`: For cross-platform IO (WebSocket and stdio).
      - `uuid`: For generating unique task IDs. (Add this dependency)

2.  **Core Data Structures (Review and Complete):**

    - **`McpTransport` (enum):** Ensure it exists with `websocket` and `stdio` values. (`lib/common_imports.dart`)
    - **`McpErrorCode` (enum):** Ensure it includes all standard error codes as defined in the MCP specification (e.g., `INVALID_REQUEST`, `UNKNOWN_TOOL`, `TOOL_ERROR`, `INTERNAL_ERROR`, `CANCELLED`). (`lib/server.dart`)
    - **`McpException` (class):** Should take an `McpErrorCode` and an optional message. Implement a `toJson()` method to serialize the error for the MCP response. (`lib/core/protocol.dart`)
    - **`McpRequest` (class):** Represent an incoming MCP request. Include fields for:
      - `type` (String): The request type (e.g., "tools/list", "tools/info", "tools/call", "cancel").
      - `id` (String): The request ID.
      - `params` (Map<String, dynamic>): Parameters for the request (can be empty).
      - `context` (`McpContext`): The context object.
    - **`McpResponse` (class):** Represent a response to an MCP request. Include fields for:
      - `id` (String): The ID of the request being responded to.
      - `result` (Map<String, dynamic>?): The result data (can be null for errors or void responses).
      - `error` (`McpError`?): An error object (if an error occurred).
    - **`McpError` (class):** Represents an error in the MCP response.
      - `code` (String): The error code (from `McpErrorCode`).
      - `message` (String): A human-readable error message.
      - `data` (Map<String, dynamic>?): Optional additional error data.
      - `task_id` (String?): The ID of the task, if the error is related to a specific task.
    - **`McpContext` (class):** Represent the execution context. (`lib/server.dart`)
      - `workspace_root` (String): The root directory of the workspace.
      - `attachments` (Map<String, String>): A map of attachment names to base64-encoded content.
    - **`McpTool` (abstract class):** (`lib/core/protocol.dart`)
      - `name` (String): The unique name of the tool.
      - `description` (String): A description of the tool.
      - `inputSchema` (Map<String, dynamic>): A JSON schema describing the expected input parameters.
      - `outputSchema` (Map<String, dynamic>): A JSON schema describing the output of the tool.
      - `execute(McpContext context, Map<String, dynamic> params, CancellationToken cancellationToken, void Function(double, String)? onProgress)` (abstract method): The method that executes the tool. It should:
        - Take the `McpContext`, input parameters, a `CancellationToken`, and an optional `onProgress` callback.
        - Return a `Future<Map<String, dynamic>>` representing the tool's result.
        - Regularly check `cancellationToken.isCancelled` and throw a `CancellationException` if it's true.
        - Call `onProgress` to report progress (if provided).
      - `toJson()` (method): Serializes the tool's metadata (name, description, inputSchema, outputSchema) to a JSON-compatible Map.
    - **`CancellationToken` (class):** (`lib/core/cancellation.dart`)
      - `isCancelled` (bool): Indicates whether cancellation has been requested.
      - `cancel()` (method): Requests cancellation.
      - `cancelled` (Future): A future that completes when cancellation is requested.
      - `throwIfCancelled()`: Throws a `CancellationException` if cancelled.
    - **`ProgressReporting` (mixin):** (`lib/core/cancellation.dart`) - _Modify to accept `task_id`_
      - `reportProgress(String taskId, String message, double progress)`: Reports progress.

3.  **`McpProtocol` Class (`lib/core/protocol.dart`):**

    - **Constructor:** Takes the MCP `version` (String) and `transport` (`McpTransport`).
    - **`_toolRegistry` (Map<String, McpTool>):** Stores registered tools.
    - **`registerTool(McpTool tool)`:** Registers a tool in the `_toolRegistry`.
    - **`getTool(String name)`:** Retrieves a tool by name.
    - **`listTools()`:** Returns a list of registered tools (as their JSON representations).
    - **`handleRequest(McpRequest request)`:** This is the core request handler. It should:
      1.  Validate the `request` based on its `type`. Use JSON schema validation for `params` against the tool's `inputSchema` when applicable.
      2.  Dispatch based on `request.type`:
          - **`tools/list`:** Return a list of registered tools (using `listTools()`).
          - **`tools/info`:**
            - Get the tool name from `request.params["name"]`.
            - If the tool exists, return its JSON representation (using `tool.toJson()`).
            - If the tool doesn't exist, return an `McpError` with `UNKNOWN_TOOL`.
          - **`tools/call`:**
            - Get the tool name from `request.params["name"]`.
            - If the tool exists:
              - Generate a unique `task_id` (using `Uuid().v4()`).
              - Create a `CancellationToken`.
              - Store the `CancellationToken` in a `_activeTasks` map (keyed by `task_id`).
              - Call the tool's `execute` method, passing the `McpContext`, `request.params`, the `CancellationToken`, and a progress reporting callback.
              - Wrap the `execute` call in a `Future` to ensure asynchronous execution.
              - When the `execute` future completes (either successfully or with an error):
                - Remove the `CancellationToken` from `_activeTasks`.
                - Return an `McpResponse` with the result or error, including the `task_id`.
              - If the tool throws a `CancellationException`, return an `McpError` with code `CANCELLED` and the `task_id`.
            - If the tool doesn't exist, return an `McpError` with `UNKNOWN_TOOL`.
          - **`cancel`:**
            - Get the `task_id` from `request.params["task_id"]`.
            - If the `task_id` exists in `_activeTasks`, call `cancel()` on the corresponding `CancellationToken`.
            - Return an `McpResponse` acknowledging the cancellation request (even if the task wasn't found).
      3.  If the `request.type` is unknown, return an `McpError` with `INVALID_REQUEST`.
      4.  Catch any exceptions during request processing and return an appropriate `McpError` (including `INTERNAL_ERROR` for unexpected errors).
    - **`_activeTasks` (Map<String, CancellationToken>):** Stores active cancellation tokens, keyed by `task_id`.

4.  **`McpServer` Class (`lib/server.dart`):**

    - **Constructor:** Takes `host`, `port`, `transport`, `version`, and an `LlmProvider`.
    - **`_protocol` (`McpProtocol`):** An instance of the `McpProtocol` class.
    - **`start()`:** Starts the server (either WebSocket or stdio).
      - **WebSocket:**
        - Use `HttpServer.bind` to create an HTTP server.
        - Use `WebSocketTransformer.upgrade` to handle WebSocket connections.
        - Use `IOWebSocketChannel` to manage the WebSocket connection.
        - Listen for incoming messages on the WebSocket.
        - For each message:
          1.  **Decode the Message:** Implement MCP's message framing (length-prefixed JSON). Read the length, then read that many bytes as the JSON payload.
          2.  Deserialize the JSON into an `McpRequest` object.
          3.  Call `_protocol.handleRequest` to process the request.
          4.  Serialize the `McpResponse` to JSON.
          5.  Encode the response with the length prefix.
          6.  Send the encoded response over the WebSocket.
        - Handle connection errors and disconnections gracefully.
      - **Stdio:**
        - Listen for incoming lines on `stdin`.
        - For each line:
          1.  **Decode the Message:** Implement MCP's message framing (length-prefixed JSON). Read the length, then read that many bytes as the JSON payload.
          2.  Deserialize the JSON into an `McpRequest` object.
          3.  Call `_protocol.handleRequest` to process the request.
          4.  Serialize the `McpResponse` to JSON.
          5.  Encode the response with the length prefix.
          6.  Write the encoded response to `stdout`, followed by a newline.
        - Handle errors gracefully.
    - **`registerTool(McpTool tool)`:** Registers a tool with the `_protocol` instance.
    - **`_formatError(dynamic error)`:** Formats an error into an `McpResponse` with an `McpError`. This should handle both `McpException` and other exception types.
    - **`_handleMessage(String message)`:** This method should be removed, and its logic moved into the `start()` method's WebSocket and stdio handling sections.

5.  **Message Framing Implementation:**

    - Create helper functions (likely in `lib/common_imports.dart` or a new `lib/core/framing.dart` file) for encoding and decoding length-prefixed JSON messages:
      - **`encodeMessage(Map<String, dynamic> message)`:**
        1.  Serialize the message to JSON.
        2.  Encode the JSON string to UTF-8 bytes.
        3.  Get the length of the encoded bytes.
        4.  Create a new byte buffer.
        5.  Write the length as a 32-bit unsigned integer (big-endian) to the buffer.
        6.  Write the encoded JSON bytes to the buffer.
        7.  Return the buffer's contents as a `List<int>`.
      - **`decodeMessage(Stream<List<int>> stream)`:**
        1.  Read the first 4 bytes from the stream (this is the length). Use a `StreamController` and `addStream` to manage the stream if needed.
        2.  Convert the 4 bytes to a 32-bit unsigned integer (big-endian).
        3.  Read the next _length_ bytes from the stream.
        4.  Decode the bytes as a UTF-8 string.
        5.  Deserialize the JSON string to a `Map<String, dynamic>`.
        6.  Return the map.
        7.  Handle potential errors (e.g., incomplete stream, invalid JSON).

6.  **Example Tool (for testing):**

    - Create a simple `EchoTool` (in `lib/tools/echo_tool.dart`) that implements `McpTool`.
      - `name`: "echo"
      - `description`: "Echoes back the input message."
      - `inputSchema`: `{"type": "object", "properties": {"message": {"type": "string"}}, "required": ["message"]}`
      - `outputSchema`: `{"type": "object", "properties": {"message": {"type": "string"}}, "required": ["message"]}`
      - `execute`: Returns a map containing the input message. Include a check for cancellation.

7.  **Main Entry Point (`bin/mcp_server.dart`):**

    - Create an `McpServer` instance.
    - Register the `EchoTool`.
    - Call `server.start()`.
    - Allow configuration via command-line arguments or environment variables (e.g., to set the host, port, and transport mode).

8.  **Testing**
    - Write unit tests for `McpProtocol`, message encoding/decoding, and the `EchoTool`.
    - Write integration tests to verify the server's behavior with both WebSocket and stdio clients.

This detailed specification should provide a clear roadmap for implementing the core MCP server functionality. Remember to prioritize clear error handling, robust input validation, and asynchronous processing.
