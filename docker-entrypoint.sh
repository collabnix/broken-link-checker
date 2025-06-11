#!/bin/bash
set -e

# Function to log messages
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a /app/logs/mcp-server.log
}

# Create logs directory if it doesn't exist
mkdir -p /app/logs

# Initialize log file
log "Starting MCP Broken Link Checker Server..."
log "Version: ${MCP_SERVER_VERSION:-1.0.0}"
log "Server Name: ${MCP_SERVER_NAME:-broken-link-checker}"

# Check if config directory exists and has files
if [ -d "/app/config" ] && [ "$(ls -A /app/config)" ]; then
    log "Configuration directory found with files"
    ls -la /app/config/ | tee -a /app/logs/mcp-server.log
else
    log "No configuration directory or files found, using defaults"
fi

# Validate Python environment
log "Python version: $(python --version)"
log "Installed packages:"
pip list | tee -a /app/logs/mcp-server.log

# Check for required dependencies
python -c "import mcp, aiohttp, bs4; print('All required dependencies are available')" || {
    log "ERROR: Missing required dependencies"
    exit 1
}

# Start the MCP server
log "Starting MCP server..."
exec "$@"