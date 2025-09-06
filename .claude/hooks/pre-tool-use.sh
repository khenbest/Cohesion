#!/bin/bash
# Cohesion - Pre-Tool Use Hook
# State-based tool access control with < 10ms overhead

set -euo pipefail

# Get tool and state from stdin
INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // ""')
ARGS=$(echo "$INPUT" | jq -r '.tool_input // {}')

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

# Fast state lookup
STATE=$(jq -r '.state // "DISCOVER"' "$STATE_FILE" 2>/dev/null || echo "DISCOVER")

# Quick permission check based on state
case "$STATE" in
    UNLEASH)
        # All tools allowed in UNLEASH state
        echo '{"continue": true}'
        exit 0
        ;;
        
    OPTIMIZE)
        # Allow diagnostic tools in OPTIMIZE state for emergency recovery
        case "$TOOL" in
            Read|Bash|Grep)
                # Allow read-only tools for diagnostics
                echo '{"continue": true, "reminder": "🤝 OPTIMIZE state - Read-only tools allowed for diagnostics"}'
                exit 0
                ;;
            *)
                # Block modification tools
                cat <<EOF
{
  "continue": false,
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "⛔ MODIFICATION TOOLS PAUSED\n\nOPTIMIZE state active.\nRead/Bash/Grep allowed for diagnostics.\nExplain your question to the user and wait for guidance."
  }
}
EOF
                exit 0
                ;;
        esac
        ;;
        
    DISCOVER)
        # DISCOVER state - can do everything except edit code
        case "$TOOL" in
            Write|Edit|MultiEdit|NotebookEdit)
                cat <<EOF
{
  "continue": false,
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "⛔ TOOL OPTIMIZE: $TOOL prohibited in DISCOVER state\n\nCURRENT STATE: DISCOVER\nPROHIBITED: Write, Edit, MultiEdit, NotebookEdit\n\nREQUIRED FIRST:\n1. Complete analysis\n2. Present plan\n3. Get approval\n\nUse Read/Grep/Bash for analysis only."
  }
}
EOF
                exit 0
                ;;
                
            *)
                # All other tools allowed (Read, Bash, Grep, etc.)
                echo '{"continue": true}'
                exit 0
                ;;
        esac
        ;;
esac

echo '{"continue": true}'
exit 0