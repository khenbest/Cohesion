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
git clone https://github.com/khenbest/Cohesion.git
cd Cohesion

# For global installation:
./install.sh

# For project-local installation:
# Copy to your project first
cp -r .claude ~/your-project/
cp cohesion ~/your-project/
cp install.sh ~/your-project/
cd ~/your-project
./install.sh
```

### Method 2: Direct Download

```bash
# Download latest release
curl -L https://github.com/khenbest/Cohesion/archive/main.tar.gz | tar xz
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
for hook in session-start session-end pre-tool-use post-tool-use detect-intent save-progress pre-compact; do
  curl -O https://raw.githubusercontent.com/khenbest/Cohesion/main/.claude/hooks/${hook}.sh
done

# Get utilities
curl -o utils/state.sh https://raw.githubusercontent.com/khenbest/Cohesion/main/.claude/utils/state.sh

# Get settings
curl -O https://raw.githubusercontent.com/khenbest/Cohesion/main/.claude/settings.local.json

# Get installer
curl -O https://raw.githubusercontent.com/khenbest/Cohesion/main/install.sh

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
git clone https://github.com/khenbest/Cohesion.git
cd Cohesion
./install.sh

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
git clone https://github.com/khenbest/Cohesion.git
cd Cohesion
./install.sh

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
git clone https://github.com/khenbest/Cohesion.git
cd Cohesion
./install.sh
```

### Windows (Git Bash)

```bash
# Note: Limited functionality without full bash
# Download jq for Windows from https://github.com/jqlang/jq/releases

# In Git Bash:
git clone https://github.com/khenbest/Cohesion.git
cd Cohesion

# May need to adjust paths in scripts
./install.sh
```

## Protection System

### Built-in Safety Features

Cohesion includes comprehensive protection mechanisms:

```bash
# Protected Directories (cannot be modified):
# .claude, .git, node_modules, .next, build, dist

# Protected Files (cannot be modified):
# .env, .env.local, .env.production

# Check protection status
./cohesion protection-status

# Verify system integrity
./cohesion safety-check
```

### Safety Commands

```bash
# Run comprehensive safety check
./cohesion safety-check

# Expected output:
# 🛡️  Cohesion Safety Check
# ✅ Installation integrity verified
# ✅ Hook system operational  
# ✅ State management functional
# ✅ Protection system active
```

## Configuration

### Basic Configuration

The installer creates a default configuration at `.claude/settings.local.json`:

```json
{
  "permissions": {
    "allow": [
      "Read(**)",
      "Grep(**)", 
      "Glob(**)",
      "Write(**)",
      "Edit(**)",
      "MultiEdit(**)",
      "Bash(git status)",
      "Bash(./cohesion:*)"
    ],
    "deny": [
      "Read(./.env*)",
      "Write(./.env*)",
      "Bash(rm -rf:*)",
      "Bash(sudo:*)"
    ],
    "ask": [
      "Bash(git push:*)",
      "Bash(git commit:*)"
    ]
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
ls -la .claude/settings.local.json

# Check permissions
find .claude -name "*.sh" -exec ls -l {} \;

# Verify protection system
./cohesion safety-check
./cohesion protection-status
```

### Step 2: Test CLI

```bash
# Test cohesion command
./cohesion status

# Expected output:
# 🎯 Cohesion Status
# State: DISCOVER 🔍
# Session: active
# Duration: 0m

# Test safety check
./cohesion safety-check

# Test protection status
./cohesion protection-status
```

### Step 3: Test Hooks

```bash
# Test session start hook
.claude/hooks/session-start.sh

# Check flag-based state system
ls -la .claude/state/flags/

# Test state transitions
./cohesion duo-status
```

### Step 4: Claude Code Integration

1. **Restart Claude Code**
2. Start a new conversation
3. Check that DUO Protocol is active:

```bash
# Check current state
./cohesion status

# View DUO Protocol status
./cohesion duo-status

# Watch state transitions (optional)
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
# Check state directories exist
mkdir -p .claude/state/flags

# Check flag-based state system
ls -la .claude/state/flags/

# Reset state using CLI
./cohesion reset

# Verify state system
./cohesion safety-check
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
# Check DUO Protocol status
./cohesion duo-status

# Run comprehensive diagnostics
./cohesion safety-check

# Enable debug output in hooks (if needed)
echo 'echo "DEBUG: Hook triggered at $(date)" >&2' >> .claude/hooks/session-start.sh

# Run with trace
bash -x .claude/hooks/session-start.sh

# Check logs
tail -f .claude/state/*.log
```

### Getting Help

1. Check [Troubleshooting Guide](guides/TROUBLESHOOTING.md)
2. Search [GitHub Issues](https://github.com/khenbest/Cohesion/issues)
3. Ask in [Discussions](https://github.com/khenbest/Cohesion/discussions)
4. Contact support

---

**Successfully installed?** Continue to the [Tutorial](TUTORIAL.md) →