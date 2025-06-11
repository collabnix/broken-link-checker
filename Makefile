# Makefile for Broken Link Checker MCP Tool

# Variables
IMAGE_NAME := broken-link-checker-mcp
CONTAINER_NAME := mcp-broken-link-checker
DOCKER_COMPOSE_FILE := docker-compose.yml
PYTHON_VERSION := 3.11

# Colors
COLOR_RESET := \033[0m
COLOR_BLUE := \033[34m
COLOR_GREEN := \033[32m
COLOR_YELLOW := \033[33m
COLOR_RED := \033[31m

# Help target
.PHONY: help
help: ## Show this help message
	@echo "$(COLOR_BLUE)Broken Link Checker MCP Tool$(COLOR_RESET)"
	@echo ""
	@echo "$(COLOR_GREEN)Available targets:$(COLOR_RESET)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(COLOR_YELLOW)%-20s$(COLOR_RESET) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Development targets
.PHONY: install
install: ## Install Python dependencies locally
	@echo "$(COLOR_BLUE)Installing Python dependencies...$(COLOR_RESET)"
	pip install -r requirements.txt

.PHONY: install-dev
install-dev: ## Install development dependencies
	@echo "$(COLOR_BLUE)Installing development dependencies...$(COLOR_RESET)"
	pip install -r requirements.txt
	pip install pytest black flake8 mypy

.PHONY: lint
lint: ## Run code linting
	@echo "$(COLOR_BLUE)Running code linting...$(COLOR_RESET)"
	flake8 broken_link_checker.py
	black --check broken_link_checker.py
	mypy broken_link_checker.py

.PHONY: format
format: ## Format code
	@echo "$(COLOR_BLUE)Formatting code...$(COLOR_RESET)"
	black broken_link_checker.py

.PHONY: test
test: ## Run tests
	@echo "$(COLOR_BLUE)Running tests...$(COLOR_RESET)"
	python -m pytest -v

# Docker targets
.PHONY: docker-build
docker-build: ## Build Docker image
	@echo "$(COLOR_BLUE)Building Docker image...$(COLOR_RESET)"
	docker build -t $(IMAGE_NAME) .
	@echo "$(COLOR_GREEN)Docker image built successfully$(COLOR_RESET)"

.PHONY: docker-run
docker-run: docker-build ## Build and run Docker container
	@echo "$(COLOR_BLUE)Running Docker container...$(COLOR_RESET)"
	mkdir -p config logs
	docker run -d \
		--name $(CONTAINER_NAME) \
		--restart unless-stopped \
		-v $(PWD)/config:/app/config:ro \
		-v $(PWD)/logs:/app/logs \
		-e PYTHONUNBUFFERED=1 \
		$(IMAGE_NAME)
	@echo "$(COLOR_GREEN)Container started successfully$(COLOR_RESET)"

.PHONY: docker-stop
docker-stop: ## Stop Docker container
	@echo "$(COLOR_BLUE)Stopping Docker container...$(COLOR_RESET)"
	-docker stop $(CONTAINER_NAME)
	@echo "$(COLOR_GREEN)Container stopped$(COLOR_RESET)"

.PHONY: docker-restart
docker-restart: docker-stop docker-run ## Restart Docker container
	@echo "$(COLOR_GREEN)Container restarted$(COLOR_RESET)"

.PHONY: docker-logs
docker-logs: ## Show Docker container logs
	@echo "$(COLOR_BLUE)Showing container logs...$(COLOR_RESET)"
	docker logs -f $(CONTAINER_NAME)

.PHONY: docker-shell
docker-shell: ## Open shell in Docker container
	@echo "$(COLOR_BLUE)Opening shell in container...$(COLOR_RESET)"
	docker exec -it $(CONTAINER_NAME) /bin/bash

.PHONY: docker-clean
docker-clean: ## Remove Docker container and image
	@echo "$(COLOR_BLUE)Cleaning up Docker resources...$(COLOR_RESET)"
	-docker stop $(CONTAINER_NAME)
	-docker rm $(CONTAINER_NAME)
	-docker rmi $(IMAGE_NAME)
	@echo "$(COLOR_GREEN)Cleanup completed$(COLOR_RESET)"

.PHONY: docker-status
docker-status: ## Show Docker container status
	@echo "$(COLOR_BLUE)Container status:$(COLOR_RESET)"
	@if docker ps -q -f name=$(CONTAINER_NAME) | grep -q .; then \
		echo "$(COLOR_GREEN)✓ Running$(COLOR_RESET)"; \
		docker ps -f name=$(CONTAINER_NAME) --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"; \
	else \
		echo "$(COLOR_RED)✗ Not running$(COLOR_RESET)"; \
	fi
	@echo "$(COLOR_BLUE)Image status:$(COLOR_RESET)"
	@if docker images -q $(IMAGE_NAME) | grep -q .; then \
		echo "$(COLOR_GREEN)✓ Built$(COLOR_RESET)"; \
		docker images $(IMAGE_NAME) --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"; \
	else \
		echo "$(COLOR_RED)✗ Not built$(COLOR_RESET)"; \
	fi

# Docker Compose targets
.PHONY: compose-up
compose-up: ## Start services with Docker Compose
	@echo "$(COLOR_BLUE)Starting services with Docker Compose...$(COLOR_RESET)"
	docker-compose up -d
	@echo "$(COLOR_GREEN)Services started$(COLOR_RESET)"

.PHONY: compose-up-web
compose-up-web: ## Start services with web interface
	@echo "$(COLOR_BLUE)Starting services with web interface...$(COLOR_RESET)"
	docker-compose --profile web up -d
	@echo "$(COLOR_GREEN)Services started with web interface$(COLOR_RESET)"

.PHONY: compose-down
compose-down: ## Stop Docker Compose services
	@echo "$(COLOR_BLUE)Stopping Docker Compose services...$(COLOR_RESET)"
	docker-compose down
	@echo "$(COLOR_GREEN)Services stopped$(COLOR_RESET)"

.PHONY: compose-logs
compose-logs: ## Show Docker Compose logs
	@echo "$(COLOR_BLUE)Showing Docker Compose logs...$(COLOR_RESET)"
	docker-compose logs -f

.PHONY: compose-restart
compose-restart: compose-down compose-up ## Restart Docker Compose services
	@echo "$(COLOR_GREEN)Services restarted$(COLOR_RESET)"

# Utility targets
.PHONY: check-deps
check-deps: ## Check if required dependencies are available
	@echo "$(COLOR_BLUE)Checking dependencies...$(COLOR_RESET)"
	@which docker > /dev/null || (echo "$(COLOR_RED)Docker not found$(COLOR_RESET)" && exit 1)
	@which docker-compose > /dev/null || (echo "$(COLOR_RED)Docker Compose not found$(COLOR_RESET)" && exit 1)
	@which python$(PYTHON_VERSION) > /dev/null || which python3 > /dev/null || (echo "$(COLOR_RED)Python not found$(COLOR_RESET)" && exit 1)
	@echo "$(COLOR_GREEN)All dependencies available$(COLOR_RESET)"

.PHONY: setup-dirs
setup-dirs: ## Create necessary directories
	@echo "$(COLOR_BLUE)Creating directories...$(COLOR_RESET)"
	mkdir -p config logs
	@echo "$(COLOR_GREEN)Directories created$(COLOR_RESET)"

.PHONY: clean-logs
clean-logs: ## Clean log files
	@echo "$(COLOR_BLUE)Cleaning log files...$(COLOR_RESET)"
	rm -f logs/*.log
	@echo "$(COLOR_GREEN)Log files cleaned$(COLOR_RESET)"

.PHONY: validate-config
validate-config: ## Validate configuration files
	@echo "$(COLOR_BLUE)Validating configuration files...$(COLOR_RESET)"
	@if [ -f "docker/claude-desktop-docker-config.json" ]; then \
		python -m json.tool docker/claude-desktop-docker-config.json > /dev/null && \
		echo "$(COLOR_GREEN)✓ Claude Desktop config is valid$(COLOR_RESET)"; \
	else \
		echo "$(COLOR_YELLOW)⚠ Claude Desktop config not found$(COLOR_RESET)"; \
	fi
	@if [ -f "docker-compose.yml" ]; then \
		docker-compose config > /dev/null && \
		echo "$(COLOR_GREEN)✓ Docker Compose config is valid$(COLOR_RESET)"; \
	else \
		echo "$(COLOR_RED)✗ Docker Compose config not found$(COLOR_RESET)"; \
	fi

# Combined targets
.PHONY: setup
setup: check-deps setup-dirs docker-build ## Initial setup
	@echo "$(COLOR_GREEN)Setup completed successfully$(COLOR_RESET)"

.PHONY: quick-start
quick-start: setup compose-up ## Quick start with Docker Compose
	@echo "$(COLOR_GREEN)Quick start completed!$(COLOR_RESET)"
	@echo "$(COLOR_BLUE)Use 'make compose-logs' to view logs$(COLOR_RESET)"
	@echo "$(COLOR_BLUE)Use 'make docker-status' to check status$(COLOR_RESET)"

.PHONY: dev-setup
dev-setup: install-dev setup ## Setup for development
	@echo "$(COLOR_GREEN)Development setup completed$(COLOR_RESET)"

.PHONY: clean-all
clean-all: compose-down docker-clean clean-logs ## Clean everything
	@echo "$(COLOR_GREEN)Everything cleaned$(COLOR_RESET)"

# Default target
.DEFAULT_GOAL := help