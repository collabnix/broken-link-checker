#!/bin/bash

# Broken Link Checker MCP Tool - Docker Run Script
# This script helps you run the containerized MCP tool easily

set -e

# Configuration
IMAGE_NAME="broken-link-checker-mcp"
CONTAINER_NAME="mcp-broken-link-checker"
CONFIG_DIR="$(pwd)/config"
LOGS_DIR="$(pwd)/logs"

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
    echo "Broken Link Checker MCP Tool - Docker Runner"
    echo ""
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  build     Build the Docker image"
    echo "  run       Run the container"
    echo "  stop      Stop the container"
    echo "  restart   Restart the container"
    echo "  logs      Show container logs"
    echo "  shell     Open shell in container"
    echo "  clean     Remove container and image"
    echo "  status    Show container status"
    echo "  help      Show this help message"
    echo ""
    echo "Options:"
    echo "  --detach  Run container in background (for run command)"
    echo "  --follow  Follow logs in real-time (for logs command)"
    echo ""
    echo "Examples:"
    echo "  $0 build"
    echo "  $0 run --detach"
    echo "  $0 logs --follow"
    echo "  $0 shell"
}

# Build Docker image
build_image() {
    log_info "Building Docker image: $IMAGE_NAME"
    docker build -t $IMAGE_NAME .
    log_success "Docker image built successfully"
}

# Run container
run_container() {
    local detach_flag=""
    
    if [[ "$1" == "--detach" ]]; then
        detach_flag="-d"
        log_info "Running container in detached mode"
    else
        log_info "Running container in interactive mode"
    fi
    
    # Create directories if they don't exist
    mkdir -p "$CONFIG_DIR" "$LOGS_DIR"
    
    # Stop existing container if running
    if docker ps -q -f name=$CONTAINER_NAME | grep -q .; then
        log_warning "Stopping existing container"
        docker stop $CONTAINER_NAME >/dev/null 2>&1
    fi
    
    # Remove existing container
    if docker ps -aq -f name=$CONTAINER_NAME | grep -q .; then
        docker rm $CONTAINER_NAME >/dev/null 2>&1
    fi
    
    # Run new container
    docker run $detach_flag \
        --name $CONTAINER_NAME \
        --restart unless-stopped \
        -v "$CONFIG_DIR:/app/config:ro" \
        -v "$LOGS_DIR:/app/logs" \
        -e PYTHONUNBUFFERED=1 \
        -e MCP_SERVER_NAME=broken-link-checker \
        -e MCP_SERVER_VERSION=1.0.0 \
        $IMAGE_NAME
    
    if [[ "$1" == "--detach" ]]; then
        log_success "Container started in background"
        log_info "Use '$0 logs --follow' to view logs"
        log_info "Use '$0 status' to check container status"
    fi
}

# Stop container
stop_container() {
    log_info "Stopping container: $CONTAINER_NAME"
    if docker ps -q -f name=$CONTAINER_NAME | grep -q .; then
        docker stop $CONTAINER_NAME
        log_success "Container stopped"
    else
        log_warning "Container is not running"
    fi
}

# Restart container
restart_container() {
    log_info "Restarting container: $CONTAINER_NAME"
    stop_container
    sleep 2
    run_container --detach
}

# Show logs
show_logs() {
    if [[ "$1" == "--follow" ]]; then
        log_info "Following container logs (Ctrl+C to exit)"
        docker logs -f $CONTAINER_NAME
    else
        log_info "Showing container logs"
        docker logs $CONTAINER_NAME
    fi
}

# Open shell
open_shell() {
    log_info "Opening shell in container"
    if docker ps -q -f name=$CONTAINER_NAME | grep -q .; then
        docker exec -it $CONTAINER_NAME /bin/bash
    else
        log_error "Container is not running. Start it first with: $0 run"
        exit 1
    fi
}

# Clean up
clean_up() {
    log_info "Cleaning up container and image"
    
    # Stop and remove container
    if docker ps -q -f name=$CONTAINER_NAME | grep -q .; then
        docker stop $CONTAINER_NAME
    fi
    
    if docker ps -aq -f name=$CONTAINER_NAME | grep -q .; then
        docker rm $CONTAINER_NAME
    fi
    
    # Remove image
    if docker images -q $IMAGE_NAME | grep -q .; then
        docker rmi $IMAGE_NAME
    fi
    
    log_success "Cleanup completed"
}

# Show status
show_status() {
    log_info "Container status:"
    
    if docker ps -q -f name=$CONTAINER_NAME | grep -q .; then
        echo -e "${GREEN}✓ Running${NC}"
        docker ps -f name=$CONTAINER_NAME --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    elif docker ps -aq -f name=$CONTAINER_NAME | grep -q .; then
        echo -e "${YELLOW}⚠ Stopped${NC}"
        docker ps -a -f name=$CONTAINER_NAME --format "table {{.Names}}\t{{.Status}}"
    else
        echo -e "${RED}✗ Not found${NC}"
    fi
    
    log_info "Image status:"
    if docker images -q $IMAGE_NAME | grep -q .; then
        echo -e "${GREEN}✓ Built${NC}"
        docker images $IMAGE_NAME --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedSince}}"
    else
        echo -e "${RED}✗ Not built${NC}"
    fi
}

# Main script logic
case "$1" in
    build)
        build_image
        ;;
    run)
        build_image
        run_container "$2"
        ;;
    stop)
        stop_container
        ;;
    restart)
        restart_container
        ;;
    logs)
        show_logs "$2"
        ;;
    shell)
        open_shell
        ;;
    clean)
        clean_up
        ;;
    status)
        show_status
        ;;
    help|--help|-h)
        show_help
        ;;
    "")
        log_error "No command specified"
        show_help
        exit 1
        ;;
    *)
        log_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac