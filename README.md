# .claude-code-slash-commands

My shareable Claude Code slash commands, using symbolic links to share commands across multiple projects.

## 📋 Available Slash Commands

| Command | Description |
|---------|-------------|
| `/commit` | Execute intelligent Git commits |
| `/review` | Perform code reviews with improvement suggestions |
| `/refactor` | Propose and execute code refactoring |

## 🚀 Quick Start

### 1. Installation

```sh
# Clone the repository
git clone https://github.com/sugarshin/.claude-code-slash-commands.git ~/.claude-code-slash-commands

# Run the installation script to configure shell
~/.claude-code-slash-commands/utils/install.sh
```

### 2. Project Setup

```sh
# Navigate to your project directory
cd /path/to/your/project

# Run the setup script
ccsc-setup
# or
~/.claude-code-slash-commands/setup.sh
```

### 3. Usage in Claude Code

```sh
# Example: Intelligent commit
/commit

# Example: Code review
/review src/components/Button.tsx

# Example: Refactoring analysis
/refactor
```

## 📁 Directory Structure

```
.claude-code-slash-commands/
├── README.md              # This file
├── setup.sh               # Project setup script
├── commands/              # Slash commands files
│   ├── commit.md          # Git commit helper
│   ├── review.md          # Code review assistant
│   └── refactor.md        # Refactoring support
├── templates/             # Templates for creating new commands
│   └── command-template.md
└── utils/                 # Management utilities
    ├── install.sh         # Initial installation
    ├── update.sh          # Command updates
    └── uninstall.sh       # Uninstallation
```

## 🔧 Detailed Usage

### Slash Command Details

#### `/commit` - Smart Git Commit

```sh
# Basic usage
/commit

# Custom message
/commit "feat: add new feature"
```

- Check current git status
- Analyze changes to determine commit type
- Generate Conventional Commits format messages
- Execute commits automatically

#### `/review` - Code Review Assistant

```sh
# Overall review
/review

# Review specific file
/review src/components/Button.tsx

# Review specific feature
/review "認証機能"
```

- Analyze code quality, performance, and security
- Provide specific improvement suggestions
- Present Before/After comparison examples

#### `/refactor` - Code Refactoring

```sh
# Overall refactoring analysis
/refactor

# Refactor specific file
/refactor src/utils/helper.ts

# Performance-focused refactoring
/refactor --performance
```

- Structural improvements and naming enhancements
- Performance optimization
- Technical debt identification and improvement suggestions

## 🛠 Management Commands

### Setup

```sh
# Basic setup
./setup.sh

# Overwrite existing commands
./setup.sh --force

# Verbose logging
./setup.sh --verbose
```

### Updates

```sh
# Update commands to latest version
ccsc-update

# Update project symbolic links as well
ccsc-update --update-projects

# Update to specific branch
ccsc-update --branch develop
```

### Uninstallation

```sh
# Basic uninstallation
~/.claude-code-slash-commands/utils/uninstall.sh

# Also remove from shell configuration
~/.claude-code-slash-commands/utils/uninstall.sh --remove-shell-config

# Also remove project symbolic links
~/.claude-code-slash-commands/utils/uninstall.sh --remove-project-links
```

## 📝 Creating New Slash Commands

### 1. Use Template

```sh
cp templates/command-template.md commands/mycommand.md
```

### 2. Edit Slash Command File

```markdown
---
description: "Command description"
allowed-tools: ["Bash", "Read", "Edit"]
---

# My Custom Slash Command

Detailed description and usage instructions...

Use $ARGUMENTS to get user arguments.
```

### 3. Use in Projects

```sh
# Re-run setup script
ccsc-setuop --force

# Use in Claude Code
/mycommand
```

## 🔍 Troubleshooting

### Common Issues

#### Command Not Found

```sh
# Check symbolic links
ls -la .claude/commands/

# Re-run setup script
ccsc-setup --force
```

#### Permission Errors

```sh
# Check script execution permissions
chmod +x ~/.claude-code-slash-commands/setup.sh
chmod +x ~/.claude-code-slash-commands/utils/*.sh
```

#### Old Version Commands Running

```sh
# Update to latest version
ccsc-update

# Restart Claude Code
```

## 🧪 Development & Testing

### Prerequisites

```sh
# Install development dependencies
brew install shellcheck bats-core  # macOS
```

### Running Tests

```sh
# Run all tests
make test

# Run linting
make lint

# Run both lint and test
make check

# Install dependencies
make install
```

### Test Structure

- `tests/setup.bats` - Tests for main setup script
- `tests/install.bats` - Tests for installation process
- `tests/commands.bats` - Tests for command file structure
- `tests/helpers/test_helper.bash` - Common test utilities

### Continuous Integration

The project uses GitHub Actions for CI/CD:
- ✅ Shell script linting with Shellcheck
- ✅ Automated testing with Bats
- ✅ Cross-platform testing (Ubuntu, macOS)
- ✅ Integration testing
- ✅ Security scanning

## 📜 License

This project is published under the MIT License. See [LICENSE](LICENSE) file for details.

## 🔗 Related Links

- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)
- [Claude Code Slash Commands](https://docs.anthropic.com/en/docs/claude-code/slash-commands)
- [Conventional Commits](https://conventionalcommits.org/)
- [Shellcheck](https://www.shellcheck.net/)
- [Bats Testing Framework](https://bats-core.readthedocs.io/)
