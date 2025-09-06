#!/bin/bash
# Cohesion - Session Start Hook
# ALWAYS starts in DISCOVER mode, loads previous work context

# Debug logging
echo "[$(date)] Cohesion session-start hook called from: $(pwd)" >> /tmp/cohesion-debug.log

set -euo pipefail

# Performance: Use process substitution to avoid subshells
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect if we're in global or local mode
if [ -d "$HOME/.cohesion" ] && [ "$SCRIPT_DIR" = "$HOME/.cohesion/hooks" ]; then
    # Global mode - use project-specific state directory
    PROJECT_PATH=$(pwd)
    PROJECT_HASH=$(echo "$PROJECT_PATH" | shasum -a 256 | cut -c1-16)
    STATE_DIR="$HOME/.cohesion/states/$PROJECT_HASH"
    CONTEXT_FILE="$PROJECT_PATH/docs/CONTEXT.md"
else
    # Local mode - use local state directory
    STATE_DIR="$SCRIPT_DIR/../state"
    CONTEXT_FILE="$SCRIPT_DIR/../../docs/CONTEXT.md"
fi

STATE_FILE="$STATE_DIR/session.json"
WORK_FILE="$STATE_DIR/work.json"

# Ensure state directory exists
mkdir -p "$STATE_DIR"

# ALWAYS start in DISCOVER mode
NOW=$(date +%s)

# Validate existing state file if it exists (auto-recovery from corruption)
if [ -f "$STATE_FILE" ]; then
    if ! jq empty "$STATE_FILE" 2>/dev/null; then
        echo "⚠️ Corrupted state file detected - resetting to DISCOVER" >&2
        rm -f "$STATE_FILE"
    fi
fi

echo '{"state": "DISCOVER", "timestamp": '"$NOW"'}' > "$STATE_FILE"

# Load previous work context if exists
WORK_CONTEXT=""
if [ -f "$WORK_FILE" ]; then
    LAST_TASK=$(jq -r '.last_task // ""' "$WORK_FILE" 2>/dev/null || echo "")
    NEXT_PLAN=$(jq -r '.next_plan // ""' "$WORK_FILE" 2>/dev/null || echo "")
    LAST_STATE=$(jq -r '.last_state // ""' "$WORK_FILE" 2>/dev/null || echo "")
    
    if [ -n "$LAST_TASK" ] || [ -n "$NEXT_PLAN" ] || [ -n "$LAST_STATE" ]; then
        WORK_CONTEXT="\n\n📋 PREVIOUS SESSION:"
        [ -n "$LAST_TASK" ] && WORK_CONTEXT="$WORK_CONTEXT\nLast task: $LAST_TASK"
        [ -n "$NEXT_PLAN" ] && WORK_CONTEXT="$WORK_CONTEXT\nNext plan: $NEXT_PLAN"
        [ "$LAST_STATE" = "OPTIMIZE" ] && WORK_CONTEXT="$WORK_CONTEXT\n⚠️ Session ended during consultation - review context"
    fi
fi

# Load project context if exists
if [ -f "$CONTEXT_FILE" ]; then
    echo "{\"continue\": true, \"systemMessage\": \"🚀 COHESION INITIALIZED - DISCOVER STATE\\n\\nAnalyze the request carefully and consider the optimal outcome. Find the simplest working solution.$WORK_CONTEXT\\n\\nPROHIBITED:\\n• Write, Edit, or modification tools\\n\\nREQUIRED:\\n1. Analyze using Read/Grep only\\n2. Present comprehensive plan\\n3. Wait for approval before modifications\\n\\nContext loaded from CONTEXT.md.\"}"
else
    echo "{\"continue\": true, \"systemMessage\": \"🚀 COHESION INITIALIZED - DISCOVER STATE\\n\\nAnalyze the request carefully and consider the optimal outcome. Find the simplest working solution.$WORK_CONTEXT\\n\\nPROHIBITED:\\n• Write, Edit, or modification tools\\n\\nREQUIRED:\\n1. Analyze using Read/Grep only\\n2. Present comprehensive plan\\n3. Wait for approval before modifications\\n\\nTip: Create docs/CONTEXT.md for persistent context.\"}"
fi

exit 0