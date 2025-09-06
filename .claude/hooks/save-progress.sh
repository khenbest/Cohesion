#!/bin/bash
# Cohesion - Save Progress Hook
# Persists context and state after each interaction

set -euo pipefail

STATE_DIR="$(dirname "$0")/../state"
CONTEXT_FILE="$(dirname "$0")/../../docs/CONTEXT.md"
STATE_FILE="$STATE_DIR/session.json"
BACKUP_DIR="$STATE_DIR/backups"

# Create backup directory if needed
mkdir -p "$BACKUP_DIR"

# Quick state backup (rotate last 5)
if [ -f "$STATE_FILE" ]; then
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    cp "$STATE_FILE" "$BACKUP_DIR/session_${TIMESTAMP}.json"
    
    # Keep only last 5 backups
    ls -t "$BACKUP_DIR"/session_*.json 2>/dev/null | tail -n +6 | xargs rm -f 2>/dev/null || true
fi

# Update last activity timestamp
if [ -f "$STATE_FILE" ]; then
    NOW=$(date +%s)
    jq '. + {"last_activity": '"$NOW"'}' "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
fi

echo '{"continue": true}'
exit 0