# ⚙️ Configuration Reference

> How to customize Cohesion for your workflow

## Configuration Overview

Cohesion v1.0 uses simple bash scripts that you can directly edit to customize behavior. No complex configuration files needed!

```
.claude/
├── settings.json         # Hook registration (don't edit)
├── hooks/
│   ├── detect-intent.sh # Customize keywords here
│   ├── pre-tool-use.sh  # Customize tool permissions here
│   └── *.sh            # Other hook scripts
└── state/
    └── session.json    # Runtime state (auto-managed)
```

## Customizing Keywords

Edit `.claude/hooks/detect-intent.sh` to add your own trigger words:

### Approval Keywords (DISCOVER → UNLEASH)
```bash
detect_approval() {
    case "$MESSAGE" in
        *approved*|*lgtm*|*"looks good"*|*proceed*|*"ship it"*|*"go ahead"*)
            return 0
            ;;
        # Add your keywords here:
        *"let's go"*|*"do it"*|*"yes please"*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}
```

### Collaboration Keywords (Any → OPTIMIZE)
```bash
detect_consultation() {
    case "$MESSAGE" in
        # Blockers
        *stuck*|*blocked*|*help*|*"can't"*|*"cannot"*)
            return 0
            ;;
        # Uncertainty
        *unclear*|*clarify*|*"not sure"*|*ambiguous*)
            return 0
            ;;
        # Add your triggers here:
        *"wait"*|*"hold on"*|*"timeout"*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}
```

## Customizing Tool Permissions

Edit `.claude/hooks/pre-tool-use.sh` to control what tools are allowed in each state:

### DISCOVER State Permissions
```bash
DISCOVER)
    case "$TOOL" in
        # Denied tools
        Write|Edit|MultiEdit|NotebookEdit)
            # Block these tools
            deny_tool "Cannot modify in DISCOVER"
            ;;
        
        # Allowed tools
        Read|Grep|Glob|Bash)
            echo '{"continue": true}'
            ;;
            
        # Add custom tool rules:
        YourCustomTool)
            if [ "$SOME_CONDITION" = "true" ]; then
                echo '{"continue": true}'
            else
                deny_tool "Not allowed in DISCOVER"
            fi
            ;;
    esac
    ;;
```

### UNLEASH State Permissions
```bash
UNLEASH)
    # All tools allowed by default
    echo '{"continue": true}'
    
    # Or add restrictions even in UNLEASH:
    case "$TOOL" in
        DangerousTool)
            deny_tool "Too dangerous even in UNLEASH"
            ;;
        *)
            echo '{"continue": true}'
            ;;
    esac
    ;;
```

## Customizing Bash Commands

Edit `.claude/hooks/bash-validator.sh` to control bash command permissions:

### Add Safe Commands
```bash
# In DISCOVER state, allow readonly commands
if echo "$COMMAND" | grep -qE '^(ls|pwd|cat|head|tail|grep|YOUR_SAFE_COMMAND)(\s|$)'; then
    echo '{"continue": true}'
    exit 0
fi
```

### Block Dangerous Commands
```bash
# Block write operations
if echo "$COMMAND" | grep -qE '(rm|mv|cp|YOUR_DANGEROUS_COMMAND)'; then
    deny_command "Command not allowed in DISCOVER"
    exit 0
fi
```

## Customizing State Messages

Edit `.claude/hooks/detect-intent.sh` to customize state transition messages:

```bash
# When transitioning to UNLEASH
echo '{"continue": true, "systemMessage": "🚀 Your custom UNLEASH message here!"}'

# When transitioning to OPTIMIZE
echo '{"continue": true, "systemMessage": "🤝 Your custom OPTIMIZE message here!"}'
```

## Adding Custom Hooks

To add a new hook, create a script in `.claude/hooks/` and register it in `settings.json`:

### 1. Create Your Hook
```bash
#!/bin/bash
# .claude/hooks/my-custom-hook.sh

# Your custom logic here
echo '{"continue": true}'
```

### 2. Make It Executable
```bash
chmod +x .claude/hooks/my-custom-hook.sh
```

### 3. Register in settings.json
```json
{
  "hooks": {
    "userPromptReceived": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/my-custom-hook.sh"
          }
        ]
      }
    ]
  }
}
```

## State File Structure

The state is stored in `.claude/state/session.json`:

```json
{
  "state": "DISCOVER",
  "timestamp": 1234567890,
  "last_activity": 1234567900
}
```

You can manually edit this file if needed:
```bash
# Reset to DISCOVER
echo '{"state": "DISCOVER", "timestamp": '$(date +%s)'}' > .claude/state/session.json
```

## Manual State Control

Use the CLI tool or state utility directly:

```bash
# Using CLI
./cohesion reset       # Return to DISCOVER
./cohesion duo-status  # Check detailed state
./cohesion safety-check # Verify installation

# State transitions via keywords in conversation:
# "approved" → UNLEASH state
# "unclear" → OPTIMIZE state
# "reset" → DISCOVER state

# Using state utility
.claude/utils/state.sh set DISCOVER "Manual reset"
.claude/utils/state.sh get  # Check current state
```

## Troubleshooting

### Hooks Not Working?
```bash
# Check permissions
ls -la .claude/hooks/*.sh

# Make executable
chmod +x .claude/hooks/*.sh

# Test a hook manually
.claude/hooks/detect-intent.sh
```

### State Stuck?
```bash
# Check current state
cat .claude/state/session.json

# Force reset
rm .claude/state/session.json
./cohesion reset
```

### Debug Mode
Add debug output to any hook:
```bash
# Add to any hook script
echo "DEBUG: Current state is $STATE" >&2
echo "DEBUG: Tool requested is $TOOL" >&2
```

## What's NOT Configurable (Yet)

These features are hard-coded in v1.0:
- Session timeout (24 hours)
- State transition rules
- Log file locations
- Backup count (5)

---

*For v1.0, we kept configuration simple - just edit the bash scripts directly!*