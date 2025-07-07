#!/bin/bash

# Claude Commands Uninstall Script
# This script uninstalls common Claude Commands

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
FORCE=false
REMOVE_SHELL_CONFIG=false
REMOVE_PROJECT_LINKS=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dir)
            INSTALL_DIR="$2"
            shift 2
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -s|--remove-shell-config)
            REMOVE_SHELL_CONFIG=true
            shift
            ;;
        -p|--remove-project-links)
            REMOVE_PROJECT_LINKS=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  -d, --dir DIR                Installation directory (default: $DEFAULT_INSTALL_DIR)"
            echo "  -f, --force                  Remove without confirmation"
            echo "  -s, --remove-shell-config    Also remove from shell configuration"
            echo "  -p, --remove-project-links   Also remove project symbolic links"
            echo "  -h, --help                   Show this help message"
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
    print_warning "Claude Commands not installed: $INSTALL_DIR"
    exit 0
fi

# Confirmation prompt
if [[ $FORCE == false ]]; then
    echo
    print_warning "Will remove directory: $INSTALL_DIR"
    if [[ $REMOVE_SHELL_CONFIG == true ]]; then
        print_warning "Will also remove from shell configuration"
    fi
    if [[ $REMOVE_PROJECT_LINKS == true ]]; then
        print_warning "Will also remove project symbolic links"
    fi
    echo
    read -p "Continue? (y/N): " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Uninstall cancelled"
        exit 0
    fi
fi

# Remove project symbolic links
if [[ $REMOVE_PROJECT_LINKS == true ]]; then
    print_info "Removing project symbolic links..."
    
    # Remove from current project
    if [[ -d ".claude/commands" ]]; then
        print_info "Removing symbolic links from current project..."
        find ".claude/commands" -type l -delete 2>/dev/null || true
        
        # Remove empty directories
        if [[ -d ".claude/commands" ]] && [[ -z "$(ls -A .claude/commands)" ]]; then
            rmdir ".claude/commands" 2>/dev/null || true
        fi
        if [[ -d ".claude" ]] && [[ -z "$(ls -A .claude)" ]]; then
            rmdir ".claude" 2>/dev/null || true
        fi
    fi
    
    # Remove from other projects (optional)
    print_info "Remove symbolic links from other projects as well? (y/N): "
    read -r -n 1 response
    echo
    if [[ "$response" =~ ^[Yy]$ ]]; then
        print_info "Enter project directories (space-separated):"
        read -r -a project_dirs
        
        for project_dir in "${project_dirs[@]}"; do
            if [[ -d "$project_dir/.claude/commands" ]]; then
                print_info "Removing symbolic links from project: $project_dir"
                find "$project_dir/.claude/commands" -type l -delete 2>/dev/null || true
                
                # Remove empty directories
                if [[ -d "$project_dir/.claude/commands" ]] && [[ -z "$(ls -A "$project_dir/.claude/commands")" ]]; then
                    rmdir "$project_dir/.claude/commands" 2>/dev/null || true
                fi
                if [[ -d "$project_dir/.claude" ]] && [[ -z "$(ls -A "$project_dir/.claude")" ]]; then
                    rmdir "$project_dir/.claude" 2>/dev/null || true
                fi
            else
                print_warning "Project directory not found: $project_dir"
            fi
        done
    fi
fi

# Remove from shell configuration
if [[ $REMOVE_SHELL_CONFIG == true ]]; then
    print_info "Removing Claude Commands from shell configuration..."
    
    for config_file in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
        if [[ -f "$config_file" ]]; then
            if grep -q "claude-commands" "$config_file"; then
                print_info "Removing from: $config_file"
                
                # Create backup
                cp "$config_file" "$config_file.bak"
                
                # Remove Claude Commands lines
                sed -i.tmp '/# Claude Commands/,/^$/d' "$config_file"
                sed -i.tmp '/claude-commands/d' "$config_file"
                
                # Remove temporary file
                rm -f "$config_file.tmp"
                
                print_success "Removed from: $config_file (backup: $config_file.bak)"
            fi
        fi
    done
fi

# Remove main directory
print_info "Removing Claude Commands directory: $INSTALL_DIR"
if rm -rf "$INSTALL_DIR"; then
    print_success "Removal completed"
else
    print_error "Removal failed"
    exit 1
fi

# Remove global command symbolic links
if [[ -L "/usr/local/bin/claude-setup" ]]; then
    print_info "Removing global commands..."
    sudo rm -f "/usr/local/bin/ccsc-setup" 2>/dev/null || true
    sudo rm -f "/usr/local/bin/ccsc-update" 2>/dev/null || true
fi

echo
print_success "Claude Commands uninstall completed!"
echo
print_info "Notes:"
echo "  - If you removed shell configuration, open a new shell"
echo "  - Manually remove project symbolic links if not done"
echo "  - Remove backup files if no longer needed"