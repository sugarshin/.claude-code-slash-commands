#!/usr/bin/env bash

# Test helper functions for Bats tests

# Get the project root directory
export PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
export COMMANDS_DIR="$PROJECT_ROOT/commands"
export UTILS_DIR="$PROJECT_ROOT/utils"

# Test fixtures directory
export TEST_FIXTURES_DIR="$PROJECT_ROOT/tests/fixtures"

# Create a temporary directory for testing
setup_temp_dir() {
    export TEST_TEMP_DIR="$(mktemp -d)"
    export TEST_ORIGINAL_DIR="$(pwd)"
    cd "$TEST_TEMP_DIR"
    
    # Create mock command files to avoid touching real ones
    mkdir -p mock-commands
    cp -r "$PROJECT_ROOT/commands"/* mock-commands/ 2>/dev/null || true
    export MOCK_COMMANDS_DIR="$TEST_TEMP_DIR/mock-commands"
}

# Clean up temporary directory
teardown_temp_dir() {
    if [[ -n "$TEST_ORIGINAL_DIR" ]]; then
        cd "$TEST_ORIGINAL_DIR"
    fi
    if [[ -n "$TEST_TEMP_DIR" && -d "$TEST_TEMP_DIR" ]]; then
        rm -rf "$TEST_TEMP_DIR"
    fi
}

# Create a mock git repository for testing
setup_mock_git_repo() {
    # Set default branch to main to avoid warnings
    git config --global init.defaultBranch main 2>/dev/null || true
    git init
    git config user.name "Test User"
    git config user.email "test@example.com"
    git config commit.gpgsign false  # Disable GPG signing for tests
    echo "# Test Project" > README.md
    git add README.md
    git commit -m "Initial commit" 2>/dev/null || {
        echo "DEBUG: Git commit failed in setup_mock_git_repo"
        git status
        return 1
    }
}

# Create a mock .claude/commands directory
setup_mock_claude_dir() {
    mkdir -p .claude/commands
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Skip test if command is not available
skip_if_missing() {
    local cmd="$1"
    local message="${2:-$cmd is not available}"
    
    if ! command_exists "$cmd"; then
        skip "$message"
    fi
}

# Assert that a file exists
assert_file_exists() {
    local file="$1"
    [[ -f "$file" ]] || {
        echo "Expected file '$file' to exist"
        return 1
    }
}

# Assert that a directory exists
assert_directory_exists() {
    local dir="$1"
    [[ -d "$dir" ]] || {
        echo "Expected directory '$dir' to exist"
        return 1
    }
}

# Assert that a symlink exists and points to expected target
assert_symlink_exists() {
    local link="$1"
    local expected_target="$2"
    
    [[ -L "$link" ]] || {
        echo "Expected '$link' to be a symlink"
        return 1
    }
    
    if [[ -n "$expected_target" ]]; then
        local actual_target="$(readlink "$link")"
        [[ "$actual_target" == "$expected_target" ]] || {
            echo "Expected symlink '$link' to point to '$expected_target', but it points to '$actual_target'"
            return 1
        }
    fi
}

# Assert that output contains expected text
assert_output_contains() {
    local expected="$1"
    [[ "$output" == *"$expected"* ]] || {
        echo "Expected output to contain '$expected'"
        echo "Actual output: '$output'"
        return 1
    }
}

# Assert that output matches expected pattern
assert_output_matches() {
    local pattern="$1"
    [[ "$output" =~ $pattern ]] || {
        echo "Expected output to match pattern '$pattern'"
        echo "Actual output: '$output'"
        return 1
    }
}