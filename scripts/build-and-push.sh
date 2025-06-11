#!/bin/bash

# Build and Push Script for Docker Hub
# This script builds the Docker image and pushes it to Docker Hub

set -e

# Configuration
IMAGE_NAME="collabnix/broken-link-checker-mcp"
DOCKER_REGISTRY="docker.io"
BUILD_PLATFORMS="linux/amd64,linux/arm64"

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

# Help function
show_help() {
    echo "Docker Hub Build and Push Script"
    echo ""
    echo "Usage: $0 [OPTIONS] [VERSION]"
    echo ""
    echo "Options:"
    echo "  --dry-run         Build only, don't push to Docker Hub"
    echo "  --local-only      Build for local platform only (faster)"
    echo "  --latest          Tag as latest (default for main branch)"
    echo "  --help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 1.0.0          # Build and push version 1.0.0"
    echo "  $0 --dry-run      # Build only, don't push"
    echo "  $0 --latest       # Build and push as latest"
    echo "  $0 --local-only 1.0.0  # Build for local platform only"
    echo ""
    echo "Environment Variables:"
    echo "  DOCKER_USERNAME   Docker Hub username"
    echo "  DOCKER_PASSWORD   Docker Hub password/token"
}

# Parse arguments
DRY_RUN=false
LOCAL_ONLY=false
TAG_LATEST=false
VERSION=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --local-only)
            LOCAL_ONLY=true
            shift
            ;;
        --latest)
            TAG_LATEST=true
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        -*)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
        *)
            if [[ -z "$VERSION" ]]; then
                VERSION="$1"
            else
                log_error "Multiple versions specified"
                exit 1
            fi
            shift
            ;;
    esac
done

# Determine version and tags
if [[ -z "$VERSION" ]]; then
    if git describe --tags --exact-match HEAD 2>/dev/null; then
        VERSION=$(git describe --tags --exact-match HEAD | sed 's/^v//')
        log_info "Using git tag version: $VERSION"
    else
        VERSION="dev-$(git rev-parse --short HEAD)"
        log_info "Using development version: $VERSION"
    fi
fi

# Build tags
TAGS=("$IMAGE_NAME:$VERSION")

if [[ "$TAG_LATEST" == "true" ]] || [[ "$(git branch --show-current)" == "main" && "$VERSION" != dev-* ]]; then
    TAGS+=("$IMAGE_NAME:latest")
fi

# Set build platforms
if [[ "$LOCAL_ONLY" == "true" ]]; then
    PLATFORMS="linux/$(uname -m | sed 's/x86_64/amd64/')"
else
    PLATFORMS="$BUILD_PLATFORMS"
fi

log_info "Configuration:"
echo "  Image: $IMAGE_NAME"
echo "  Version: $VERSION"
echo "  Tags: ${TAGS[*]}"
echo "  Platforms: $PLATFORMS"
echo "  Dry run: $DRY_RUN"
echo ""

# Check prerequisites
if ! command -v docker &> /dev/null; then
    log_error "Docker is not installed or not in PATH"
    exit 1
fi

if ! docker buildx version &> /dev/null; then
    log_error "Docker Buildx is not available"
    exit 1
fi

# Create buildx builder if it doesn't exist
if ! docker buildx inspect multiarch &> /dev/null; then
    log_info "Creating multiarch builder"
    docker buildx create --name multiarch --driver docker-container --bootstrap --use
else
    docker buildx use multiarch
fi

# Login to Docker Hub (if not dry run)
if [[ "$DRY_RUN" == "false" ]]; then
    if [[ -z "$DOCKER_USERNAME" ]] || [[ -z "$DOCKER_PASSWORD" ]]; then
        log_warning "DOCKER_USERNAME or DOCKER_PASSWORD not set. Attempting interactive login..."
        if ! docker login $DOCKER_REGISTRY; then
            log_error "Failed to login to Docker Hub"
            exit 1
        fi
    else
        log_info "Logging in to Docker Hub..."
        echo "$DOCKER_PASSWORD" | docker login $DOCKER_REGISTRY -u "$DOCKER_USERNAME" --password-stdin
    fi
fi

# Build tag arguments
TAG_ARGS=()
for tag in "${TAGS[@]}"; do
    TAG_ARGS+=("--tag" "$tag")
done

# Build and optionally push
log_info "Building Docker image..."

if [[ "$DRY_RUN" == "true" ]]; then
    docker buildx build \
        --platform "$PLATFORMS" \
        "${TAG_ARGS[@]}" \
        --load \
        .
    log_success "Image built successfully (dry run)"
    
    # Test the image
    log_info "Testing image..."
    docker run --rm "${TAGS[0]}" python -c "import mcp, aiohttp, bs4; print('✅ Dependencies OK')"
    log_success "Image test passed"
else
    docker buildx build \
        --platform "$PLATFORMS" \
        "${TAG_ARGS[@]}" \
        --push \
        .
    log_success "Image built and pushed successfully"
    
    # Display pull commands
    log_info "Image available at:"
    for tag in "${TAGS[@]}"; do
        echo "  docker pull $tag"
    done
fi

# Cleanup
log_info "Build completed successfully!"