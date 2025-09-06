#!/bin/bash
# Cohesion - Pre-Compact Hook
# Preserve context before conversation history compaction

set -euo pipefail

STATE_DIR="$(dirname "$0")/../state"
STATE_FILE="$STATE_DIR/session.json"
WORK_FILE="$STATE_DIR/work.json"
COMPACT_LOG="$STATE_DIR/compact.log"

# Get current state
CURRENT_STATE=$(jq -r '.state // "DISCOVER"' "$STATE_FILE" 2>/dev/null || echo "DISCOVER")
NOW=$(date +%s)

# Log compaction event
echo "$(date '+%Y-%m-%d %H:%M:%S')|State:${CURRENT_STATE}|Compacted" >> "$COMPACT_LOG"

# Save work context if not already saved
if [ ! -f "$WORK_FILE" ] || [ ! -s "$WORK_FILE" ]; then
    cat > "$WORK_FILE" <<EOF
{
  "last_task": "Session compacted while in $CURRENT_STATE state",
  "next_plan": "Continue previous work after compaction",
  "compacted_at": $NOW,
  "pre_compact_state": "$CURRENT_STATE"
}
EOF
else
    # Update existing work file with compaction info
    jq '. + {"compacted_at": '"$NOW"', "pre_compact_state": "'"$CURRENT_STATE"'"}' "$WORK_FILE" > "${WORK_FILE}.tmp" && mv "${WORK_FILE}.tmp" "$WORK_FILE"
fi

# Update state file with compaction timestamp
if [ -f "$STATE_FILE" ]; then
    jq '. + {"last_compact": '"$NOW"'}' "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
fi

# Return message based on current state
case "$CURRENT_STATE" in
    UNLEASH)
        echo '{"continue": true, "systemMessage": "📦 Compacting conversation. You are in UNLEASH state - continue implementing after compaction."}'
        ;;
    OPTIMIZE)
        echo '{"continue": true, "systemMessage": "📦 Compacting conversation. You were in OPTIMIZE state - re-explain your question after compaction."}'
        ;;
    *)
        echo '{"continue": true, "systemMessage": "📦 Compacting conversation. Continue analysis after compaction."}'
        ;;
esac

exit 0