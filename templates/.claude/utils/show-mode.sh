#!/usr/bin/env bash
# Show current Cohesion mode

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
STATE_DIR="$SCRIPT_DIR/../state"

if [ -f "$STATE_DIR/UNLEASH" ]; then
    echo "UNLEASH"
elif [ -f "$STATE_DIR/OPTIMIZE" ]; then
    echo "OPTIMIZE"
elif [ -f "$STATE_DIR/DISCOVER" ]; then
    echo "DISCOVER"
else
    echo "DISCOVER"  # Default mode
fi