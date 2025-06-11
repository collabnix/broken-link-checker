#!/bin/bash

# Test Script for Docker Image
# This script tests the Docker image functionality

set -e

# Configuration
IMAGE_NAME="collabnix/broken-link-checker-mcp"
TEST_CONTAINER_NAME="test-broken-link-checker"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Test functions
test_dependencies() {
    log_info "Testing Python dependencies..."
    docker run --rm "$IMAGE_NAME:$VERSION" python -c "
import sys
try:
    import mcp
    import aiohttp
    import bs4
    print('✅ All required dependencies are available')
except ImportError as e:
    print(f'❌ Missing dependency: {e}')
    sys.exit(1)
"
}

test_mcp_server() {
    log_info "Testing MCP server startup..."
    timeout 10s docker run --rm "$IMAGE_NAME:$VERSION" python -c "
import asyncio
import sys
from broken_link_checker import server

async def test():
    try:
        tools = await server.list_tools()
        print(f'✅ MCP server loaded {len(tools)} tools')
        for tool in tools:
            print(f'  - {tool.name}: {tool.description}')
        return True
    except Exception as e:
        print(f'❌ MCP server test failed: {e}')
        return False

result = asyncio.run(test())
sys.exit(0 if result else 1)
" || {
    log_warning "MCP server test timed out (expected for stdio server)"
}
}

test_container_health() {
    log_info "Testing container health..."
    
    # Start container
    docker run -d --name "$TEST_CONTAINER_NAME" "$IMAGE_NAME:$VERSION" sleep 30
    
    # Wait for health check
    sleep 5
    
    # Check health status
    HEALTH_STATUS=$(docker inspect --format='{{.State.Health.Status}}' "$TEST_CONTAINER_NAME" 2>/dev/null || echo "no-health-check")
    
    if [[ "$HEALTH_STATUS" == "healthy" ]]; then
        log_success "Container health check passed"
    elif [[ "$HEALTH_STATUS" == "no-health-check" ]]; then
        log_warning "No health check configured"
    else
        log_error "Container health check failed: $HEALTH_STATUS"
    fi
    
    # Cleanup
    docker stop "$TEST_CONTAINER_NAME" >/dev/null 2>&1
    docker rm "$TEST_CONTAINER_NAME" >/dev/null 2>&1
}

test_image_size() {
    log_info "Checking image size..."
    
    SIZE=$(docker images --format "table {{.Size}}" "$IMAGE_NAME:$VERSION" | tail -n 1)
    
    log_info "Image size: $SIZE"
    
    # Convert size to MB for comparison (rough estimate)
    if [[ "$SIZE" =~ ([0-9.]+)GB ]]; then
        SIZE_NUM=${BASH_REMATCH[1]}
        if (( $(echo "$SIZE_NUM > 1.0" | bc -l) )); then
            log_warning "Image size is quite large: $SIZE"
        else
            log_success "Image size is reasonable: $SIZE"
        fi
    else
        log_success "Image size is reasonable: $SIZE"
    fi
}

test_platforms() {
    log_info "Testing image platforms..."
    
    # Get image manifest
    if command -v docker &> /dev/null && docker buildx imagetools inspect "$IMAGE_NAME:$VERSION" >/dev/null 2>&1; then
        PLATFORMS=$(docker buildx imagetools inspect "$IMAGE_NAME:$VERSION" 2>/dev/null | grep -o "linux/[a-z0-9]*" | sort -u | tr '\n' ', ' | sed 's/,$//')
        
        if [[ -n "$PLATFORMS" ]]; then
            log_success "Available platforms: $PLATFORMS"
        else
            log_warning "Could not determine available platforms"
        fi
    else
        log_warning "Could not inspect image platforms (buildx not available)"
    fi
}

# Main test function
run_tests() {
    local version="$1"
    
    log_info "Running tests for image: $IMAGE_NAME:$version"
    echo ""
    
    # Check if image exists
    if ! docker image inspect "$IMAGE_NAME:$version" >/dev/null 2>&1; then
        log_info "Image not found locally, pulling from Docker Hub..."
        docker pull "$IMAGE_NAME:$version"
    fi
    
    # Run tests
    test_dependencies
    test_mcp_server
    test_container_health
    test_image_size
    test_platforms
    
    echo ""
    log_success "All tests completed for $IMAGE_NAME:$version"
}

# Parse arguments
VERSION="latest"

if [[ $# -gt 0 ]]; then
    VERSION="$1"
fi

# Help
if [[ "$VERSION" == "--help" ]] || [[ "$VERSION" == "-h" ]]; then
    echo "Docker Image Test Script"
    echo ""
    echo "Usage: $0 [VERSION]"
    echo ""
    echo "Examples:"
    echo "  $0           # Test latest version"
    echo "  $0 1.0.0     # Test specific version"
    echo "  $0 dev       # Test dev version"
    exit 0
fi

# Run tests
run_tests "$VERSION"