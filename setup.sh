#!/bin/bash

# Claude Code Slash Commands Setup Script
# This script sets up common Claude Commands for the current project

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

# Get path to common slash commands
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMANDS_DIR="${SCRIPT_DIR}/commands"
TARGET_DIR=".claude/commands"

# Parse command line arguments
FORCE=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--force)
            FORCE=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  -f, --force    Overwrite existing slash commands"
            echo "  -v, --verbose  Show detailed logs"
            echo "  -h, --help     Show this help message"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check if current directory is a Git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    print_warning "Current directory is not a Git repository"
    read -p "Continue anyway? (y/N): " -r
    if [[ ! ${REPLY} =~ ^[Yy]$ ]]; then
        print_info "Setup cancelled"
        exit 0
    fi
fi

# Check if common slash commands directory exists
if [[ ! -d "${COMMANDS_DIR}" ]]; then
    print_error "Common slash commands directory not found: ${COMMANDS_DIR}"
    exit 1
fi

# Create .claude/commands directory
print_info "Creating Claude Slash Commands directory..."
mkdir -p "${TARGET_DIR}"

# Link common slash commands
print_info "Setting up common slash commands..."
link_count=0
skip_count=0

for cmd_file in "${COMMANDS_DIR}"/*.md; do
    if [[ ! -f "${cmd_file}" ]]; then
        continue
    fi
    
    filename=$(basename "${cmd_file}")
    target_file="${TARGET_DIR}/${filename}"
    
    if [[ ${VERBOSE} == true ]]; then
        print_info "Processing: ${filename}"
    fi
    
    # Check for existing files
    if [[ -e "${target_file}" ]]; then
        if [[ ${FORCE} == true ]]; then
            rm -f "${target_file}"
            if [[ ${VERBOSE} == true ]]; then
                print_warning "Removed existing file: ${filename}"
            fi
        else
            if [[ ${VERBOSE} == true ]]; then
                print_warning "Skipped existing file: ${filename} (use --force to overwrite)"
            fi
            skip_count=$((skip_count + 1))
            continue
        fi
    fi
    
    # Create symbolic link using absolute path
    abs_cmd_file="$(cd "$(dirname "${cmd_file}")" && pwd)/$(basename "${cmd_file}")"
    if ln -s "${abs_cmd_file}" "${target_file}" 2>/dev/null; then
        if [[ ${VERBOSE} == true ]]; then
            print_success "Created link: ${filename}"
        fi
        link_count=$((link_count + 1))
    else
        print_error "Failed to create link: ${filename}"
        if [[ ${VERBOSE} == true ]]; then
            print_error "Source: ${abs_cmd_file}"
            print_error "Target: ${target_file}"
        fi
        exit 1
    fi
done

# Display results
echo
print_success "Setup completed!"
print_info "Created links: ${link_count}"
if [[ ${skip_count} -gt 0 ]]; then
    print_info "Skipped files: ${skip_count}"
fi

# Display available slash commands
echo
print_info "Available slash commands:"
for cmd_file in "${TARGET_DIR}"/*.md; do
    if [[ -f "${cmd_file}" ]]; then
        cmd_name=$(basename "${cmd_file}" .md)
        echo "  /${cmd_name}"
    fi
done

echo
print_info "You can now use these commands in Claude Code"
print_info "Example: /commit for intelligent git commits"
