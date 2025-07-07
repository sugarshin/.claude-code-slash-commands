#!/bin/bash

# Claude Commands Update Script
# This script updates common Claude Commands to the latest version

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
BRANCH="main"
UPDATE_PROJECTS=false

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
        -b|--branch)
            BRANCH="$2"
            shift 2
            ;;
        -p|--update-projects)
            UPDATE_PROJECTS=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  -d, --dir DIR         Installation directory (default: $DEFAULT_INSTALL_DIR)"
            echo "  -f, --force           Force update"
            echo "  -b, --branch BRANCH   Branch to use (default: main)"
            echo "  -p, --update-projects Also update project symbolic links"
            echo "  -h, --help            Show this help message"
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
    print_error "Claude Commands not installed: $INSTALL_DIR"
    print_info "Run utils/install.sh to install"
    exit 1
fi

# Check if it's a Git repository
if [[ ! -d "$INSTALL_DIR/.git" ]]; then
    print_error "Not a Git repository: $INSTALL_DIR"
    exit 1
fi

# Save current directory
CURRENT_DIR=$(pwd)

# Change to installation directory
cd "$INSTALL_DIR"

# Check current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
print_info "Current branch: $CURRENT_BRANCH"

# Check for uncommitted changes
if [[ -n $(git status --porcelain) ]]; then
    if [[ $FORCE == true ]]; then
        print_warning "Uncommitted changes found. Force updating"
        git reset --hard HEAD
    else
        print_error "Uncommitted changes found"
        print_info "Use --force to discard changes"
        cd "$CURRENT_DIR"
        exit 1
    fi
fi

# Fetch latest changes
print_info "Fetching latest changes..."
if git fetch origin; then
    print_success "Fetch completed"
else
    print_error "Fetch failed"
    cd "$CURRENT_DIR"
    exit 1
fi

# Switch branch if needed
if [[ "$CURRENT_BRANCH" != "$BRANCH" ]]; then
    print_info "Switching branch: $CURRENT_BRANCH -> $BRANCH"
    if git checkout "$BRANCH"; then
        print_success "Branch switch completed"
    else
        print_error "Branch switch failed"
        cd "$CURRENT_DIR"
        exit 1
    fi
fi

# Check for updates
LOCAL_COMMIT=$(git rev-parse HEAD)
REMOTE_COMMIT=$(git rev-parse "origin/$BRANCH")

if [[ "$LOCAL_COMMIT" == "$REMOTE_COMMIT" ]]; then
    print_info "Already up to date"
else
    print_info "Applying updates..."
    if git merge "origin/$BRANCH"; then
        print_success "Update completed"
    else
        print_error "Update failed"
        cd "$CURRENT_DIR"
        exit 1
    fi
fi

# Make scripts executable
print_info "Updating script permissions..."
chmod +x setup.sh utils/*.sh

# Return to original directory
cd "$CURRENT_DIR"

# Update project symbolic links
if [[ $UPDATE_PROJECTS == true ]]; then
    print_info "Updating project symbolic links..."
    
    # Update current project
    if [[ -d ".claude/commands" ]]; then
        print_info "Updating current project..."
        "$INSTALL_DIR/setup.sh" --force
    fi
    
    # Update other projects (optional)
    print_info "Update other projects as well? (y/N): "
    read -r -n 1 response
    echo
    if [[ "$response" =~ ^[Yy]$ ]]; then
        print_info "Enter project directories (space-separated):"
        read -r -a project_dirs
        
        for project_dir in "${project_dirs[@]}"; do
            if [[ -d "$project_dir" ]]; then
                print_info "Updating project: $project_dir"
                (cd "$project_dir" && "$INSTALL_DIR/setup.sh" --force)
            else
                print_warning "Project directory not found: $project_dir"
            fi
        done
    fi
fi

# Display available commands
echo
print_success "Update completed!"
echo
print_info "Available commands:"
for cmd_file in "$INSTALL_DIR/commands"/*.md; do
    if [[ -f "$cmd_file" ]]; then
        cmd_name=$(basename "$cmd_file" .md)
        echo "  /$cmd_name"
    fi
done

echo
print_info "Restart Claude Code to use updated commands"