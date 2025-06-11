# Broken Link Checker MCP Tool

A Model Context Protocol (MCP) tool for checking broken links on websites. This tool can crawl websites and identify broken internal and external links, providing detailed reports.

## 🚀 Quick Start

### Option 1: Docker (Recommended)

```bash
# Clone the repository
git clone https://github.com/collabnix/broken-link-checker.git
cd broken-link-checker

# Quick start with Docker Compose
make quick-start

# Or use the helper script
chmod +x docker/run.sh
./docker/run.sh run --detach
```

### Option 2: Local Installation

```bash
# Clone and install dependencies
git clone https://github.com/collabnix/broken-link-checker.git
cd broken-link-checker
pip install -r requirements.txt

# Run directly
python broken_link_checker.py
```

## ✨ Features

- 🔍 **Website Crawling**: Crawl websites up to specified depth
- 🔗 **Link Detection**: Find all links including href, src, and other link types
- ✅ **Status Checking**: Check HTTP status of each link
- 📊 **Detailed Reports**: Get comprehensive reports with broken link details
- ⚡ **Batch Processing**: Process links in batches for better performance
- 🎯 **Specific Link Testing**: Check status of specific URLs
- 🌐 **Internal/External Filtering**: Option to include or exclude external links
- 🐳 **Docker Support**: Fully containerized with Docker and Docker Compose
- 🛠️ **Development Tools**: Makefile, linting, testing, and more

## 📦 Installation Options

### Docker Installation (Recommended)

#### Using Docker Compose
```bash
# Start the service
docker-compose up -d

# View logs
docker-compose logs -f

# Stop the service
docker-compose down
```

#### Using Helper Script
```bash
# Make executable and run
chmod +x docker/run.sh

# Build and run in background
./docker/run.sh run --detach

# Check status
./docker/run.sh status

# View logs
./docker/run.sh logs --follow
```

#### Using Makefile
```bash
# Quick start (builds, creates dirs, starts services)
make quick-start

# Individual commands
make docker-build     # Build image
make docker-run       # Run container
make docker-status    # Check status
make docker-logs      # View logs
make docker-clean     # Clean up
```

### Local Python Installation
```bash
# Install dependencies
pip install -r requirements.txt

# For development
make dev-setup
```

## 🔧 Configuration

### MCP Client Configuration

#### For Docker Setup (Claude Desktop)
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

#### For Local Setup (Claude Desktop)
```json
{
  "mcpServers": {
    "broken-link-checker": {
      "command": "python",
      "args": ["/path/to/broken-link-checker/broken_link_checker.py"]
    }
  }
}
```

Example configurations are available in:
- `docker/claude-desktop-docker-config.json` (Docker setup)
- `examples/claude-desktop-config.json` (Local setup)

## 🛠️ Available Tools

### 1. `scan_website_links`

Comprehensively scan a website for broken links.

**Parameters:**
- `url` (required): The base URL of the website to scan
- `max_depth` (optional): Maximum crawl depth (default: 2)
- `include_external` (optional): Whether to check external links (default: true)
- `timeout` (optional): Request timeout in seconds (default: 10)

**Example:**
```
Scan mywebsite.com for broken links with depth 3
```

### 2. `check_specific_links`

Check the status of specific URLs.

**Parameters:**
- `urls` (required): Array of URLs to check
- `timeout` (optional): Request timeout in seconds (default: 10)

**Example:**
```
Check these URLs: https://example.com/page1, https://example.com/page2
```

## 📋 Usage Examples

### WordPress Site Check
```
Scan my WordPress site https://myblog.com for broken links
```

### Internal Links Only
```
Scan https://mysite.com but only check internal links
```

### Specific Links
```
Check these specific URLs for broken links:
- https://example.com/contact
- https://example.com/about
- https://example.com/products
```

### Deep Crawl
```
Scan https://mysite.com with maximum depth of 5 levels
```

More examples available in `examples/usage-examples.md`.

## 📊 Report Format

The tool generates detailed reports including:

- **Summary**: Total links found, broken count, success rate
- **Scan Parameters**: Depth, external link inclusion, timeout
- **Broken Link Details**: Status codes, error messages, locations where broken links appear

