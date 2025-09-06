#!/bin/bash
# Cohesion - State Management Utilities

set -euo pipefail

STATE_FILE="$(dirname "$0")/../state/session.json"

get_state() {
    jq -r '.state // "DISCOVER"' "$STATE_FILE" 2>/dev/null || echo "DISCOVER"
}

set_state() {
    local NEW_STATE="$1"
    local REASON="${2:-Manual transition}"
    local NOW=$(date +%s)
    
    if [ -f "$STATE_FILE" ]; then
        jq '. + {"state": "'"$NEW_STATE"'", "timestamp": '"$NOW"', "transition_reason": "'"$REASON"'"}' "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
    else
        echo '{"state": "'"$NEW_STATE"'", "timestamp": '"$NOW"', "transition_reason": "'"$REASON"'"}' > "$STATE_FILE"
    fi
}

can_transition() {
    local FROM="$1"
    local TO="$2"
    
    case "$FROM:$TO" in
        DISCOVER:UNLEASH|DISCOVER:OPTIMIZE)
            return 0
            ;;
        UNLEASH:OPTIMIZE|UNLEASH:DISCOVER)
            return 0
            ;;
        OPTIMIZE:DISCOVER)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Main command handling
case "${1:-}" in
    get)
        get_state
        ;;
    set)
        set_state "${2:-DISCOVER}" "${3:-}"
        ;;
    check)
        can_transition "${2:-}" "${3:-}" && echo "allowed" || echo "denied"
        ;;
    *)
        echo "Usage: $0 {get|set <state> [reason]|check <from> <to>}"
        exit 1
        ;;
esac