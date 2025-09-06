#!/bin/bash
# Cohesion - Session End Hook
# Saves work context for next session, logs summary

set -euo pipefail

STATE_DIR="$(dirname "$0")/../state"
STATE_FILE="$STATE_DIR/session.json"
WORK_FILE="$STATE_DIR/work.json"
SUMMARY_FILE="$STATE_DIR/session-summary.log"

# Generate session summary
if [ -f "$STATE_FILE" ]; then
    STATE=$(jq -r '.state // "UNKNOWN"' "$STATE_FILE")
    START=$(jq -r '.timestamp // 0' "$STATE_FILE")
    NOW=$(date +%s)
    DURATION=$((NOW - START))
    
    # Append to summary log
    echo "$(date '+%Y-%m-%d %H:%M:%S')|Duration:${DURATION}s|FinalState:${STATE}" >> "$SUMMARY_FILE"
    
    # Save work context for next session
    # This would ideally be populated from the actual work being done
    # For now, preserve existing work.json if it exists
    if [ ! -f "$WORK_FILE" ]; then
        echo '{"last_task": "", "next_plan": "", "session_ended": '"$NOW"'}' > "$WORK_FILE"
    else
        # Update session_ended timestamp
        jq '. + {"session_ended": '"$NOW"'}' "$WORK_FILE" > "${WORK_FILE}.tmp" && mv "${WORK_FILE}.tmp" "$WORK_FILE"
    fi
fi

echo '{"continue": true}'
exit 0