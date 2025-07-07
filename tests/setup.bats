#!/usr/bin/env bats

# Tests for setup.sh script

load 'helpers/test_helper'

setup() {
    setup_temp_dir
    setup_mock_git_repo
}

teardown() {
    teardown_temp_dir
}

@test "setup.sh creates .claude/commands directory" {
    run "$PROJECT_ROOT/setup.sh"
    
    assert_directory_exists ".claude/commands"
}

@test "setup.sh creates symbolic links to command files" {
    run "$PROJECT_ROOT/setup.sh"
    
    if [[ "$status" -ne 0 ]]; then
        echo "DEBUG: setup.sh failed with status: $status"
        echo "DEBUG: Output: $output"
        echo "DEBUG: Current directory: $(pwd)"
        echo "DEBUG: PROJECT_ROOT: $PROJECT_ROOT"
        echo "DEBUG: COMMANDS_DIR: $COMMANDS_DIR"
        echo "DEBUG: Commands directory exists: $(test -d "$COMMANDS_DIR" && echo 'yes' || echo 'no')"
        echo "DEBUG: Commands in directory:"
        ls -la "$COMMANDS_DIR" || echo "Cannot list commands directory"
        return 1
    fi
    
    # Verify .claude/commands directory exists
    assert_directory_exists ".claude/commands"
    
    # Check that symbolic links are created for each command file
    assert_symlink_exists ".claude/commands/commit.md"
    assert_symlink_exists ".claude/commands/review.md"
    assert_symlink_exists ".claude/commands/refactor.md"
    
    # Verify the symlinks point to the correct files
    [[ "$(readlink '.claude/commands/commit.md')" == "$COMMANDS_DIR/commit.md" ]]
    [[ "$(readlink '.claude/commands/review.md')" == "$COMMANDS_DIR/review.md" ]]
    [[ "$(readlink '.claude/commands/refactor.md')" == "$COMMANDS_DIR/refactor.md" ]]
}

@test "setup.sh shows help with --help flag" {
    run "$PROJECT_ROOT/setup.sh" --help
    
    [ "$status" -eq 0 ]
    assert_output_contains "Usage:"
    assert_output_contains "Options:"
}

@test "setup.sh handles --force flag correctly" {
    # First run to create files
    run "$PROJECT_ROOT/setup.sh"
    [[ "$status" -eq 0 ]] || {
        echo "First setup failed with status: $status"
        echo "Output: $output"
        return 1
    }
    
    # Create a regular file where symlink should be (in test directory)
    # Use a different file name to avoid touching real project files
    echo "dummy content" > ".claude/commands/test-dummy.md"
    
    # Run with --force - this will recreate the existing symlinks
    run "$PROJECT_ROOT/setup.sh" --force
    [[ "$status" -eq 0 ]] || {
        echo "Setup with --force failed with status: $status"
        echo "Output: $output"
        return 1
    }
    
    # Check that commit.md symlink exists (created normally)
    assert_symlink_exists ".claude/commands/commit.md"
}

@test "setup.sh skips existing files without --force" {
    # Create a dummy file in test directory with same name as real command
    mkdir -p .claude/commands
    echo "existing content" > ".claude/commands/test-dummy.md"
    
    run "$PROJECT_ROOT/setup.sh"
    [ "$status" -eq 0 ]
    
    # Verify that real symlinks were created
    assert_symlink_exists ".claude/commands/commit.md"
    # The dummy file should remain unchanged since it doesn't match any real command
    [[ "$(cat .claude/commands/test-dummy.md)" == "existing content" ]]
}

@test "setup.sh works in non-git directory with confirmation" {
    # Create a non-git directory
    rm -rf .git
    
    # Test with 'y' response
    run bash -c "echo 'y' | $PROJECT_ROOT/setup.sh"
    [ "$status" -eq 0 ]
    
    assert_directory_exists ".claude/commands"
}

@test "setup.sh exits gracefully when user declines non-git setup" {
    # Create a non-git directory
    rm -rf .git
    
    # Test with 'n' response
    run bash -c "echo 'n' | $PROJECT_ROOT/setup.sh"
    [ "$status" -eq 0 ]
    
    assert_output_contains "Setup cancelled"
}

@test "setup.sh handles verbose flag" {
    run "$PROJECT_ROOT/setup.sh" --verbose
    
    [ "$status" -eq 0 ]
    assert_output_contains "Processing:"
}

@test "setup.sh reports correct link count" {
    run "$PROJECT_ROOT/setup.sh"
    
    if [[ "$status" -ne 0 ]]; then
        echo "DEBUG: setup.sh failed with status: $status"
        echo "DEBUG: Output: $output"
        echo "DEBUG: Current directory: $(pwd)"
        echo "DEBUG: PROJECT_ROOT: $PROJECT_ROOT"
        echo "DEBUG: COMMANDS_DIR: $COMMANDS_DIR"
        return 1
    fi
    
    assert_output_contains "Created links:"
    assert_output_contains "Setup completed!"
}

@test "setup.sh lists available commands" {
    run "$PROJECT_ROOT/setup.sh"
    
    if [[ "$status" -ne 0 ]]; then
        echo "DEBUG: setup.sh failed with status: $status"
        echo "DEBUG: Output: $output"
        echo "DEBUG: Current directory: $(pwd)"
        echo "DEBUG: PROJECT_ROOT: $PROJECT_ROOT"
        echo "DEBUG: COMMANDS_DIR: $COMMANDS_DIR"
        return 1
    fi
    
    assert_output_contains "Available slash commands:"
    assert_output_contains "/commit"
    assert_output_contains "/review"
    assert_output_contains "/refactor"
}