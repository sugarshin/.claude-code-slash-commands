# Makefile for Claude Code Slash Commands

.PHONY: help install test lint clean setup-dev check-deps

# Default target
help:
	@echo "Available targets:"
	@echo "  install    - Install project dependencies"
	@echo "  test       - Run all tests"
	@echo "  lint       - Run shellcheck on all shell scripts"
	@echo "  check      - Run both lint and test"
	@echo "  setup-dev  - Set up development environment"
	@echo "  clean      - Clean up test artifacts"
	@echo "  help       - Show this help message"

# Check if required tools are installed
check-deps:
	@command -v shellcheck >/dev/null 2>&1 || { echo "Error: shellcheck is not installed. Install with: brew install shellcheck"; exit 1; }
	@command -v bats >/dev/null 2>&1 || { echo "Error: bats is not installed. Install with: brew install bats-core"; exit 1; }

# Install development dependencies
install: check-deps
	@echo "Installing development dependencies..."
	@if command -v brew >/dev/null 2>&1; then \
		brew install shellcheck bats-core; \
	else \
		echo "Please install shellcheck and bats-core manually"; \
	fi

# Set up development environment
setup-dev:
	@echo "Setting up development environment..."
	@mkdir -p tests/fixtures
	@mkdir -p tests/helpers
	@echo "Development environment ready"

# Run shellcheck on all shell scripts
lint: check-deps
	@echo "Running shellcheck on shell scripts..."
	@find . -name "*.sh" -type f -exec shellcheck {} +
	@echo "Shellcheck completed successfully"

# Run all tests
test: check-deps
	@echo "Running tests..."
	@if [ -d "tests" ]; then \
		bats tests/; \
	else \
		echo "No tests directory found"; \
	fi

# Run both lint and test
check: lint test
	@echo "All checks completed successfully"

# Clean up test artifacts
clean:
	@echo "Cleaning up test artifacts..."
	@rm -rf tests/fixtures/tmp_*
	@rm -rf tests/fixtures/test_*
	@echo "Cleanup completed"

# Install project using setup script
project-install:
	@echo "Installing project..."
	@./utils/install.sh
	@echo "Project installation completed"