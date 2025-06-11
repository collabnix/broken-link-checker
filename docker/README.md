# Docker Setup for Broken Link Checker MCP Tool

This directory contains Docker configuration files for containerizing the Broken Link Checker MCP tool.

## Quick Start

### 1. Using Docker Compose (Recommended)

```bash
# Build and start the service
docker-compose up -d

# View logs
docker-compose logs -f

# Stop the service
docker-compose down
```

### 2. Using the Run Script

```bash
# Make the script executable
chmod +x docker/run.sh

# Build and run
./docker/run.sh run --detach

# Check status
./docker/run.sh status

# View logs
./docker/run.sh logs --follow
```

### 3. Manual Docker Commands

```bash
# Build the image
docker build -t broken-link-checker-mcp .

# Run the container
docker run -d \
  --name mcp-broken-link-checker \
  --restart unless-stopped \
  -v $(pwd)/config:/app/config:ro \
  -v $(pwd)/logs:/app/logs \
  broken-link-checker-mcp
```

## Configuration

### MCP Client Configuration (Claude Desktop)

Use this configuration to connect Claude Desktop to the containerized MCP server:

```json
{
  "mcpServers": {
    "broken-link-checker": {
      "command": "docker",
      "args": [
        "exec",
        "-i",
        "mcp-broken-link-checker",
        "python",
        "broken_link_checker.py"
      ]
    }
  }
}
```

### Environment Variables

You can customize the container behavior using environment variables:

```bash
# In docker-compose.yml or docker run command
environment:
  - PYTHONUNBUFFERED=1
  - MCP_SERVER_NAME=broken-link-checker
  - MCP_SERVER_VERSION=1.0.0
```

## Directory Structure

```
docker/
├── README.md                           # This file
├── run.sh                             # Helper script for Docker operations
└── claude-desktop-docker-config.json # Example MCP client configuration
```

## Volume Mounts

### Configuration Directory (`./config`)
- Mount point: `/app/config` (read-only)
- Purpose: Store configuration files
- Usage: Place any configuration files here

### Logs Directory (`./logs`)
- Mount point: `/app/logs` (read-write)
- Purpose: Store application logs
- Usage: Monitor container activity and debugging

## Helper Script Usage

The `run.sh` script provides convenient commands:

```bash
# Build the Docker image
./docker/run.sh build

# Run container in foreground
./docker/run.sh run

# Run container in background
./docker/run.sh run --detach

# Stop container
./docker/run.sh stop

# Restart container
./docker/run.sh restart

# View logs
./docker/run.sh logs

# Follow logs in real-time
./docker/run.sh logs --follow

# Open shell in container
./docker/run.sh shell

# Check container and image status
./docker/run.sh status

# Clean up (remove container and image)
./docker/run.sh clean

# Show help
./docker/run.sh help
```

## Docker Compose Services

### Main Service: `broken-link-checker`
- **Purpose**: Main MCP server container
- **Resources**: 512MB RAM limit, 0.5 CPU limit
- **Health Check**: Python import validation
- **Restart Policy**: Unless stopped

### Optional Service: `web-interface`
- **Purpose**: Web interface for testing (optional)
- **Port**: 8080
- **Profile**: `web` (must be explicitly enabled)
- **Usage**: `docker-compose --profile web up`

## Networking

- **Network**: `mcp-broken-link-checker` (bridge)
- **Internal Communication**: Services can communicate via service names
- **External Access**: Only web interface exposed on port 8080 (if enabled)

## Health Checks

The container includes health checks to monitor service status:

```bash
# Check health status
docker inspect --format='{{.State.Health.Status}}' mcp-broken-link-checker

# View health check logs
docker inspect --format='{{range .State.Health.Log}}{{.Output}}{{end}}' mcp-broken-link-checker
```

## Troubleshooting

### Container Won't Start

1. Check logs:
   ```bash
   docker logs mcp-broken-link-checker
   ```

2. Verify image build:
   ```bash
   docker images broken-link-checker-mcp
   ```

3. Check dependencies:
   ```bash
   docker run --rm broken-link-checker-mcp python -c "import mcp, aiohttp, bs4"
   ```

### MCP Client Connection Issues

1. Ensure container is running:
   ```bash
   docker ps | grep mcp-broken-link-checker
   ```

2. Test MCP server manually:
   ```bash
   docker exec -it mcp-broken-link-checker python broken_link_checker.py
   ```

3. Check configuration path in Claude Desktop

### Performance Issues

1. Adjust resource limits in `docker-compose.yml`
2. Monitor resource usage:
   ```bash
   docker stats mcp-broken-link-checker
   ```

## Security Considerations

- Container runs as non-root user (`appuser`)
- Configuration directory mounted as read-only
- No unnecessary ports exposed
- Health checks for monitoring
- Resource limits to prevent resource exhaustion

## Development

### Building for Development

```bash
# Build with no cache
docker build --no-cache -t broken-link-checker-mcp .

# Build with custom tag
docker build -t broken-link-checker-mcp:dev .
```

### Testing

```bash
# Run tests inside container
docker run --rm broken-link-checker-mcp python -m pytest

# Interactive development
docker run -it --rm -v $(pwd):/app broken-link-checker-mcp bash
```

## Production Deployment

### Resource Recommendations

- **Memory**: 512MB - 1GB
- **CPU**: 0.5 - 1.0 cores
- **Storage**: 1GB for logs and temporary files

### Monitoring

```bash
# Monitor resource usage
docker stats mcp-broken-link-checker

# Check health status
docker inspect --format='{{.State.Health.Status}}' mcp-broken-link-checker

# Follow logs
docker logs -f mcp-broken-link-checker
```