### Sample Output
```
# Broken Link Report for https://example.com

## Summary
- Total unique links found: 156
- Broken links: 3
- Success rate: 98.1%

## Broken Links Details

### ❌ https://example.com/old-page
- Status: 404
- Error: HTTP error
- Found on pages:
  - https://example.com/blog/post-1
  - https://example.com/about
```

## 🐳 Docker Details

### Available Commands

```bash
# Helper script commands
./docker/run.sh build          # Build image
./docker/run.sh run            # Run container (foreground)
./docker/run.sh run --detach   # Run container (background)
./docker/run.sh stop           # Stop container
./docker/run.sh restart        # Restart container
./docker/run.sh logs           # View logs
./docker/run.sh logs --follow  # Follow logs
./docker/run.sh shell          # Open shell in container
./docker/run.sh status         # Show status
./docker/run.sh clean          # Remove container and image

# Makefile commands
make help              # Show all available commands
make quick-start       # Complete setup and start
make docker-build      # Build Docker image
make docker-run        # Run container
make compose-up        # Start with Docker Compose
make compose-down      # Stop Docker Compose services
make docker-status     # Check container status
make clean-all         # Clean everything
```

### Resource Requirements

- **Memory**: 512MB - 1GB
- **CPU**: 0.5 - 1.0 cores
- **Storage**: 1GB for logs and temporary files

### Volume Mounts

- `./config:/app/config:ro` - Configuration files (read-only)
- `./logs:/app/logs` - Application logs (read-write)

## 🔍 Troubleshooting

### Docker Issues

1. **Container won't start**:
   ```bash
   ./docker/run.sh logs
   # or
   make docker-logs
   ```

2. **Check container status**:
   ```bash
   ./docker/run.sh status
   # or
   make docker-status
   ```

3. **Rebuild image**:
   ```bash
   ./docker/run.sh clean
   ./docker/run.sh build
   ```

### Common Issues

1. **Import Errors**: Make sure all dependencies are installed
2. **Timeout Issues**: Increase timeout parameter for slow websites
3. **Rate Limiting**: The tool includes batch processing to avoid overwhelming servers
4. **Permission Errors**: Ensure the Python file has execute permissions

### Performance Tips

- Use lower `max_depth` for large websites
- Set `include_external=false` to focus on internal links only
- Adjust `timeout` based on your website's response time
- For very large sites, consider running scans during off-peak hours

## 🧪 Development

### Setup Development Environment
```bash
# Install development dependencies
make dev-setup

# Run linting
make lint

# Format code
make format

# Run tests
make test
```

### Project Structure
```
broken-link-checker/
├── broken_link_checker.py     # Main MCP tool
├── requirements.txt           # Python dependencies
├── Dockerfile                 # Docker image definition
├── docker-compose.yml         # Docker Compose configuration
├── Makefile                   # Build and development commands
├── docker/
│   ├── run.sh                # Docker helper script
│   ├── README.md             # Docker-specific documentation
│   └── claude-desktop-docker-config.json
├── examples/
│   ├── claude-desktop-config.json
│   └── usage-examples.md
└── README.md                 # This file
```

## 🚀 Production Deployment

### Using Docker Compose (Recommended)
```bash
# Production deployment
docker-compose up -d

# Monitor
docker-compose logs -f

# Scale if needed
docker-compose up -d --scale broken-link-checker=2
```

### Resource Monitoring
```bash
# Monitor resource usage
docker stats mcp-broken-link-checker

# Check health
docker inspect --format='{{.State.Health.Status}}' mcp-broken-link-checker
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `make test`
5. Submit a pull request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

If you encounter any issues or have questions:

1. Check the [troubleshooting section](#🔍-troubleshooting)
2. Review [examples](examples/usage-examples.md)
3. Open an issue on GitHub
4. Check Docker-specific docs in [docker/README.md](docker/README.md)

## 🙏 Acknowledgments

- Built with [Model Context Protocol (MCP)](https://modelcontextprotocol.io/)
- Uses [aiohttp](https://aiohttp.readthedocs.io/) for async HTTP requests
- HTML parsing with [Beautiful Soup](https://www.crummy.com/software/BeautifulSoup/)
- Containerized with [Docker](https://www.docker.com/)

---

**Ready to check your links?** Start with `make quick-start` for Docker or follow the local installation guide above!