# 📦 Installation Guide

> Complete installation instructions for Cohesion

## Table of Contents

1. [System Requirements](#system-requirements)
2. [Installation Methods](#installation-methods)
3. [Platform-Specific Instructions](#platform-specific-instructions)
4. [Configuration](#configuration)
5. [Verification](#verification)
6. [Upgrading](#upgrading)
7. [Uninstalling](#uninstalling)
8. [Troubleshooting](#troubleshooting)

## System Requirements

### Required
- **Claude Code** Desktop app or VS Code extension
- **Bash** 4.0+ (Mac, Linux, or WSL on Windows)
- **File system** with execute permissions

### Recommended
- **jq** 1.6+ for JSON processing (10x faster)
- **git** for version control
- **curl** or **wget** for downloads

### Checking Requirements

```bash
# Check bash version
bash --version

# Check if jq is installed
which jq || echo "jq not found (optional)"

# Check Claude Code
# Should be running this from within Claude Code
```

## Installation Methods

### Method 1: Git Clone (Recommended)

```bash
# Clone the repository
git clone https://github.com/yourusername/cohesion.git
cd cohesion

# Copy to your project
cp -r .claude ~/your-project/.claude
cp cohesion ~/your-project/cohesion

# Make executable
cd ~/your-project
chmod +x .claude/install.sh
chmod +x cohesion

# Run installer
./.claude/install.sh
```

### Method 2: Direct Download

```bash
# Download latest release
curl -L https://github.com/yourusername/cohesion/archive/main.tar.gz | tar xz
cd cohesion-main

# Copy to your project
cp -r .claude ~/your-project/.claude
cp cohesion ~/your-project/cohesion

# Install
cd ~/your-project
chmod +x .claude/install.sh
./.claude/install.sh
```

### Method 3: Manual Installation

```bash
# Create directory structure
mkdir -p ~/your-project/.claude/{hooks,utils,state}

# Download each file individually
cd ~/your-project/.claude

# Get hooks
for hook in session-start pre-tool-use post-tool-use detect-intent save-progress; do
  curl -O https://raw.githubusercontent.com/yourusername/cohesion/main/.claude/hooks/${hook}.sh
done

# Get utilities
curl -o utils/state.sh https://raw.githubusercontent.com/.../utils/state.sh

# Get settings
curl -O https://raw.githubusercontent.com/.../settings.json

# Get installer
curl -O https://raw.githubusercontent.com/.../install.sh

# Make executable
chmod +x hooks/*.sh utils/*.sh install.sh

# Run installer
./install.sh
```

## Platform-Specific Instructions

### macOS

```bash
# Install jq (optional but recommended)
brew install jq

# Install Cohesion
git clone https://github.com/yourusername/cohesion.git
cd cohesion
cp -r .claude ~/your-project/.claude
cd ~/your-project
./.claude/install.sh

# Add to PATH (optional)
echo 'export PATH="$PATH:$HOME/your-project"' >> ~/.zshrc
source ~/.zshrc
```

### Linux (Ubuntu/Debian)

```bash
# Install dependencies
sudo apt-get update
sudo apt-get install -y jq git curl

# Install Cohesion
git clone https://github.com/yourusername/cohesion.git
cd cohesion
cp -r .claude ~/your-project/.claude
cd ~/your-project
./.claude/install.sh

# Add to PATH (optional)
echo 'export PATH="$PATH:$HOME/your-project"' >> ~/.bashrc
source ~/.bashrc
```

### Windows (WSL)

```bash
# First, ensure WSL is installed and updated
wsl --update

# In WSL terminal:
# Install dependencies
sudo apt-get update
sudo apt-get install -y jq git

# Install Cohesion
git clone https://github.com/yourusername/cohesion.git
cd cohesion
cp -r .claude /mnt/c/Users/YourName/your-project/.claude
cd /mnt/c/Users/YourName/your-project
./.claude/install.sh
```

### Windows (Git Bash)

```bash
# Note: Limited functionality without full bash
# Download jq for Windows from https://github.com/jqlang/jq/releases

# In Git Bash:
git clone https://github.com/yourusername/cohesion.git
cd cohesion
cp -r .claude ~/your-project/.claude
cd ~/your-project

# May need to adjust paths in scripts
./.claude/install.sh
```

## Configuration

### Basic Configuration

The installer creates a default configuration at `.claude/settings.json`:

```json
{
  "hooks": {
    "sessionStarted": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/session-start.sh"
      }]
    }],
    "preToolUse": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/pre-tool-use.sh"
      }]
    }]
  }
}
```

### Advanced Configuration

```bash
# Edit settings
vim .claude/settings.json

# Customize state transitions
vim .claude/hooks/detect-intent.sh

# Modify tool permissions
vim .claude/hooks/pre-tool-use.sh
```

### Environment Variables

```bash
# Optional: Set custom state directory
export COHESION_STATE_DIR="$HOME/.cohesion"

# Optional: Set session timeout (seconds)
export COHESION_SESSION_TIMEOUT=86400  # 24 hours

# Optional: Enable debug logging
# Add debug output to hooks
echo 'echo "DEBUG: Hook triggered" >&2' >> .claude/hooks/session-start.sh
```

## Verification

### Step 1: Check Installation

```bash
# Verify files exist
ls -la .claude/hooks/*.sh
ls -la .claude/utils/*.sh
ls -la .claude/settings.json

# Check permissions
find .claude -name "*.sh" -exec ls -l {} \;
```

### Step 2: Test CLI

```bash
# Test cohesion command
./cohesion status

# Expected output:
# 🎯 Cohesion Status
# State: DISCOVER
# Session: active
# Duration: 0m
```

### Step 3: Test Hooks

```bash
# Test session start hook
.claude/hooks/session-start.sh

# Test state management
.claude/utils/state.sh get
.claude/utils/state.sh set UNLEASH "Test"
.claude/utils/state.sh get
```

### Step 4: Claude Code Integration

1. **Restart Claude Code**
2. Start a new conversation
3. Check that hooks are firing:

```bash
# Watch hook activity
tail -f .claude/state/*.log
```

## Upgrading

### Backup Current Installation

```bash
# Backup existing configuration
cp -r .claude .claude.backup

# Save current state
cp -r .claude/state .claude/state.backup
```

### Upgrade Process

```bash
# Get latest version
cd ~/cohesion
git pull origin main

# Copy new files (preserves state)
cp .claude/hooks/*.sh ~/your-project/.claude/hooks/
cp .claude/utils/*.sh ~/your-project/.claude/utils/

# Preserve your settings
# Manual merge if settings.json changed

# Re-run installer
cd ~/your-project
./.claude/install.sh
```

### Version Check

```bash
# Check version (if supported)
cohesion version

# Or check git commit
cd ~/cohesion && git log -1 --oneline
```

## Uninstalling

### Complete Removal

```bash
# Remove Cohesion files
rm -rf .claude
rm -f cohesion

# Clean up logs and state
rm -rf .cohesion  # If using custom state dir
```

### Disable Temporarily

```bash
# Rename settings to disable hooks
mv .claude/settings.json .claude/settings.json.disabled

# Or set to UNLEASH permanently
cohesion unleash
echo "PERMANENT_UNLEASH=true" >> .claude/state/session.json
```

## Troubleshooting

### Common Issues

#### Hooks Not Firing

```bash
# Check Claude Code recognizes settings
cat .claude/settings.json

# Verify hook permissions
chmod +x .claude/hooks/*.sh

# Test hook manually
echo '{"tool_name":"Write"}' | .claude/hooks/pre-tool-use.sh
```

#### Permission Denied

```bash
# Fix all permissions
find .claude -name "*.sh" -exec chmod +x {} \;
chmod +x cohesion

# Check directory permissions
chmod 755 .claude .claude/hooks .claude/utils
chmod 644 .claude/settings.json
```

#### State Not Persisting

```bash
# Check state directory exists
mkdir -p .claude/state

# Check write permissions
touch .claude/state/test && rm .claude/state/test

# Reset state
rm -rf .claude/state/*
cohesion reset
```

#### jq Not Found

```bash
# Install jq for your platform
# Mac: brew install jq
# Linux: apt-get install jq

# Or use fallback mode (slower)
# Edit hooks to use grep/sed instead
```

### Debug Mode

```bash
# Enable debug output
# Add debug output to hooks
echo 'echo "DEBUG: Hook triggered" >&2' >> .claude/hooks/session-start.sh

# Run with trace
bash -x .claude/hooks/session-start.sh

# Check logs
tail -f .claude/state/*.log
```

### Getting Help

1. Check [Troubleshooting Guide](guides/TROUBLESHOOTING.md)
2. Search [GitHub Issues](https://github.com/yourusername/cohesion/issues)
3. Ask in [Discussions](https://github.com/yourusername/cohesion/discussions)
4. Contact support

---

**Successfully installed?** Continue to the [Tutorial](TUTORIAL.md) →