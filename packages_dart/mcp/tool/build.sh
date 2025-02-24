#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Clean previous builds
rm -f "$PROJECT_ROOT/bin/mcp_server"

# Build the server
cd "$PROJECT_ROOT" && dart compile exe bin/mcp_server.dart -o bin/mcp_server

# Make it executable
chmod +x "$PROJECT_ROOT/bin/mcp_server" 