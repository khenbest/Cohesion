#!/usr/bin/env bash
# Idempotent settings merger for Claude Code
# Merges Cohesion settings with existing user settings

set -euo pipefail

CLAUDE_SETTINGS="${1:-$HOME/.claude/settings.json}"
BACKUP_SUFFIX=".backup.$(date +%s)"

# Check if jq is available
if ! command -v jq >/dev/null 2>&1; then
    echo "Error: jq is required for settings merging" >&2
    exit 1
fi

# Our desired Cohesion settings
COHESION_SETTINGS=$(cat << 'EOF'
{
  "permissions": {
    "defaultMode": "ask",
    "allow": [
      "Read(./**)",
      "Glob(./**)", 
      "Grep(./**)",
      "TodoWrite",
      "Task"
    ],
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)",
      "Bash(rm -rf /)",
      "Bash(sudo rm -rf *)"
    ]
  },
  "customInstructions": {
    "globalClaudeMd": "~/CLAUDE.md",
    "autoLoadGlobal": true
  },
  "telemetry": {
    "enabled": false
  }
}
EOF
)

# Function to merge settings
merge_settings() {
    local existing="$1"
    local new="$2"
    
    # Use jq to merge, with existing taking precedence for conflicts
    # but adding missing allow/deny rules
    jq -s '
    .[0] as $existing | .[1] as $new |
    $existing * $new |
    .permissions.allow = (
        ($existing.permissions.allow // []) + 
        ($new.permissions.allow // []) | 
        unique
    ) |
    .permissions.deny = (
        ($existing.permissions.deny // []) + 
        ($new.permissions.deny // []) | 
        unique
    )
    ' <(echo "$existing") <(echo "$new")
}

# Main logic
if [[ -f "$CLAUDE_SETTINGS" ]]; then
    echo "Found existing settings at $CLAUDE_SETTINGS"
    
    # Backup existing
    cp "$CLAUDE_SETTINGS" "${CLAUDE_SETTINGS}${BACKUP_SUFFIX}"
    echo "Backed up to ${CLAUDE_SETTINGS}${BACKUP_SUFFIX}"
    
    # Read existing settings
    EXISTING=$(cat "$CLAUDE_SETTINGS")
    
    # Merge settings
    echo "Merging Cohesion settings..."
    MERGED=$(merge_settings "$EXISTING" "$COHESION_SETTINGS")
    
    # Show diff
    echo ""
    echo "Changes to be applied:"
    diff -u <(echo "$EXISTING" | jq -S .) <(echo "$MERGED" | jq -S .) || true
    
    # Write merged settings
    echo "$MERGED" | jq -S . > "$CLAUDE_SETTINGS"
    echo ""
    echo "✓ Settings merged successfully"
    
    # Report what rules come from where
    echo ""
    echo "Permission sources:"
    echo "  • allow rules: $(echo "$MERGED" | jq -r '.permissions.allow | length') total"
    echo "  • deny rules: $(echo "$MERGED" | jq -r '.permissions.deny | length') total"
    echo "  • defaultMode: $(echo "$MERGED" | jq -r '.permissions.defaultMode // "ask"')"
    echo ""
    echo "Verify in Claude Code with: /permissions"
else
    echo "No existing settings found, creating new at $CLAUDE_SETTINGS"
    mkdir -p "$(dirname "$CLAUDE_SETTINGS")"
    echo "$COHESION_SETTINGS" | jq -S . > "$CLAUDE_SETTINGS"
    echo "✓ Created new settings file"
fi

# Check for CLAUDE.md
if [[ ! -f "$HOME/CLAUDE.md" ]]; then
    echo ""
    echo "Creating global CLAUDE.md..."
    cat > "$HOME/CLAUDE.md" << 'EOF'
# Global Claude Code Instructions (Cohesion-Aware)

## Cohesion Detection
Check for `.claude/hooks/` to detect Cohesion projects.

### With Cohesion:
Follow DUO Protocol - check `.claude/state/` for mode.

### Without Cohesion:
Be cautious with destructive operations.

## Quick Reference
- `cohesion status` - Check state
- `cohesion init` - Initialize project
- `/permissions` - View active permissions
- `/config reload` - Reload settings
EOF
    echo "✓ Created ~/CLAUDE.md"
elif ! grep -q "Cohesion" "$HOME/CLAUDE.md"; then
    echo ""
    echo "Appending Cohesion section to existing CLAUDE.md..."
    cat >> "$HOME/CLAUDE.md" << 'EOF'

## Cohesion Quick Reference
- `cohesion status` - Check state
- `/permissions` - View active permissions
- `/config reload` - Reload settings after state change
EOF
    echo "✓ Updated ~/CLAUDE.md"
else
    echo "✓ CLAUDE.md already contains Cohesion instructions"
fi