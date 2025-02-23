Okay, here's a comprehensive specification for building the SIP Intent Server as an MCP server, designed to be directly usable by an AI agent for implementation.

**Response Type:** Specification

**Thought:** This specification combines the architectural overview, resource definitions, tool descriptions, and workflow examples from the previous responses into a single, cohesive document. It emphasizes clarity, completeness, and actionability for an AI agent. It includes specific instructions for file handling, error handling, and LLM interaction.

**Response:**

## SIP Intent Server - MCP Server Specification

**1. Overview**

The SIP Intent Server is an MCP (Model Context Protocol) server that manages a library of Semantic Intents for a Flutter/Dart project. It allows AI agents (and other clients) to interact with the Semantic Intent Paradigm (SIP) using natural language and a standardized MCP interface. The server operates directly on the project's file system, treating the `lib/` directory (and its subdirectories) as the "Semantic Intent Library."

**2. Goals**

- Provide a natural language interface for creating, modifying, and refactoring Semantic Intents.
- Generate implementation artifacts (code, tests, mocks) from Semantic Intents.
- Update Semantic Intents based on changes in implementation code.
- Maintain consistency between the Semantic Intent Library (file system) and the server's internal state.
- Enable AI agents to seamlessly integrate SIP into their workflows.

**3. Architecture**

- **Server:** MCP Server (named "SIP Intent Server").
- **Data Source:** The project's `lib/` directory (and subdirectories).
- **File Types:**
  - `.yaml`: Semantic Intent files (e.g., `my_intent.yaml`).
  - `.dart`: Dart implementation and test files (e.g., `my_intent.dart`, `my_intent_test.dart`).
- **File Watcher:** The server MUST implement a file watcher to detect changes in the `lib/` directory and update its internal state. Use the `watcher` package in Dart.
- **YAML Handling:** Use the `yaml` package in Dart for robust YAML parsing and serialization.
- **LLM Integration:** The server MUST integrate with an LLM (e.g., OpenAI, Gemini) via an API client. The specific LLM is configurable.
- **Caching:** Implement a cache for parsed intent YAML files to improve performance. The cache should be invalidated when files are changed (detected by the file watcher).

**4. MCP Resources**

The server exposes the following resources:

- `/intents`:
  - `GET`: List all intent names and paths.
    - **Response:** JSON array of objects: `[{ "name": "MyIntent", "path": "lib/feature/my_intent.yaml" }, ...]`.
    - **Error Handling:** Return appropriate error codes (e.g., 500) if there are issues accessing the file system.
  - `POST`: Create a new intent.
    - **Request Body:**
      - `description`: (string, required) Natural language description.
      - `path`: (string, optional) Desired file path (relative to `lib/`).
      - `initial_yaml`: (string, optional) Partial YAML.
    - **Response:**
      - `path`: (string) Full path of the created intent file.
      - `yaml`: (string) Initial YAML content.
    - **Error Handling:**
      - 400 Bad Request: If `description` is missing or invalid.
      - 409 Conflict: If the file at `path` already exists.
      - 500 Internal Server Error: For other errors (file system, LLM).
- `/intents/{intent_path}`: (e.g., `/intents/lib/feature/my_intent.yaml`)
  - `GET`: Retrieve the full YAML content.
    - **Response:** The YAML content as a string.
    - **Error Handling:**
      - 404 Not Found: If the file doesn't exist.
      - 500 Internal Server Error: For other errors.
  - `PUT`: Update the intent's YAML.
    - **Request Body:** The complete, valid YAML.
    - **Response:** The updated YAML content (same as request body).
    - **Error Handling:**
      - 400 Bad Request: If the YAML is invalid.
      - 404 Not Found: If the file doesn't exist.
      - 500 Internal Server Error: For other errors.
  - `DELETE`: Delete the intent file (and associated files).
    - **Response:** 204 No Content on success.
    - **Error Handling:**
      - 404 Not Found: If the file doesn't exist.
      - 500 Internal Server Error: For other errors.
- `/intents/{intent_path}/implementation`:
  - `GET`: Retrieve implementation file paths.
    - **Response:** JSON object: `{ "code": "lib/feature/my_intent.dart", "test": "lib/feature/my_intent_test.dart" }` (or similar).
    - **Error Handling:**
      - 404 Not Found: If the intent file or implementation files don't exist.
      - 500 Internal Server Error: For other errors.
