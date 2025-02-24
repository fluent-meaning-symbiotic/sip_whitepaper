#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Clean previous builds
rm -f "$PROJECT_ROOT/bin/mcp_server"

# Get dependencies
cd "$PROJECT_ROOT" && dart pub get

# Build the server
echo "Building MCP server..."
cd "$PROJECT_ROOT" && dart compile exe bin/mcp_server.dart -o bin/mcp_server

# Make it executable
chmod +x "$PROJECT_ROOT/bin/mcp_server"

echo "Build complete. Server executable is at bin/mcp_server" 