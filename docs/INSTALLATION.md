# Installation Guide

## Fresh Project (No existing .claude)

### Global Installation (Recommended)
```bash
# 1. Clone Cohesion
git clone https://github.com/khenbest/Cohesion
cd Cohesion

# 2. Install globally
./install.sh

# 3. In any project, initialize
cd ~/your-project
cohesion init
```

### Local Installation
```bash
# In your project
cd ~/your-project

# Clone Cohesion
git clone https://github.com/khenbest/Cohesion

# Use directly
./Cohesion/cohesion init
```

## Existing Project (Has .claude already)

### Option 1: Backup and Replace
```bash
# Backup existing .claude
mv .claude .claude.backup

# Initialize Cohesion
cohesion init

# Merge any needed files from backup
# (custom context, etc.)
```

### Option 2: Upgrade in Place
```bash
# Initialize Cohesion (will preserve existing files)
cohesion init

# Your existing settings.json will be backed up
# as settings.json.backup
```

## Upgrading

```bash
# In your project
cohesion upgrade

# This preserves your current state and updates hooks
```

## Uninstalling

### Remove from Project
```bash
# In your project
cohesion uninstall

# This removes Cohesion but preserves other .claude files
```

### Remove Global Installation
```bash
rm -rf ~/.cohesion
# Remove PATH entry from ~/.bashrc or ~/.zshrc
```

## Troubleshooting

### Hooks not working?
```bash
# Check permissions
ls -la .claude/hooks/*.sh

# Make executable
chmod +x .claude/hooks/*.sh
```

### State not persisting?
```bash
# Check state directory
ls -la .claude/state/

# Reset manually
rm -f .claude/state/*
cohesion reset
```