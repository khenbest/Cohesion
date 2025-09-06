#!/bin/bash
# Cohesion DUO Protocol - Intent Detection Hook
# Enforces the DUO workflow: DISCOVER → UNLEASH → OPTIMIZE

set -euo pipefail

INPUT=$(cat)
MESSAGE=$(echo "$INPUT" | jq -r '.prompt // ""' | tr '[:upper:]' '[:lower:]')

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
mkdir -p "$FLAG_DIR"

# Determine current DUO state
if [ -f "$UNLEASHED_FLAG" ]; then
    CURRENT_STATE="UNLEASH"
elif [ -f "$OPTIMIZING_FLAG" ]; then
    CURRENT_STATE="OPTIMIZE"
else
    CURRENT_STATE="DISCOVER"
fi

# Fast keyword detection using case statement
detect_approval() {
    case "$MESSAGE" in
        *approved*|*lgtm*|*"looks good"*|*proceed*|*"ship it"*|*"go ahead"*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

detect_weak_approval() {
    case "$MESSAGE" in
        *"yes"*|*"ok"*|*"sure"*|*"yep"*|*"yeah"*|*"good"*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

detect_consultation() {
    case "$MESSAGE" in
        # Technical blockers (original)
        *stuck*|*blocked*|*help*|*"can't"*|*"cannot"*|*issue*|*problem*)
            return 0
            ;;
        # Uncertainty & clarification
        *unclear*|*clarify*|*"not sure"*|*ambiguous*|*confus*)
            return 0
            ;;
        # Choice points & preferences
        *"which approach"*|*"which way"*|*preference*|*"should i"*|*"would you prefer"*)
            return 0
            ;;
        # Scope questions
        *"also include"*|*"out of scope"*|*"how far"*|*"extend to"*)
            return 0
            ;;
        # Alignment checks
        *"is this what"*|*"did you mean"*|*"correct understanding"*|*confirm*)
            return 0
            ;;
        # Overthinking indicators
        *"getting complex"*|*"spiraling"*|*"overthinking"*|*"too complicated"*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}


detect_reset() {
    case "$MESSAGE" in
        *reset*|*"start over"*|*"new task"*|*"fresh start"*|*clear*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Handle state transitions
NOW=$(date +%s)

if detect_reset; then
    echo '{"state": "DISCOVER", "timestamp": '"$NOW"'}' > "$STATE_FILE"
    echo '{"continue": true, "systemMessage": "🔄 State reset to DISCOVER - ready for new task"}'
    exit 0
fi

# DUO Protocol Transition: DISCOVER → UNLEASH (User Approval)
if [ "$CURRENT_STATE" = "DISCOVER" ]; then
    if detect_approval; then
        # Check for weak single-word approvals
        if [[ "$MESSAGE" =~ ^(yes|ok|sure|yep|yeah)$ ]]; then
            cat <<EOF
{
  "continue": true,
  "systemMessage": "⚠️ DUO PROTOCOL: Weak approval detected\\n\\nPlease confirm with: 'approved', 'proceed', or 'lgtm' to enter UNLEASH state"
}
EOF
            exit 0
        else
            # Strong approval - DISCOVER → UNLEASH
            touch "$UNLEASHED_FLAG"
            rm -f "$OPTIMIZING_FLAG" 2>/dev/null
            echo "Plan unleashed at $(date)" > "$UNLEASHED_FLAG"
            jq '. + {"state": "UNLEASH", "timestamp": '"$NOW"', "approved_at": '"$NOW"'}' "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
            cat <<EOF
{
  "continue": true,
  "systemMessage": "⚡ UNLEASH STATE ACTIVATED\\n\\n🎯 Mission: Execute approved plan autonomously\\n🔧 Tools: All modification capabilities enabled\\n⏰ Started: $(date '+%H:%M')\\n\\n💪 Working with full autonomy until task completion..."
}
EOF
            exit 0
        fi
    elif detect_weak_approval; then
        cat <<EOF
{
  "continue": true,
  "systemMessage": "🤔 Partial approval detected\\n\\n💡 For UNLEASH state, say: 'approved', 'lgtm', or 'proceed'\\n🔍 Currently in DISCOVER - analysis only"
}
EOF
        exit 0
    fi
fi

# DUO Protocol Transition: Any State → OPTIMIZE (Help/Consultation)
if [[ "$MESSAGE" =~ ("unclear"|"which approach"|"preference"|"help"|"confused"|"what do you think"|"need advice") ]]; then
    if [ "$CURRENT_STATE" != "OPTIMIZE" ]; then
        touch "$OPTIMIZING_FLAG"
        rm -f "$UNLEASHED_FLAG" 2>/dev/null
        jq '. + {"state": "OPTIMIZE", "timestamp": '"$NOW"'}' "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
        cat <<EOF
{
  "continue": true,
  "systemMessage": "🤝 DUO PROTOCOL: OPTIMIZE STATE ACTIVATED\\n\\nCollaborative consultation mode. You have research tools to help analyze and discuss the best approach."
}
EOF
        exit 0
    fi
fi

# User provides guidance (Any State → DISCOVER)
if [[ "$MESSAGE" =~ ("try this"|"here's how"|"the solution"|"you should"|"instead"|"the problem is") ]]; then
    rm -f "$UNLEASHED_FLAG" "$OPTIMIZING_FLAG" 2>/dev/null
    jq '. + {"state": "DISCOVER", "timestamp": '"$NOW"'}' "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
    cat <<EOF
{
  "continue": true,
  "systemMessage": "💡 DUO PROTOCOL: Guidance received - Back to DISCOVER\\n\\nAnalyze the new guidance and present updated plan for approval."
}
EOF
    exit 0
fi

# No state change needed - add reminder based on current state
case "$CURRENT_STATE" in
    DISCOVER)
        echo '{"continue": true, "reminder": "⚠️ REMINDER: DISCOVER state. Analysis only - NO modifications allowed."}'
        ;;
    UNLEASH)
        echo '{"continue": true, "reminder": "✅ REMINDER: UNLEASH state. Continue implementing the approved plan."}'
        ;;
    OPTIMIZE)
        echo '{"continue": true, "reminder": "🤝 REMINDER: OPTIMIZE state. Awaiting user input before proceeding."}'
        ;;
    *)
        echo '{"continue": true}'
        ;;
esac
exit 0