#!/usr/bin/env bats

# Tests for command files structure and format

load 'helpers/test_helper'

@test "all command files have proper YAML frontmatter" {
    for cmd_file in "$COMMANDS_DIR"/*.md; do
        if [[ -f "$cmd_file" ]]; then
            # Check that file starts with YAML frontmatter
            head -1 "$cmd_file" | grep -q "^---$"
            
            # Check that frontmatter contains required fields
            grep -q "description:" "$cmd_file"
            grep -q "allowed-tools:" "$cmd_file"
        fi
    done
}

@test "commit.md has correct structure" {
    assert_file_exists "$COMMANDS_DIR/commit.md"
    
    # Check for required sections
    grep -q "# Smart Git Commit" "$COMMANDS_DIR/commit.md"
    grep -q "Conventional Commits" "$COMMANDS_DIR/commit.md"
    grep -q "\$ARGUMENTS" "$COMMANDS_DIR/commit.md"
}

@test "review.md has correct structure" {
    assert_file_exists "$COMMANDS_DIR/review.md"
    
    # Check for required sections
    grep -q "# Code Review Assistant" "$COMMANDS_DIR/review.md"
    grep -q "コード品質" "$COMMANDS_DIR/review.md"
    grep -q "パフォーマンス" "$COMMANDS_DIR/review.md"
    grep -q "セキュリティ" "$COMMANDS_DIR/review.md"
    grep -q "\$ARGUMENTS" "$COMMANDS_DIR/review.md"
}

@test "refactor.md has correct structure" {
    assert_file_exists "$COMMANDS_DIR/refactor.md"
    
    # Check for required sections
    grep -q "# Code Refactoring Assistant" "$COMMANDS_DIR/refactor.md"
    grep -q "構造的改善" "$COMMANDS_DIR/refactor.md"
    grep -q "パフォーマンス最適化" "$COMMANDS_DIR/refactor.md"
    grep -q "\$ARGUMENTS" "$COMMANDS_DIR/refactor.md"
}

@test "command template has correct structure" {
    assert_file_exists "$PROJECT_ROOT/templates/command-template.md"
    
    # Check for template sections
    grep -q "カスタムコマンドテンプレート" "$PROJECT_ROOT/templates/command-template.md"
    grep -q "\$ARGUMENTS" "$PROJECT_ROOT/templates/command-template.md"
    grep -q "allowed-tools:" "$PROJECT_ROOT/templates/command-template.md"
}

@test "all command files reference \$ARGUMENTS" {
    for cmd_file in "$COMMANDS_DIR"/*.md; do
        if [[ -f "$cmd_file" ]]; then
            grep -q "\$ARGUMENTS" "$cmd_file" || {
                echo "Command file $cmd_file does not reference \$ARGUMENTS"
                return 1
            }
        fi
    done
}

@test "all command files have proper allowed-tools configuration" {
    for cmd_file in "$COMMANDS_DIR"/*.md; do
        if [[ -f "$cmd_file" ]]; then
            # Check that allowed-tools is properly formatted as array
            grep -q 'allowed-tools: \[' "$cmd_file" || {
                echo "Command file $cmd_file does not have properly formatted allowed-tools"
                return 1
            }
        fi
    done
}