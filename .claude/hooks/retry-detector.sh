#!/bin/bash
# Retry Detection System V3 - State-Aware with JSON Output

RETRY_DIR="$HOME/.cohesion/state/retry_tracking"
ATTEMPTS_LOG="$RETRY_DIR/attempts.log"
RETRY_THRESHOLD=2
WINDOW_SECONDS=60

# Create tracking directory
mkdir -p "$RETRY_DIR"

# Clean old entries (older than window)
cleanup_old() {
    local cutoff=$(($(date +%s) - WINDOW_SECONDS))
    if [ -f "$ATTEMPTS_LOG" ]; then
        awk -F'|' -v cutoff="$cutoff" '$1 >= cutoff' "$ATTEMPTS_LOG" > "${ATTEMPTS_LOG}.tmp"
        mv "${ATTEMPTS_LOG}.tmp" "$ATTEMPTS_LOG"
    fi
}

# Count attempts for specific tool/action
count_attempts() {
    local tool="$1"
    local action="$2"
    if [ -f "$ATTEMPTS_LOG" ]; then
        grep -c "^[0-9]*|${tool}|${action}$" "$ATTEMPTS_LOG" 2>/dev/null || echo 0
    else
        echo 0
    fi
}

# Generate state-specific guidance
get_state_guidance() {
    local state="$1"
    local tool="$2"
    
    case "$state" in
        DISCOVER)
            echo "DISCOVER STATE - Analysis Only\\n\\nBlocked: Write, Edit, MultiEdit, most Bash\\nAllowed: Read, Grep, Glob, WebSearch\\n\\nSolution: Ask user to change state or use analysis tools"
            ;;
        UNLEASH)
            echo "UNLEASH STATE - Full Access\\n\\nYou have full access but hit a retry loop.\\nCheck: File permissions, syntax errors, or logic issues"
            ;;
        OPTIMIZE)
            echo "OPTIMIZE STATE - Collaborative Mode\\n\\nBlocked: Write, MultiEdit\\nAllowed: Read, Bash, Grep\\n\\nSolution: Provide suggestions for user to implement"
            ;;
        *)
            echo "Unknown state. Check configuration."
            ;;
    esac
}

# Update memory file with current status
update_memory_file() {
    local tool="$1"
    local count="$2"
    local state="$3"
    
    STATUS_FILE="/Users/kenny/Claude/Cohesion/.claude/state/retry_status.md"
    
    # Determine state restrictions text
    case "$state" in
        DISCOVER)
            RESTRICTIONS="- ❌ Cannot: Write, Edit, MultiEdit, most Bash commands
- ✅ Can: Read, Grep, Glob, WebSearch, WebFetch"
            ;;
        UNLEASH)
            RESTRICTIONS="- ✅ Full access to all tools"
            ;;
        OPTIMIZE)
            RESTRICTIONS="- ❌ Cannot: Write, MultiEdit
- ✅ Can: Read, Bash, Grep"
            ;;
        *)
            RESTRICTIONS="- Unknown state restrictions"
            ;;
    esac
    
    # Determine pattern status
    if [ "$count" -ge "$RETRY_THRESHOLD" ]; then
        PATTERN_STATUS="⚠️ **RETRY LOOP DETECTED**"
        NEXT_STEPS="1. STOP trying $tool
2. Check current state with 'cohesion status'
3. Use 'cohesion can-i-edit' before attempting edits
4. Ask user to change state if needed"
    else
        PATTERN_STATUS="✓ Normal operation"
        NEXT_STEPS="Continue with appropriate tools for $state state"
    fi
    
    cat > "$STATUS_FILE" <<EOF
# Retry Detection Memory
**Last Updated:** $(date)
**Current State:** $state
**Recent Activity:** $tool attempted $count times

## Pattern Recognition
$PATTERN_STATUS

## State Restrictions
$RESTRICTIONS

## Next Steps
$NEXT_STEPS
EOF
}

# Create visible warning file if threshold exceeded
create_warning_file() {
    local tool="$1"
    local count="$2"
    local state="$3"
    
    if [ "$count" -ge "$RETRY_THRESHOLD" ]; then
        WARNING_FILE="/Users/kenny/Claude/Cohesion/RETRY_WARNING.txt"
        cat > "$WARNING_FILE" <<EOF
⚠️ RETRY PATTERN DETECTED - PLEASE READ

You have attempted $tool $count times in $state state.

STOP and check:
1. Current state: $state
2. What's allowed in this state
3. Use 'cohesion can-i-edit' before trying again

Delete this file after reading.
EOF
    fi
}

# Main execution
cleanup_old

TOOL="${1:-unknown}"
ACTION="${2:-unknown}"
STATE="${3:-DISCOVER}"

# Log this attempt
echo "$(date +%s)|${TOOL}|${ACTION}" >> "$ATTEMPTS_LOG"

# Count attempts
COUNT=$(count_attempts "$TOOL" "$ACTION")

# Update memory file
update_memory_file "$TOOL" "$COUNT" "$STATE"

# Create warning file if needed
create_warning_file "$TOOL" "$COUNT" "$STATE"

# Generate JSON response
if [ "$COUNT" -ge "$RETRY_THRESHOLD" ]; then
    GUIDANCE=$(get_state_guidance "$STATE" "$TOOL")
    cat <<EOF
{
  "retry_detected": true,
  "attempts": $COUNT,
  "tool": "$TOOL",
  "state": "$STATE",
  "threshold_exceeded": true,
  "message": "🔄 RETRY PATTERN: ${COUNT} attempts with ${TOOL}\\n\\n${GUIDANCE}\\n\\n💡 After 2 attempts, always check state first!"
}
EOF
    # Clear attempts log after warning
    > "$ATTEMPTS_LOG"
else
    cat <<EOF
{
  "retry_detected": false,
  "attempts": $COUNT,
  "tool": "$TOOL",
  "state": "$STATE",
  "threshold_exceeded": false,
  "message": "Attempt $COUNT of $RETRY_THRESHOLD before warning"
}
EOF
fi