#!/bin/bash

# Test script for Claude Code Slash Commands
# This script runs all Bats tests

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}


print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

# Check if bats is installed
if ! command -v bats >/dev/null 2>&1; then
    print_error "bats is not installed"
    print_info "Install with: brew install bats-core (macOS) or sudo apt-get install bats (Linux)"
    exit 1
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TESTS_DIR="${PROJECT_ROOT}/tests"

# Check if tests directory exists
if [[ ! -d "${TESTS_DIR}" ]]; then
    print_error "Tests directory not found: ${TESTS_DIR}"
    exit 1
fi

print_header "Running Bats tests..."

# Run tests with options
if [[ "${1:-}" == "--verbose" ]] || [[ "${1:-}" == "-v" ]]; then
    print_info "Running in verbose mode"
    bats --verbose "${TESTS_DIR}"
elif [[ "${1:-}" == "--tap" ]]; then
    print_info "Running in TAP format"
    bats --tap "${TESTS_DIR}"
else
    print_info "Running tests (use --verbose for detailed output)"
    bats "${TESTS_DIR}"
fi

test_exit_code=$?

echo
print_header "Test Results"
if [[ ${test_exit_code} -eq 0 ]]; then
    print_info "✓ All tests passed!"
else
    print_error "✗ Some tests failed"
    print_info "Run with --verbose for more details"
fi

exit "${test_exit_code}"