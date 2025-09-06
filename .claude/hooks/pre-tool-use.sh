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
    STATE_DIR="$HOME/.cohesion/states/$PROJECT_HASH"
else
    # Local mode - use local state directory
    STATE_DIR="$SCRIPT_DIR/../state"
fi

# DUO Protocol state flags
FLAG_DIR="$STATE_DIR/flags"
UNLEASHED_FLAG="$FLAG_DIR/unleashed"
OPTIMIZING_FLAG="$FLAG_DIR/optimizing"

# Fast state detection (optimized)
get_current_state() {
    [ -f "$UNLEASHED_FLAG" ] && echo "UNLEASH" && return
    [ -f "$OPTIMIZING_FLAG" ] && echo "OPTIMIZE" && return
    echo "DISCOVER"
}

STATE=$(get_current_state)

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
        # DUO Protocol: DISCOVER State - Analysis + Research Tools
        case "$TOOL" in
            # Modification tools blocked in DISCOVER
            Write|Edit|MultiEdit|NotebookEdit)
                cat <<EOF
{
  "continue": false,
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "🔍 DISCOVER STATE - Analysis Only\\n\\n❌ Cannot modify files yet\\n\\n✅ Available: Read, Grep, WebSearch, WebFetch\\n\\n🎯 Next Step: Present your plan, then say 'approved'\\n\\n💡 Tip: Use './cohesion status' to see current state"
  }
}
EOF
                exit 0
                ;;
            # Research and analysis tools always allowed
            Read|Grep|Glob|WebSearch|WebFetch)
                echo '{"continue": true, "systemMessage": "🔍 DISCOVER STATE - Research tools available"}'
                exit 0
                ;;
            # Limited bash commands for analysis
            Bash)
                COMMAND=$(echo "$ARGS" | jq -r '.command // ""')
                if echo "$COMMAND" | grep -qE '^(git status|git log|git diff|ls|find|pwd|cat|head|tail|grep|ps|which)'; then
                    echo '{"continue": true}'
                else
                    cat <<EOF
{
  "continue": false,
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse", 
    "permissionDecision": "deny",
    "permissionDecisionReason": "🔍 DISCOVER STATE - Only analysis bash commands allowed\\n\\nAllowed: git status, ls, find, grep, ps, etc."
  }
}
EOF
                fi
                exit 0
                ;;
            *)
                echo '{"continue": true}'
                exit 0
                ;;
        esac
        ;;
esac

echo '{"continue": true}'
exit 0