#!/bin/bash

# Claude Commands Installation Script
# This script installs common Claude Commands

set -e

# Functions for colored output
print_info() {
    echo -e "\033[34m[INFO]\033[0m $1"
}

print_success() {
    echo -e "\033[32m[SUCCESS]\033[0m $1"
}

print_warning() {
    echo -e "\033[33m[WARNING]\033[0m $1"
}

print_error() {
    echo -e "\033[31m[ERROR]\033[0m $1"
}

# Default installation directory
DEFAULT_INSTALL_DIR="$HOME/.claude-code-slash-commands"

# Parse command line arguments
INSTALL_DIR="$DEFAULT_INSTALL_DIR"

while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dir)
            INSTALL_DIR="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  -d, --dir DIR      Installation directory (default: $DEFAULT_INSTALL_DIR)"
            echo "  -h, --help         Show this help message"
            echo ""
            echo "Prerequisites:"
            echo "  git clone https://github.com/sugarshin/.claude-code-slash-commands.git ~/.claude-code-slash-commands"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check if installation directory exists
if [[ ! -d "$INSTALL_DIR" ]]; then
    print_error "Claude Commands repository not found: $INSTALL_DIR"
    print_info "Please clone the repository first:"
    print_info "git clone https://github.com/sugarshin/.claude-code-slash-commands.git ~/.claude-code-slash-commands"
    exit 1
fi

# Check if it's a valid Claude Code Slash Commands installation
if [[ ! -f "$INSTALL_DIR/setup.sh" ]] || [[ ! -d "$INSTALL_DIR/commands" ]]; then
    print_error "Invalid Claude Code Slash Commands installation in: $INSTALL_DIR"
    print_info "Please ensure you have cloned the correct repository"
    exit 1
fi

print_info "Found Claude Code Slash Commands installation: $INSTALL_DIR"

# Make scripts executable
print_info "Making scripts executable..."
chmod +x "$INSTALL_DIR/setup.sh"
chmod +x "$INSTALL_DIR/utils"/*.sh

# Add PATH to Zsh configuration
ZSHRC="$HOME/.zshrc"

if [[ -f "$ZSHRC" ]]; then
    print_info "Adding PATH to Zsh configuration: $ZSHRC"
    
    # Check for existing entries
    if ! grep -q "claude-commands" "$ZSHRC"; then
        {
            echo ""
            echo "# Claude Code Slash Commands"
            echo "export PATH=\"${INSTALL_DIR}:\$PATH\""
            echo "alias ccsc-setup=\"${INSTALL_DIR}/setup.sh\""
            echo "alias ccsc-update=\"${INSTALL_DIR}/utils/update.sh\""
        } >> "$ZSHRC"
        print_success "Added to Zsh configuration"
    else
        print_info "Existing entry found (skipping)"
    fi
else
    print_warning ".zshrc file not found"
    print_info "Please manually add the following to .zshrc:"
    echo "export PATH=\"$INSTALL_DIR:\$PATH\""
    echo "alias ccsc-setup=\"$INSTALL_DIR/setup.sh\""
    echo "alias ccsc-update=\"$INSTALL_DIR/utils/update.sh\""
fi

# Display available commands
echo
print_success "Installation completed!"
echo
print_info "Available commands:"
for cmd_file in "$INSTALL_DIR/commands"/*.md; do
    if [[ -f "$cmd_file" ]]; then
        cmd_name=$(basename "$cmd_file" .md)
        echo "  /$cmd_name"
    fi
done

echo
print_info "Next steps:"
echo "  1. Open a new shell or update PATH with:"
echo "     source ~/.zshrc"
echo
echo "  2. In your project directory, run:"
echo "     ccsc-setup"
echo "     or"
echo "     $INSTALL_DIR/setup.sh"
echo
echo "  3. Use available commands in Claude Code:"
echo "     /commit, /review, /refactor"
echo
print_info "Update: Use ccsc-update command to update to latest version"