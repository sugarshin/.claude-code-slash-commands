#!/bin/bash

# Lint script for Claude Code Slash Commands
# This script runs shellcheck on all shell scripts in the project

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}


print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if shellcheck is installed
if ! command -v shellcheck >/dev/null 2>&1; then
    print_error "shellcheck is not installed"
    print_info "Install with: brew install shellcheck (macOS) or sudo apt-get install shellcheck (Linux)"
    exit 1
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

print_info "Running shellcheck on all shell scripts..."

# Find and lint all shell scripts
error_count=0
total_files=0

while IFS= read -r -d '' script; do
    ((total_files++))
    print_info "Linting: ${script}"
    
    if shellcheck "${script}"; then
        print_info "✓ ${script} passed"
    else
        print_error "✗ ${script} failed"
        ((error_count++))
    fi
    echo
done < <(find "${PROJECT_ROOT}" -name "*.sh" -type f -print0)

# Summary
echo "=================================================="
print_info "Linting completed"
print_info "Total files: ${total_files}"
print_info "Errors: ${error_count}"

if [[ ${error_count} -eq 0 ]]; then
    print_info "All scripts passed shellcheck!"
    exit 0
else
    print_error "${error_count} script(s) failed shellcheck"
    exit 1
fi