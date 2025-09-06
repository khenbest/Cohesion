#!/bin/bash
# Cohesion - Bash Command Validator
# Fast validation for Bash commands in DISCOVER state

set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# Detect if we're in global or local mode
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -d "$HOME/.cohesion" ] && [ "$SCRIPT_DIR" = "$HOME/.cohesion/hooks" ]; then
    # Global mode - use project-specific state directory
    PROJECT_PATH=$(pwd)
    PROJECT_HASH=$(echo "$PROJECT_PATH" | shasum -a 256 | cut -c1-16)
    STATE_FILE="$HOME/.cohesion/states/$PROJECT_HASH/session.json"
else
    # Local mode - use local state directory
    STATE_FILE="$SCRIPT_DIR/../state/session.json"
fi

STATE=$(jq -r '.state // "DISCOVER"' "$STATE_FILE" 2>/dev/null || echo "DISCOVER")

# In UNLEASH state, allow everything
if [ "$STATE" = "UNLEASH" ]; then
    echo '{"continue": true}'
    exit 0
fi

# In OPTIMIZE state, allow readonly commands for diagnostics
if [ "$STATE" = "OPTIMIZE" ]; then
    # Allow readonly commands in OPTIMIZE for diagnostics
    if echo "$COMMAND" | grep -qE '^(ls|pwd|cat|head|tail|grep|find|echo|date|which|type|env|printenv|df|du|ps|top|whoami|hostname|uname)(\s|$)'; then
        echo '{"continue": true, "reminder": "🤝 OPTIMIZE state - Read-only bash commands allowed"}'
        exit 0
    fi
    
    # Block write operations
    cat <<EOF
{
  "continue": false,
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "⛔ BASH MODIFICATIONS OPTIMIZE\n\nOPTIMIZE state active.\nOnly read-only commands allowed for diagnostics.\nExplain your needs and wait for user guidance."
  }
}
EOF
    exit 0
fi

# In DISCOVER state, only allow readonly commands
# Fast pattern matching for common readonly commands
if echo "$COMMAND" | grep -qE '^(ls|pwd|cat|head|tail|grep|find|echo|date|which|type|env|printenv|df|du|ps|top|whoami|hostname|uname)(\s|$)'; then
    echo '{"continue": true}'
    exit 0
fi

# Block write operations
if echo "$COMMAND" | grep -qE '(rm|mv|cp|mkdir|touch|chmod|chown|>|>>|sed\s+-i|npm\s+install|pip\s+install|apt|brew|git\s+(add|commit|push))'; then
    cat <<EOF
{
  "continue": false,
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "⛔ BASH COMMAND OPTIMIZE: Write operation detected\n\nPROHIBITED in DISCOVER state:\n• File modifications (rm, mv, cp, mkdir, touch)\n• Permission changes (chmod, chown)\n• Package installations (npm install, pip install)\n• Git operations (add, commit, push)\n\nYou MUST get plan approval FIRST."
  }
}
EOF
    exit 0
fi

# Default allow for edge cases
echo '{"continue": true}'
exit 0