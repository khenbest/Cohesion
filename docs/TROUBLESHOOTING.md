# Troubleshooting Guide

## Common Issues and Solutions

### 1. Hook Error Messages Not Displaying

**Symptom**: You see "⏺ Execution stopped by hook" without your custom error message.

**Solution**: This is a known Claude Code limitation. The error messages are being sent correctly but may not always display. Use `cohesion debug` to verify state.

### 2. Hooks Not Firing

**Symptom**: State transitions don't work, tools aren't being blocked/allowed properly.

**Check**:
```bash
# Verify hooks are executable
ls -la .claude/hooks/*.sh

# Make them executable if needed
chmod +x .claude/hooks/*.sh

# Run debug to check status
cohesion debug
```

### 3. State Not Persisting Between Sessions

**Symptom**: Claude Code always starts in DISCOVER state.

**Check**:
```bash
# Check state files exist
ls -la .claude/state/

# Check permissions
ls -ld .claude/state/

# Manually check/set state
touch .claude/state/UNLEASHED  # Force UNLEASH state
cohesion status
```

### 4. Missing jq Dependency

**Symptom**: "Missing dependency: jq" error message.

**Solution**:
```bash
# Mac
brew install jq

# Ubuntu/Debian
apt-get install jq

# Check installation
jq --version
```

### 5. Git Commands Blocked in UNLEASH

**Symptom**: Git commands fail even in UNLEASH state.

**Check**:
```bash
# Remove any override settings
rm -f .claude/settings.local.json

# Verify state
cohesion status

# Reset and try again
cohesion reset
# Say "approved" to enter UNLEASH
```

### 6. Protected Path Errors

**Symptom**: Can't modify certain files even in UNLEASH.

**Solution**:
```bash
# Check protected paths
cat .claude/protected.conf

# Remove problematic patterns (temporarily)
# Edit .claude/protected.conf and comment out the line

# Or force override for specific file
# Remove the pattern from protected.conf
```

### 7. Wrong State After Keyword

**Symptom**: Saying "approved" doesn't switch to UNLEASH.

**Debug Steps**:
1. Check current state: `cohesion status`
2. Try explicit reset: `cohesion reset`
3. Use exact keyword: "approved" (lowercase)
4. Check debug output: `DEBUG=1 cohesion status`

### 8. Installation Issues

**Symptom**: "cohesion: command not found" after installation.

**Solution**:
```bash
# For global installation
./install.sh
source ~/.bashrc  # or ~/.zshrc

# Verify installation
which cohesion
cohesion help

# For local installation
./Cohesion/cohesion init
```

## Debug Mode

Enable debug mode for detailed information:

```bash
# Run debug command
cohesion debug

# Enable debug logging
DEBUG=1 cohesion status

# Enable full logging
COHESION_LOG=1 DEBUG=1 cohesion status
# Check logs at .claude/logs/cohesion.log
```

## Manual State Management

If automatic transitions fail, you can manually manage state:

```bash
# Force UNLEASH state
rm -f .claude/state/OPTIMIZE
touch .claude/state/UNLEASHED

# Force OPTIMIZE state
rm -f .claude/state/UNLEASHED
touch .claude/state/OPTIMIZE

# Force DISCOVER state
rm -f .claude/state/UNLEASHED .claude/state/OPTIMIZE

# Verify
cohesion status
```

## Hook Testing

Test individual hooks manually:

```bash
# Test session-start hook
echo '{}' | .claude/hooks/session-start.sh

# Test user-prompt hook (should trigger UNLEASH)
echo '{"prompt":"approved"}' | .claude/hooks/user-prompt.sh

# Test pre-tool-use hook
echo '{"tool_name":"Write","tool_input":{"file_path":"test.txt"}}' | .claude/hooks/pre-tool-use.sh
```

## Getting Help

1. Run `cohesion help` for command reference
2. Run `cohesion debug` for system information
3. Check this troubleshooting guide
4. Review the README.md for usage instructions

## Emergency Reset

If Cohesion is completely broken:

```bash
# Complete reset
rm -rf .claude/state
rm -rf .claude/logs
cohesion reset

# Full reinstall
cohesion uninstall
cohesion init
```