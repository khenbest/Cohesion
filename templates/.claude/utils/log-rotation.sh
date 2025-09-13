#!/bin/bash

# Log rotation for Cohesion debug logs
# Prevents .hook_debug from growing too large

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
: "${STATE_DIR:=$SCRIPT_DIR/../state}"
DEBUG_LOG="$STATE_DIR/.hook_debug"
MAX_SIZE=10485760  # 10MB in bytes
MAX_LINES=10000    # Keep last 10000 lines

# Function to rotate log if needed
rotate_debug_log() {
    if [ ! -f "$DEBUG_LOG" ]; then
        return 0
    fi

    # Check file size
    if [ "$(uname)" = "Darwin" ]; then
        file_size=$(stat -f%z "$DEBUG_LOG" 2>/dev/null || echo 0)
    else
        file_size=$(stat -c%s "$DEBUG_LOG" 2>/dev/null || echo 0)
    fi

    # Rotate if too large
    if [ "$file_size" -gt "$MAX_SIZE" ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Log rotation: file size $file_size exceeds $MAX_SIZE bytes" >> "$DEBUG_LOG"

        # Keep last N lines
        if command -v tail >/dev/null 2>&1; then
            tail -n "$MAX_LINES" "$DEBUG_LOG" > "${DEBUG_LOG}.tmp"
            mv "${DEBUG_LOG}.tmp" "$DEBUG_LOG"
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] Log rotated - kept last $MAX_LINES lines" >> "$DEBUG_LOG"
        else
            # Fallback: just truncate
            > "$DEBUG_LOG"
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] Log truncated (tail not available)" >> "$DEBUG_LOG"
        fi
    fi
}

# Function to clean old debug logs
clean_old_logs() {
    # Remove debug logs older than 7 days
    if command -v find >/dev/null 2>&1; then
        find "$STATE_DIR" -name ".hook_debug.*" -type f -mtime +7 -delete 2>/dev/null
    fi
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    rotate_debug_log
    clean_old_logs
    echo "Log rotation completed"
fi

# Export function for use by other scripts
export -f rotate_debug_log 2>/dev/null || true