#!/bin/bash
# Cohesion - Intent Detection Hook
# Fast pattern matching for state transitions

set -euo pipefail

INPUT=$(cat)
MESSAGE=$(echo "$INPUT" | jq -r '.prompt // ""' | tr '[:upper:]' '[:lower:]')

# Detect if we're in global or local mode
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -d "$HOME/.cohesion" ] && [ "$SCRIPT_DIR" = "$HOME/.cohesion/hooks" ]; then
    # Global mode - use project-specific state directory
    PROJECT_PATH=$(pwd)
    PROJECT_HASH=$(echo "$PROJECT_PATH" | shasum -a 256 | cut -c1-16)
    STATE_FILE="$HOME/.cohesion/states/$PROJECT_HASH/session.json"
else
    # Local mode - use local state directory
    STATE_FILE="$SCRIPT_DIR/../state/session.json"
fi

LOCK_FILE="${STATE_FILE}.lock"

# Acquire lock for atomic state operations (timeout after 2 seconds)
exec 200>"$LOCK_FILE"
if ! flock -w 2 200; then
    echo '{"continue": true, "warning": "State file locked - continuing without state update"}'
    exit 0
fi

CURRENT_STATE=$(jq -r '.state // "DISCOVER"' "$STATE_FILE" 2>/dev/null || echo "DISCOVER")

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

case "$CURRENT_STATE" in
    DISCOVER)
        if detect_approval; then
            # Transition to UNLEASH
            jq '. + {"state": "UNLEASH", "timestamp": '"$NOW"', "approved_at": '"$NOW"'}' "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
            echo '{"continue": true, "systemMessage": "✅ Plan approved - entering UNLEASH state\n\nYou now have full tool access. Work autonomously."}'
            exit 0
        fi
        ;;
        
    UNLEASH)
        if detect_consultation; then
            # Transition to OPTIMIZE
            jq '. + {"state": "OPTIMIZE", "timestamp": '"$NOW"'}' "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
            echo '{"continue": true, "systemMessage": "🤝 OPTIMIZE STATE ACTIVE\n\nStop all execution. You need user input before continuing.\n\nWHY YOU ARE HERE:\n• You detected complexity beyond the approved plan\n• Multiple valid approaches exist - user preference needed\n• You are spiraling or overthinking - need redirection\n• Scope or requirements became unclear during implementation\n\nIMMEDIATE ACTIONS:\n• STOP all tool usage and modifications\n• EXPLAIN the situation clearly to the user\n• PRESENT options if there are multiple paths\n• WAIT for user guidance - do not attempt to proceed\n\nWHAT TO SHARE WITH USER:\n• What you were trying to do\n• What complication or choice point arose\n• What options exist (if applicable)\n• What specific input you need to continue\n\nThe user will either:\n- Provide detailed guidance for complex situations\n- Give simple redirection if you are overthinking\n- Clarify requirements if something was ambiguous\n\nDo NOT attempt workarounds or independent solutions. Wait for clear direction."}'
            exit 0
        fi
        ;;
        
    OPTIMIZE)
        # Look for guidance or clarification
        if echo "$MESSAGE" | grep -qE 'try|solution|fixed|resolved|here|should|instead|approach|prefer|just do|keep it simple'; then
            # Back to DISCOVER to process the guidance
            jq '. + {"state": "DISCOVER", "timestamp": '"$NOW"'}' "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
            echo '{"continue": true, "systemMessage": "💡 GUIDANCE RECEIVED - RETURNING TO DISCOVER STATE\n\nRe-analyze with the user input. Incorporate their preferences and clarifications.\n\nPROHIBITED:\n• Modifications remain prohibited\n• Do NOT implement yet\n\nREQUIRED:\n1. Integrate the user guidance into your approach\n2. Present updated plan if it changed significantly\n3. Wait for approval before implementing"}'
            exit 0
        fi
        ;;
esac

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