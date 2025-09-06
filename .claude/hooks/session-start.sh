#!/bin/bash
# Cohesion - Session Start Hook
# ALWAYS starts in DISCOVER mode, loads previous work context

# Debug logging
echo "[$(date)] Cohesion session-start hook called from: $(pwd)" >> /tmp/cohesion-debug.log

set -euo pipefail

# Performance: Use process substitution to avoid subshells
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect if we're in global or local mode
if [ -d "$HOME/.cohesion" ] && [ "$SCRIPT_DIR" = "$HOME/.cohesion/hooks" ]; then
    # Global mode - use project-specific state directory
    PROJECT_PATH=$(pwd)
    PROJECT_HASH=$(echo "$PROJECT_PATH" | shasum -a 256 | cut -c1-16)
    STATE_DIR="$HOME/.cohesion/states/$PROJECT_HASH"
    CONTEXT_FILE="$PROJECT_PATH/docs/CONTEXT.md"
else
    # Local mode - use local state directory
    STATE_DIR="$SCRIPT_DIR/../state"
    CONTEXT_FILE="$SCRIPT_DIR/../../docs/CONTEXT.md"
fi

STATE_FILE="$STATE_DIR/session.json"
WORK_FILE="$STATE_DIR/work.json"

# Ensure state directory exists
mkdir -p "$STATE_DIR"

# ALWAYS start in DISCOVER mode
NOW=$(date +%s)

# Validate existing state file if it exists (auto-recovery from corruption)
if [ -f "$STATE_FILE" ]; then
    if ! jq empty "$STATE_FILE" 2>/dev/null; then
        echo "⚠️ Corrupted state file detected - resetting to DISCOVER" >&2
        rm -f "$STATE_FILE"
    fi
fi

echo '{"state": "DISCOVER", "timestamp": '"$NOW"'}' > "$STATE_FILE"

# Load previous work context if exists
WORK_CONTEXT=""
if [ -f "$WORK_FILE" ]; then
    LAST_TASK=$(jq -r '.last_task // ""' "$WORK_FILE" 2>/dev/null || echo "")
    NEXT_PLAN=$(jq -r '.next_plan // ""' "$WORK_FILE" 2>/dev/null || echo "")
    LAST_STATE=$(jq -r '.last_state // ""' "$WORK_FILE" 2>/dev/null || echo "")
    
    if [ -n "$LAST_TASK" ] || [ -n "$NEXT_PLAN" ] || [ -n "$LAST_STATE" ]; then
        WORK_CONTEXT="\n\n📋 PREVIOUS SESSION:"
        [ -n "$LAST_TASK" ] && WORK_CONTEXT="$WORK_CONTEXT\nLast task: $LAST_TASK"
        [ -n "$NEXT_PLAN" ] && WORK_CONTEXT="$WORK_CONTEXT\nNext plan: $NEXT_PLAN"
        [ "$LAST_STATE" = "OPTIMIZE" ] && WORK_CONTEXT="$WORK_CONTEXT\n⚠️ Session ended during consultation - review context"
    fi
fi

# Create DUO Protocol directories
CONTEXT_DIR="$SCRIPT_DIR/../context"
FLAG_DIR="$STATE_DIR/flags"
mkdir -p "$CONTEXT_DIR" "$FLAG_DIR"

# DUO Protocol ALWAYS starts in DISCOVER state
rm -f "$FLAG_DIR/unleashed" "$FLAG_DIR/optimizing" 2>/dev/null

# Create DUO Protocol status document
cat > "$CONTEXT_DIR/duo-status.md" << 'EOF'
# Cohesion DUO Protocol Status: DISCOVER 🔍

## Current Capabilities (DISCOVER State):
✅ **Analysis Tools**: Read, Grep, Glob for code exploration
✅ **Research Tools**: WebSearch, WebFetch for external research  
✅ **Git Inspection**: git status, git log, git diff
✅ **System Analysis**: ls, find, ps, basic bash commands

❌ **Prohibited**: Write, Edit, MultiEdit, complex bash commands
❌ **Cannot**: Modify files or execute deployment commands

## DUO Protocol Workflow:
1. **DISCOVER** 🔍 - **[CURRENT STATE]** Analyze request thoroughly
2. **Present Plan** - Show comprehensive analysis and proposed solution
3. **Wait for Approval** - User says "approved", "lgtm", or "proceed"
4. **UNLEASH** ⚡ - Gain full autonomous execution power
5. **Complete Task** - Return to DISCOVER for next request

## State Transition Keywords:
- **DISCOVER → UNLEASH**: "approved", "lgtm", "proceed", "looks good", "ship it"
- **ANY → OPTIMIZE**: "unclear", "which approach", "help", "confused"
- **ANY → DISCOVER**: "reset", "start over", "new task"

## Remember:
- You cannot change your own state with commands
- Research tools (WebSearch/WebFetch) available in DISCOVER and OPTIMIZE
- Present thorough analysis before requesting approval
EOF

# Detect git context for enhanced project awareness
GIT_CONTEXT=""
if [ -d ".git" ]; then
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
    UNCOMMITTED=$(git status --porcelain 2>/dev/null | wc -l || echo "0")
    BEHIND=$(git rev-list HEAD..@{u} --count 2>/dev/null || echo "0")
    
    GIT_CONTEXT="\\n\\n📋 Git Context: $CURRENT_BRANCH branch, $UNCOMMITTED uncommitted files"
    [ "$BEHIND" -gt 0 ] && GIT_CONTEXT="$GIT_CONTEXT, $BEHIND commits behind"
fi

# Send DUO Protocol initialization message
cat <<EOF
{
  "continue": true,
  "systemMessage": "🚀 COHESION DUO PROTOCOL INITIALIZED\\n\\nCurrent State: DISCOVER 🔍\\n\\n## Your Mission:\\n• Analyze the request thoroughly using Read/Grep/WebSearch\\n• Explore the codebase and understand current state\\n• Research external resources if needed\\n• Present comprehensive plan with clear reasoning\\n• Wait for user approval to enter UNLEASH state\\n\\n## Available Tools:\\n✅ Read, Grep, Glob - Code analysis\\n✅ WebSearch, WebFetch - External research\\n✅ Git inspection commands\\n✅ System exploration (ls, find, ps)\\n\\n❌ No modification tools until UNLEASH state$WORK_CONTEXT$GIT_CONTEXT\\n\\nDUO Protocol Status: .claude/context/duo-status.md"
}
EOF

exit 0