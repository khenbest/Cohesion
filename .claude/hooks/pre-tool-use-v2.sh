#!/bin/bash
# Cohesion Framework - Pre-tool-use hook (v2 with dual-mode support)
# Enforces state-based tool restrictions

set -euo pipefail

# Detect installation mode and get state file
if [ -d "./.claude" ] && [ -f "./.claude/settings.json" ]; then
    # Local installation
    STATE_FILE="./.claude/state/session.json"
    MODE="local"
elif [ -d "$HOME/.cohesion" ]; then
    # Global installation
    PROJECT_PATH=$(pwd)
    PROJECT_HASH=$(echo "$PROJECT_PATH" | shasum -a 256 | cut -c1-16)
    STATE_FILE="$HOME/.cohesion/states/$PROJECT_HASH/session.json"
    MODE="global"
else
    # No installation, allow all
    exit 0
fi

# Get current state
if [ -f "$STATE_FILE" ]; then
    STATE=$(jq -r '.state // "THINKING"' "$STATE_FILE" 2>/dev/null || echo "THINKING")
else
    STATE="THINKING"
fi

# Tool being called
TOOL_NAME="${1:-}"

# Define allowed tools per state
case "$STATE" in
    THINKING)
        # Planning state - read-only tools
        ALLOWED_TOOLS="Read|Grep|Glob|WebSearch|WebFetch|TodoWrite|TodoRead|ExitPlanMode"
        TOOL_DESC="read-only and planning tools"
        ;;
    FLOW)
        # Full access state - all tools allowed
        exit 0
        ;;
    BLOCKED)
        # Blocked state - minimal tools
        ALLOWED_TOOLS="Read|TodoWrite|TodoRead"
        TOOL_DESC="minimal tools (need user help)"
        ;;
    *)
        # Unknown state - default to THINKING
        ALLOWED_TOOLS="Read|Grep|Glob|WebSearch|WebFetch|TodoWrite|TodoRead"
        TOOL_DESC="read-only tools"
        ;;
esac

# Check if tool is allowed
if ! echo "$TOOL_NAME" | grep -qE "^($ALLOWED_TOOLS)$"; then
    # Log the blocked attempt
    LOG_DIR="$(dirname "$STATE_FILE")"
    LOG_FILE="$LOG_DIR/blocked-tools.log"
    echo "$(date -Iseconds)|$STATE|$TOOL_NAME|blocked" >> "$LOG_FILE"
    
    # Provide helpful error message
    cat << EOF
❌ Tool '$TOOL_NAME' is not allowed in $STATE state.

Current state: $STATE
Allowed: $TOOL_DESC

To use this tool:
  1. Complete your analysis first
  2. Get user approval
  3. Enter FLOW state with: cohesion flow
  
Or if you're stuck, use: cohesion blocked

EOF
    exit 1
fi

# Log successful tool use
LOG_DIR="$(dirname "$STATE_FILE")"
LOG_FILE="$LOG_DIR/tool-usage.log"
echo "$(date -Iseconds)|$TOOL_NAME|$STATE|allowed" >> "$LOG_FILE"