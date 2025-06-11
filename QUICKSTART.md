# Quick Start Guide: Using Pre-built Docker Image

This guide shows you how to quickly use the Broken Link Checker MCP tool using the pre-built Docker image from Docker Hub.

## 🚀 One-Command Start

```bash
# Download and start the service instantly
curl -sSL https://raw.githubusercontent.com/collabnix/broken-link-checker/main/docker-compose.yml | docker-compose -f - up -d
```

## 📦 Docker Hub Image

The image is available on Docker Hub:
**[`collabnix/broken-link-checker-mcp`](https://hub.docker.com/r/collabnix/broken-link-checker-mcp)**

### Available Tags

| Tag | Description | Architecture |
|-----|-------------|--------------|
| `latest` | Latest stable release | AMD64, ARM64 |
| `1.x.x` | Specific version | AMD64, ARM64 |
| `main` | Latest main branch | AMD64, ARM64 |

## 🐳 Usage Methods

### Method 1: Docker Compose (Recommended)

```bash
# Create docker-compose.yml or download it
curl -o docker-compose.yml https://raw.githubusercontent.com/collabnix/broken-link-checker/main/docker-compose.yml

# Start the service
docker-compose up -d

# View logs
docker-compose logs -f

# Stop the service
docker-compose down
```

### Method 2: Direct Docker Run

```bash
# Pull the image
docker pull collabnix/broken-link-checker-mcp:latest

# Run the container
docker run -d \
  --name mcp-broken-link-checker \
  --restart unless-stopped \
  -v $(pwd)/config:/app/config:ro \
  -v $(pwd)/logs:/app/logs \
  collabnix/broken-link-checker-mcp:latest

# View logs
docker logs -f mcp-broken-link-checker
```

### Method 3: One-liner for Testing

```bash
# Quick test run
docker run --rm collabnix/broken-link-checker-mcp:latest python -c \"import mcp, aiohttp, bs4; print('✅ Ready to check links!')\"
```

## ⚙️ Configuration

### MCP Client Setup (Claude Desktop)

Create or update your Claude Desktop configuration:

```json
{
  \"mcpServers\": {
    \"broken-link-checker\": {
      \"command\": \"docker\",
      \"args\": [
        \"exec\",
        \"-i\",
        \"mcp-broken-link-checker\",
        \"python\",
        \"broken_link_checker.py\"
      ]
    }
  }
}
```

### Environment Variables

```bash
# Set these in docker-compose.yml or docker run
PYTHONUNBUFFERED=1
MCP_SERVER_NAME=broken-link-checker
MCP_SERVER_VERSION=1.0.0
```

## 📁 Directory Structure

```bash
# Create these directories for persistent data
mkdir -p config logs

# Your setup will look like:
./
├── docker-compose.yml
├── config/          # Configuration files
└── logs/            # Application logs
```

## 🔍 Testing

### Verify Installation

```bash
# Check container is running
docker ps | grep broken-link-checker

# Test dependencies
docker exec mcp-broken-link-checker python -c \"import mcp, aiohttp, bs4; print('✅ All good!')\"

# Check health
docker inspect --format='{{.State.Health.Status}}' mcp-broken-link-checker
```

### Example Usage

Once configured with Claude Desktop, you can use commands like:

```
Scan https://example.com for broken links
Check these URLs: https://site1.com, https://site2.com
Scan my website with depth 3 and exclude external links
```

## 🛠️ Troubleshooting

### Container Won't Start

```bash
# Check logs
docker logs mcp-broken-link-checker

# Restart container
docker restart mcp-broken-link-checker

# Pull latest image
docker pull collabnix/broken-link-checker-mcp:latest
```

### MCP Connection Issues

1. Ensure container is running: `docker ps`
2. Check Claude Desktop configuration path
3. Restart Claude Desktop after config changes
4. Verify Docker exec permissions

### Performance Issues

```bash
# Monitor resource usage
docker stats mcp-broken-link-checker

# Adjust resource limits in docker-compose.yml
```

## 📚 Additional Resources

- **GitHub Repository**: https://github.com/collabnix/broken-link-checker
- **Docker Hub**: https://hub.docker.com/r/collabnix/broken-link-checker-mcp
- **Documentation**: [README.md](https://github.com/collabnix/broken-link-checker/blob/main/README.md)
- **Examples**: [Usage Examples](https://github.com/collabnix/broken-link-checker/blob/main/examples/usage-examples.md)

## 🔄 Updates

```bash
# Pull latest version
docker-compose pull

# Restart with new image
docker-compose up -d

# Or for direct docker run
docker pull collabnix/broken-link-checker-mcp:latest
docker restart mcp-broken-link-checker
```

---

**Need help?** Open an issue on [GitHub](https://github.com/collabnix/broken-link-checker/issues) or check the [troubleshooting guide](https://github.com/collabnix/broken-link-checker/blob/main/docker/README.md#troubleshooting).