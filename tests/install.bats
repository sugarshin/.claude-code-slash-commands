#!/usr/bin/env bats

# Tests for utils/install.sh script

load 'helpers/test_helper'

setup() {
    setup_temp_dir
    # Mock the installation directory
    export MOCK_INSTALL_DIR="$TEST_TEMP_DIR/mock-install"
    mkdir -p "$MOCK_INSTALL_DIR"
    
    # Copy necessary files to mock installation
    cp -r "$PROJECT_ROOT/setup.sh" "$MOCK_INSTALL_DIR/"
    cp -r "$PROJECT_ROOT/commands" "$MOCK_INSTALL_DIR/"
    cp -r "$PROJECT_ROOT/utils" "$MOCK_INSTALL_DIR/"
    
    # Mock home directory
    export HOME="$TEST_TEMP_DIR/home"
    mkdir -p "$HOME"
}

teardown() {
    teardown_temp_dir
}

@test "install.sh shows help with --help flag" {
    run "$PROJECT_ROOT/utils/install.sh" --help
    
    [ "$status" -eq 0 ]
    assert_output_contains "Usage:"
    assert_output_contains "Prerequisites:"
}

@test "install.sh fails when installation directory doesn't exist" {
    export HOME="$TEST_TEMP_DIR/home"
    
    run "$PROJECT_ROOT/utils/install.sh" --dir "/nonexistent/path"
    
    [ "$status" -eq 1 ]
    assert_output_contains "repository not found"
}

@test "install.sh validates installation directory structure" {
    # Create invalid installation directory
    mkdir -p "$TEST_TEMP_DIR/invalid-install"
    
    run "$PROJECT_ROOT/utils/install.sh" --dir "$TEST_TEMP_DIR/invalid-install"
    
    [ "$status" -eq 1 ]
    assert_output_contains "Invalid Claude Code Slash Commands installation"
}

@test "install.sh makes scripts executable" {
    # Create mock zshrc
    touch "$HOME/.zshrc"
    
    run "$PROJECT_ROOT/utils/install.sh" --dir "$MOCK_INSTALL_DIR"
    
    [ "$status" -eq 0 ]
    [[ -x "$MOCK_INSTALL_DIR/setup.sh" ]]
    [[ -x "$MOCK_INSTALL_DIR/utils/install.sh" ]]
}

@test "install.sh adds PATH to zshrc when it exists" {
    # Create mock zshrc
    touch "$HOME/.zshrc"
    
    run "$PROJECT_ROOT/utils/install.sh" --dir "$MOCK_INSTALL_DIR"
    
    [ "$status" -eq 0 ]
    
    # Check that PATH and aliases were added (looking for directory path instead)
    grep -q "$MOCK_INSTALL_DIR" "$HOME/.zshrc"
    grep -q "ccsc-setup" "$HOME/.zshrc"
    grep -q "ccsc-update" "$HOME/.zshrc"
}

@test "install.sh handles missing zshrc gracefully" {
    # Don't create .zshrc file
    
    run "$PROJECT_ROOT/utils/install.sh" --dir "$MOCK_INSTALL_DIR"
    
    [ "$status" -eq 0 ]
    assert_output_contains ".zshrc file not found"
    assert_output_contains "manually add the following"
}

@test "install.sh skips existing zshrc entries" {
    # Create zshrc with existing entry (including the key identifier)
    cat > "$HOME/.zshrc" << 'EOF'
# Claude Code Slash Commands - claude-commands
export PATH="$HOME/.claude-code-slash-commands:$PATH"
alias ccsc-setup="$HOME/.claude-code-slash-commands/setup.sh"
alias ccsc-update="$HOME/.claude-code-slash-commands/utils/update.sh"
EOF
    
    run "$PROJECT_ROOT/utils/install.sh" --dir "$MOCK_INSTALL_DIR"
    
    [ "$status" -eq 0 ]
    assert_output_contains "Existing entry found (skipping)"
}

@test "install.sh lists available commands" {
    touch "$HOME/.zshrc"
    
    run "$PROJECT_ROOT/utils/install.sh" --dir "$MOCK_INSTALL_DIR"
    
    [ "$status" -eq 0 ]
    assert_output_contains "Available commands:"
    assert_output_contains "/commit"
    assert_output_contains "/review"
    assert_output_contains "/refactor"
}

@test "install.sh shows next steps" {
    touch "$HOME/.zshrc"
    
    run "$PROJECT_ROOT/utils/install.sh" --dir "$MOCK_INSTALL_DIR"
    
    [ "$status" -eq 0 ]
    assert_output_contains "Next steps:"
    assert_output_contains "source ~/.zshrc"
    assert_output_contains "ccsc-setup"
}