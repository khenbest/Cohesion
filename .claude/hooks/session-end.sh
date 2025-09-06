#!/bin/bash
# Cohesion DUO Protocol - Session End Hook
# Clean up state and persist session context

set -euo pipefail

# Detect if we're in global or local mode
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -d "$HOME/.cohesion" ] && [ "$SCRIPT_DIR" = "$HOME/.cohesion/hooks" ]; then
    # Global mode - use project-specific state directory
    PROJECT_PATH=$(pwd)
    PROJECT_HASH=$(echo "$PROJECT_PATH" | shasum -a 256 | cut -c1-16)
    STATE_DIR="$HOME/.cohesion/states/$PROJECT_HASH"
    STATE_FILE="$STATE_DIR/session.json"
else
    # Local mode - use local state directory
    STATE_DIR="$SCRIPT_DIR/../state"
    STATE_FILE="$STATE_DIR/session.json"
fi

# DUO Protocol state flags
FLAG_DIR="$STATE_DIR/flags"
UNLEASHED_FLAG="$FLAG_DIR/unleashed"
OPTIMIZING_FLAG="$FLAG_DIR/optimizing"

# Determine current DUO state
if [ -f "$UNLEASHED_FLAG" ]; then
    CURRENT_STATE="UNLEASH"
elif [ -f "$OPTIMIZING_FLAG" ]; then
    CURRENT_STATE="OPTIMIZE"
else
    CURRENT_STATE="DISCOVER"
fi

# Save session metadata
WORK_FILE="$STATE_DIR/work.json"
NOW=$(date +%s)

# Create work context for next session
cat > "$WORK_FILE" << EOF
{
  "last_state": "$CURRENT_STATE",
  "ended_at": "$NOW",
  "ended_date": "$(date -Iseconds)",
  "last_task": "",
  "next_plan": ""
}
EOF

# Clean up state flags for next session
rm -f "$UNLEASHED_FLAG" "$OPTIMIZING_FLAG" 2>/dev/null

# Reset to DISCOVER state for next session
echo '{"state": "DISCOVER", "timestamp": '"$NOW"'}' > "$STATE_FILE"

echo '{"continue": true, "systemMessage": "🔄 Session ended - state cleaned up for next session"}'
exit 0