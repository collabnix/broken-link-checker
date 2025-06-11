# Docker Hub Publishing Guide

This guide explains how to build and publish the Broken Link Checker MCP tool to Docker Hub.

## 🚀 Quick Start for Users

If you just want to use the pre-built image:

```bash
# Pull the latest image
docker pull collabnix/broken-link-checker-mcp:latest

# Run with Docker Compose
wget https://raw.githubusercontent.com/collabnix/broken-link-checker/main/docker-compose.yml
docker-compose up -d

# Or run directly
docker run -d \
  --name mcp-broken-link-checker \
  --restart unless-stopped \
  collabnix/broken-link-checker-mcp:latest
```

## 🏗️ Building and Publishing

### Automated Builds (GitHub Actions)

The repository is configured with GitHub Actions to automatically build and push images to Docker Hub:

- **On push to main**: Builds and pushes `latest` tag
- **On git tags**: Builds and pushes versioned tags (e.g., `v1.0.0` → `1.0.0`, `1.0`, `1`)
- **On pull requests**: Builds and tests (but doesn't push)

### Manual Building and Publishing

#### Prerequisites

1. **Docker Hub Account**: Create account at [hub.docker.com](https://hub.docker.com)
2. **Docker with Buildx**: Ensure Docker Buildx is available
3. **Credentials**: Set up Docker Hub credentials

#### Method 1: Using the Build Script (Recommended)

```bash
# Make the script executable
chmod +x scripts/build-and-push.sh

# Set Docker Hub credentials
export DOCKER_USERNAME="your-username"
export DOCKER_PASSWORD="your-password-or-token"

# Build and push a specific version
./scripts/build-and-push.sh 1.0.0

# Build and push as latest
./scripts/build-and-push.sh --latest

# Dry run (build only, don't push)
./scripts/build-and-push.sh --dry-run 1.0.0

# Build for local platform only (faster)
./scripts/build-and-push.sh --local-only 1.0.0
```

#### Method 2: Using Makefile

```bash
# Set credentials
export DOCKER_USERNAME="your-username"
export DOCKER_PASSWORD="your-password-or-token"

# Build and push to Docker Hub
make docker-hub-push VERSION=1.0.0

# Build and push latest
make docker-hub-push-latest
```

#### Method 3: Manual Docker Commands

```bash
# Login to Docker Hub
docker login

# Build for multiple platforms
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --tag collabnix/broken-link-checker-mcp:1.0.0 \
  --tag collabnix/broken-link-checker-mcp:latest \
  --push .
```

## 🧪 Testing Published Images

### Automated Testing

The repository includes automated testing via GitHub Actions that runs after each build.

### Manual Testing

```bash
# Test a specific version
./scripts/test-image.sh 1.0.0

# Test latest
./scripts/test-image.sh latest

# Quick dependency test
docker run --rm collabnix/broken-link-checker-mcp:latest \
  python -c "import mcp, aiohttp, bs4; print('✅ Dependencies OK')"
```

## 📋 Release Process

### For Maintainers

1. **Update Version**: Update version in relevant files
2. **Create Git Tag**: 
   ```bash
   git tag -a v1.0.0 -m "Release version 1.0.0"
   git push origin v1.0.0
   ```
3. **Automated Build**: GitHub Actions will automatically build and push
4. **Verify**: Check [Docker Hub](https://hub.docker.com/r/collabnix/broken-link-checker-mcp) for new tags
5. **Update Documentation**: Update README and docs with new version

### Version Tagging Strategy

- **Git tag `v1.2.3`** creates Docker tags:
  - `1.2.3` (exact version)
  - `1.2` (minor version)
  - `1` (major version)
  - `latest` (if from main branch)

## 🏷️ Available Tags

| Tag | Description | Updated |
|-----|-------------|----------|
| `latest` | Latest stable release | On main branch pushes |
| `1.x.x` | Specific version | On git tags |
| `1.x` | Latest patch of minor version | On git tags |
| `1` | Latest minor of major version | On git tags |
| `main` | Latest main branch build | On main branch pushes |
| `dev-*` | Development builds | On feature branches |

## 🔧 Configuration for GitHub Actions

### Required Secrets

Add these secrets to your GitHub repository:

1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Add repository secrets:
   - `DOCKER_USERNAME`: Your Docker Hub username
   - `DOCKER_PASSWORD`: Your Docker Hub password or access token

### Access Token Setup (Recommended)

1. Go to [Docker Hub Account Settings](https://hub.docker.com/settings/security)
2. Create a new access token
3. Use the token as `DOCKER_PASSWORD` (more secure than password)

## 🔍 Monitoring and Maintenance

### Health Checks

- **Automated Tests**: Run on every build
- **Security Scanning**: Trivy vulnerability scanner
- **Multi-platform Support**: AMD64 and ARM64

### Image Optimization

- **Multi-stage builds**: Minimal final image size
- **Layer caching**: Faster builds with GitHub Actions cache
- **Security**: Non-root user, minimal base image

### Troubleshooting

#### Build Failures

```bash
# Check GitHub Actions logs
# View at: https://github.com/collabnix/broken-link-checker/actions

# Test build locally
./scripts/build-and-push.sh --dry-run
```

#### Push Failures

```bash
# Verify credentials
docker login

# Check repository permissions
# Ensure you have push access to collabnix/broken-link-checker-mcp
```

#### Platform Issues

```bash
# Build for specific platform only
./scripts/build-and-push.sh --local-only

# Check buildx setup
docker buildx ls
```

## 📊 Usage Analytics

Monitor image usage at:
- [Docker Hub Repository](https://hub.docker.com/r/collabnix/broken-link-checker-mcp)
- GitHub Actions build logs
- Repository insights

## 🤝 Contributing

To contribute to the Docker Hub publishing process:

1. Test changes with `--dry-run` flag
2. Ensure GitHub Actions pass
3. Update documentation if needed
4. Follow semver for version tags

## 📚 Additional Resources

- [Docker Hub Repository](https://hub.docker.com/r/collabnix/broken-link-checker-mcp)
- [GitHub Actions Workflows](../.github/workflows/)
- [Docker Documentation](https://docs.docker.com/)
- [Buildx Documentation](https://docs.docker.com/buildx/)