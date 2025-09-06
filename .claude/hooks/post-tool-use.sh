#!/bin/bash
# Cohesion - Post Tool Use Hook
# Tracks tool usage and updates progress

set -euo pipefail

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // ""')
SUCCESS=$(echo "$INPUT" | jq -r '.success // false')
STATE_DIR="$(dirname "$0")/../state"
LOG_FILE="$STATE_DIR/tool-usage.log"

# Log tool usage (append-only for speed)
echo "$(date +%s)|$TOOL|$SUCCESS" >> "$LOG_FILE"

# Quick success tracking
if [ "$SUCCESS" = "true" ]; then
    # Update progress counter
    PROGRESS_FILE="$STATE_DIR/progress.json"
    if [ -f "$PROGRESS_FILE" ]; then
        COUNT=$(jq -r '.tools_used // 0' "$PROGRESS_FILE")
        COUNT=$((COUNT + 1))
        jq '. + {"tools_used": '"$COUNT"', "last_tool": "'"$TOOL"'"}' "$PROGRESS_FILE" > "${PROGRESS_FILE}.tmp" && mv "${PROGRESS_FILE}.tmp" "$PROGRESS_FILE"
    else
        echo '{"tools_used": 1, "last_tool": "'"$TOOL"'"}' > "$PROGRESS_FILE"
    fi
fi

echo '{"continue": true}'
exit 0