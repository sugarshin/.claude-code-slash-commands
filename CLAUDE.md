# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a shareable repository of Claude Code slash commands that can be symlinked across multiple projects. The repository contains pre-built slash commands for common development tasks like intelligent Git commits, code reviews, and refactoring.

## Architecture

The repository follows a simple structure:

- `commands/` - Contains the actual slash command files (.md format)
- `utils/` - Management utilities for installation and updates
- `templates/` - Template files for creating new commands
- `setup.sh` - Main project setup script

### Key Components

#### Slash Commands (`commands/`)

- **commit.md** - Intelligent Git commit with Conventional Commits format
- **review.md** - Comprehensive code review with quality, performance, and security analysis
- **refactor.md** - Code refactoring suggestions and implementation

#### Management Scripts (`utils/`)

- **install.sh** - System-wide installation script
- **update.sh** - Update mechanism for pulling latest changes
- **uninstall.sh** - Clean removal of commands and configurations

#### Setup Process

The `setup.sh` script creates symbolic links from the commands directory to `.claude/commands/` in target projects.

## Command Usage

### Setup Commands

```sh
# Install system-wide (adds to PATH and creates aliases)
~/.claude-code-slash-commands/utils/install.sh

# Setup in a project directory
ccsc-setup
# or
~/.claude-code-slash-commands/setup.sh

# Update commands to latest version
ccsc-update

# Force overwrite existing commands
ccsc-setup --force
```

### Management Commands

```sh
# Install system-wide
~/.claude-code-slash-commands/utils/install.sh

# Update to latest version
ccsc-update

# Update with project links
ccsc-update --update-projects

# Remove installation
~/.claude-code-slash-commands/utils/uninstall.sh
```

## Slash Command Architecture

Each slash command is a Markdown file with:

- YAML frontmatter defining description and allowed tools
- Detailed usage instructions and examples
- Implementation logic that references `$ARGUMENTS` for user input

### Command Structure

```markdown
---
description: "Command description"
allowed-tools: ["Bash", "Read", "Edit", "Grep"]
---

# Command Name
Implementation details...

Use $ARGUMENTS to get user arguments.
```

## Creating New Commands

1. Copy the template: `cp templates/command-template.md commands/newcommand.md`
2. Edit the frontmatter and implementation
3. Run `ccsc-setup --force` to update project links
4. Test the command with `/newcommand`

## Development Workflow

### For Command Development

- Edit commands in the `commands/` directory
- Test changes by running `ccsc-setup --force` in test projects
- Commands are immediately available after setup

### For Script Development

- Scripts in `utils/` handle installation and management
- Main setup script (`setup.sh`) handles symbolic linking
- Scripts use colored output functions for user feedback

## File Management

The system uses symbolic links to share commands across projects:

- Source files remain in `~/.claude-code-slash-commands/commands/`
- Projects get symbolic links in `.claude/commands/`
- Updates to source files affect all linked projects

## Error Handling

Scripts include:

- Validation of Git repositories (with optional bypass)
- Existence checks for required directories
- Proper error messages with colored output
- Graceful handling of existing files (with --force option)

## Shell Integration

The installation script adds:

- PATH entry for script access
- Convenient aliases (`ccsc-setup`, `ccsc-update`)
- Shell configuration updates for Zsh

## Maintenance

Regular maintenance involves:

- Updating command implementations
- Testing commands across different project types
- Keeping management scripts current
- Updating documentation and examples