- `/intents/{intent_path}/prompts`:
  - `GET`: Retrieve the `llm_prompts` section.
    - **Response:** The `llm_prompts` YAML content as a string.
    - **Error Handling:**
      - 404 Not Found: If the intent file doesn't exist or has no `llm_prompts`.
      - 500 Internal Server Error: For other errors.

**5. MCP Tools**

The server implements the following tools:

- `create_intent`: (See `/intents POST` above for details).
- `modify_intent`:
  - **Input:**
    - `path`: (string, required) Path to the intent file.
    - `changes`: (string, required) Natural language description of changes.
  - **Output:** `yaml`: (string) Updated YAML content.
  - **Steps:**
    1.  Read YAML from `path`.
    2.  Use LLM to apply `changes`.
    3.  Validate YAML.
    4.  Overwrite file at `path`.
    5.  Return updated `yaml`.
- `refactor_intents`:
  - **Input:**
    - `paths`: (array of strings, required) Paths to intent files.
    - `changes`: (string, required) Description of refactoring.
  - **Output:** `updated_paths`: (array of strings) Updated file paths.
  - **Steps:**
    1.  Read YAML files from `paths`.
    2.  Use LLM for batch refactoring (may rename files).
    3.  Validate YAML.
    4.  Save files (handle renames).
    5.  Return `updated_paths`.
- `generate_artifacts`:
  - **Input:**
    - `path`: (string, required) Path to the intent file.
    - `type`: (string, optional) Artifact type ("code", "test", "mock").
  - **Output:** `artifacts`: (object) Map of artifact types to file paths.
  - **Steps:**
    1.  Read YAML from `path`.
    2.  Use `llm_prompts` and `type` to generate artifact(s) via LLM.
    3.  Save files alongside intent file.
    4.  Return `artifacts` map.
- `update_intent_from_implementation`:
  - **Input:**
    - `path`: (string, required) Path to the intent file.
    - `code`: (string, required) Updated code.
  - **Output:** `yaml`: (string) Updated YAML content.
  - **Steps:**
    1.  Read YAML from `path`.
    2.  Use LLM to analyze `code` and infer intent changes.
    3.  Update YAML.
    4.  Validate YAML.
    5.  Overwrite file at `path`.
    6.  Return updated `yaml`.
- `develop_tools_for_intents`:
  - **Input:**
    - `path`: (string, required) Path to the intent file.
    - `tool_description`: (string, required) Description of the tool's purpose.
  - **Output:** Tool plan/specification.
  - **Steps:**
    1. Leverage the `create_intent` and `generate_artifacts` tools.

**6. LLM Interaction**

- The server MUST use structured prompts for LLM interactions. Include relevant context (e.g., the current YAML content, the requested changes).
- The server MUST handle LLM API errors gracefully (e.g., rate limits, timeouts). Implement retries with exponential backoff.
- The server SHOULD provide a mechanism for configuring the LLM provider and API key.

**7. File System Operations**

- All file paths are relative to the project's `lib/` directory.
- The server MUST ensure that all file operations are performed within the project directory (security).
- The server MUST handle file I/O exceptions (e.g., file not found, permission denied).

**8. YAML Validation**

- The server MUST validate the structure of all YAML files against the `SemanticIntent` schema.
- The server SHOULD perform semantic validation (e.g., checking for duplicate intent names, invalid property types).

**9. Caching**

- Server MUST implement cache for read YAML files.
- Server MUST invalidate cache for updated YAML files.

**10. Example Workflow (Agent Perspective)**

```
# Create a new intent
agent.use_tool("create_intent", {
  "description": "UI intent for displaying a user profile.",
  "path": "lib/ui/user_profile.intent.yaml"
})

# Generate code for the intent
agent.use_tool("generate_artifacts", {
  "path": "lib/ui/user_profile.intent.yaml",
  "type": "code"
})

# Modify the intent
agent.use_tool("modify_intent", {
  "path": "lib/ui/user_profile.intent.yaml",
  "changes": "Add a field to display the user's email address."
})
```

**11. Error Handling**

- The server MUST use standard HTTP status codes to indicate success or failure.
- Error responses SHOULD include informative messages in the response body.
- The server MUST log all errors.

**12. Security Considerations**

- The server MUST NOT expose any files outside of the project's `lib/` directory.
- The server SHOULD validate user input to prevent injection attacks.
- Consider authentication if the server is exposed to untrusted clients.

This specification provides a detailed blueprint for building the SIP Intent Server. It covers all the key aspects of the server's functionality and provides clear instructions for implementation.
