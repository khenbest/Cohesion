#!/usr/bin/env bash
# Cohesion Script Header (standardized)
# Cohesion Pre-Tool-Use Hook - Primary Permission Controller
# Uses hook decision overrides to bypass Claude Code's permission system
set -euo pipefail

_script_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd -P)"
_utils_candidates=(
  "$_script_dir/../utils/cohesion-utils.sh"
  "$HOME/.cohesion/utils/cohesion-utils.sh"
)
for _u in "${_utils_candidates[@]}"; do
  if [ -f "$_u" ]; then . "$_u"; _found_utils=1; break; fi
done
: "${_found_utils:=0}"
if [ "$_found_utils" -eq 0 ]; then
  printf 'cohesion: missing cohesion-utils.sh\n' >&2; exit 1
fi
# Rotate log if needed (before unsetting variables)
if [ -f "$_script_dir/../utils/log-rotation.sh" ]; then
  . "$_script_dir/../utils/log-rotation.sh"
  rotate_debug_log 2>/dev/null || true
fi

unset _script_dir _u _utils_candidates _found_utils

# Read input
input="$(cat)"

# Debug logging
echo "$(date '+%Y-%m-%d %H:%M:%S'): Pre-tool-use input: $input" >> "$STATE_DIR/.hook_debug" 2>/dev/null || true

# Extract tool name and parameters
tool_name="$(echo "$input" | jq -r '.tool_name // .tool // ""' 2>/dev/null || echo "")"
# Try multiple possible locations for file_path (different Claude versions use different structures)
file_path="$(echo "$input" | jq -r '.tool_input.file_path // .parameters.file_path // .file_path // ""' 2>/dev/null || echo "")"

# For Edit/Write tools, also check the first argument if file_path is empty
if [[ -z "$file_path" ]] && [[ "$tool_name" =~ ^(Edit|Write|MultiEdit)$ ]]; then
  # Try to extract from arguments array or other common locations
  file_path="$(echo "$input" | jq -r '.tool_input.arguments[0] // .parameters.path // .path // ""' 2>/dev/null || echo "")"
fi
session_id="$(echo "$input" | jq -r '.session_id // ""' 2>/dev/null || echo "")"

# ═══════════════════════════════════════════════════════════════
# 🛡️ BULLETPROOF SYSTEM HEALTH MONITOR
# ═══════════════════════════════════════════════════════════════
ensure_cohesion_health() {
  local state_file="$STATE_DIR/.cohesion_state.json"
  local current_time="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local needs_repair=false
  
  # Initialize JSON state if missing (emergency bootstrap)
  if [[ ! -f "$state_file" ]]; then
    log_internal "🚨 EMERGENCY: No state file found - bootstrapping"
    create_emergency_state "$current_time"
    needs_repair=true
  fi
  
  # Load current state
  local state
  if ! state="$(cat "$state_file" 2>/dev/null)"; then
    log_internal "🚨 EMERGENCY: Corrupted state file - recreating"
    create_emergency_state "$current_time"
    state="$(cat "$state_file")"
    needs_repair=true
  fi
  
  # Check session initialization
  local session_init="$(echo "$state" | jq -r '.session.initialized // false')"
  if [[ "$session_init" != "true" ]]; then
    log_internal "🚨 REPAIR: Session never initialized - fixing"
    update_state_field ".session.initialized" "true"
    update_state_field ".session.init_method" "pretool_bootstrap"
    update_state_field ".session.init_timestamp" "$current_time"
    needs_repair=true
  fi
  
  # Check banner visibility
  local banner_shown="$(echo "$state" | jq -r '.ui.banner_shown // false')"
  if [[ "$banner_shown" != "true" ]]; then
    log_internal "🚨 REPAIR: Banner never shown - displaying backup"
    show_backup_banner
    update_state_field ".ui.banner_shown" "true"
    update_state_field ".ui.banner_method" "pretool_backup"
    needs_repair=true
  fi
  
  # Update system health
  update_state_field ".system.last_health_check" "$current_time"
  update_state_field ".system.pretool_run_count" "$(($(get_state_field '.system.pretool_run_count // 0') + 1))"
  
  if [[ "$needs_repair" == "true" ]]; then
    update_state_field ".system.health_status" "repaired"
    log_internal "✅ REPAIR COMPLETE: System health restored"
  else
    update_state_field ".system.health_status" "healthy"
  fi
}

# Internal logging (Claude debugging only)
log_internal() {
  echo "$(date '+%Y-%m-%d %H:%M:%S'): HEALTH: $1" >> "$STATE_DIR/.cohesion_internal.log" 2>/dev/null || true
}

# JSON state utilities
create_emergency_state() {
  local timestamp="$1"
  local current_mode="$(get_cohesion_mode 2>/dev/null || echo 'DISCOVER')"
  
  cat > "$STATE_DIR/.cohesion_state.json" << EOF
{
  "meta": {
    "version": "1.0.0",
    "last_updated": "$timestamp",
    "schema_version": "1"
  },
  "session": {
    "initialized": false,
    "init_method": "emergency",
    "init_timestamp": "$timestamp",
    "session_count": 1,
    "first_session": true
  },
  "mode": {
    "current": "$current_mode",
    "previous": null,
    "last_transition": "$timestamp",
    "transition_method": "emergency",
    "pending_transition": null
  },
  "ui": {
    "banner_shown": false,
    "banner_method": null,
    "last_status_check": null,
    "user_guidance_level": "first_time"
  },
  "system": {
    "health_status": "emergency",
    "last_health_check": "$timestamp",
    "failed_hooks": [],
    "recovery_actions": [],
    "pretool_run_count": 0
  },
  "internal": {
    "debug_enabled": true,
    "last_errors": [],
    "repair_log": ["$timestamp: Emergency state created"]
  }
}
EOF
}

update_state_field() {
  local field="$1"
  local value="$2"
  local state_file="$STATE_DIR/.cohesion_state.json"
  
  if command -v jq >/dev/null 2>&1; then
    local temp_file="$(mktemp)"
    jq "$field = \"$value\"" "$state_file" > "$temp_file" 2>/dev/null && mv "$temp_file" "$state_file" || rm -f "$temp_file"
  fi
}

get_state_field() {
  local field="$1"
  local state_file="$STATE_DIR/.cohesion_state.json"
  
  if [[ -f "$state_file" ]] && command -v jq >/dev/null 2>&1; then
    jq -r "$field" "$state_file" 2>/dev/null || echo "null"
  else
    echo "null"
  fi
}

show_backup_banner() {
  local current_mode="$(get_cohesion_mode 2>/dev/null || echo 'DISCOVER')"
  printf "\n🚀 Cohesion Active - %s Mode | Run /status for full overview\n\n" "$current_mode" >&2
}

# Execute health check on every tool use
ensure_cohesion_health

# Track tool usage
if [[ -n "$tool_name" ]]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S'): $tool_name" >> "$STATE_DIR/.tool_usage"
  # Also track simplified for canon progress detection
  echo "$(date +%s):$tool_name" >> "$STATE_DIR/.tool_history"
fi

# Function to check if file is approved
is_file_approved() {
  local file="$1"
  [[ -z "$file" ]] && return 1
  
  # Debug: Log what we're checking
  echo "Checking approval for: $file" >> "$STATE_DIR/.hook_debug" 2>/dev/null || true
  
  if [[ -f "$STATE_DIR/.approved_edits" ]]; then
    echo "Approved files list exists" >> "$STATE_DIR/.hook_debug" 2>/dev/null || true
    while IFS= read -r approved_file; do
      echo "  Comparing with: $approved_file" >> "$STATE_DIR/.hook_debug" 2>/dev/null || true
      # Check both exact match and basename match (in case of path issues)
      if [[ "$file" == "$approved_file" ]] || [[ "$(basename "$file")" == "$(basename "$approved_file")" ]]; then
        echo "  MATCH FOUND!" >> "$STATE_DIR/.hook_debug" 2>/dev/null || true
        return 0
      fi
    done < "$STATE_DIR/.approved_edits"
  else
    echo "No approved files list found" >> "$STATE_DIR/.hook_debug" 2>/dev/null || true
  fi
  return 1
}

# Get current mode
current_mode="$(get_cohesion_mode)"

# Canon Enforcement
if [[ -f "$STATE_DIR/.canon_active" ]]; then
  # Auto-detect progress based on tool usage
  track_canon_progress() {
    local phase=$(cat "$STATE_DIR/.canon_phase" 2>/dev/null || echo "")
    local progress=$(cat "$STATE_DIR/.task_progress" 2>/dev/null || echo "")
    
    # If in task_received phase and exploration tools used, mark as analyzed
    if [[ "$phase" == "task_received" ]] && [[ "$progress" != "analyzed" ]]; then
      if [[ "$tool_name" =~ ^(Read|Grep|Glob|LS)$ ]]; then
        echo "analyzed" > "$STATE_DIR/.task_progress"
      fi
    fi
    
    # If in mismatch_detected phase and investigation tools used
    if [[ "$phase" == "mismatch_detected" ]] && [[ "$progress" != "investigated" ]]; then
      if [[ "$tool_name" =~ ^(Read|Grep|Bash)$ ]]; then
        echo "investigated" > "$STATE_DIR/.task_progress"
      fi
    fi
    
    # If in significant_change phase and impact analysis tools used
    if [[ "$phase" == "significant_change" ]] && [[ "$progress" != "analyzed" ]]; then
      if [[ "$tool_name" =~ ^(Read|Grep|Glob|LS)$ ]]; then
        echo "analyzed" > "$STATE_DIR/.task_progress"
      fi
    fi
    
    # If in refactor_wildcard phase and exploration tools used
    if [[ "$phase" == "refactor_wildcard" ]] && [[ "$progress" != "analyzed" ]]; then
      if [[ "$tool_name" =~ ^(Read|Grep|Glob|LS)$ ]]; then
        echo "analyzed" > "$STATE_DIR/.task_progress"
      fi
    fi
    
    # Detect test execution
    if [[ "$tool_name" == "Bash" ]]; then
      local cmd=$(echo "$input" | jq -r '.tool_input.command // .parameters.command // ""' 2>/dev/null)
      if [[ "$cmd" =~ (test|spec|jest|mocha|pytest|npm.*test|yarn.*test) ]]; then
        echo "tested" >> "$STATE_DIR/.task_progress"
      fi
    fi
  }
  
  # Enforce canon based on phase and progress
  enforce_canon() {
    local tool="$1"
    local phase=$(cat "$STATE_DIR/.canon_phase" 2>/dev/null || echo "")
    local progress=$(cat "$STATE_DIR/.task_progress" 2>/dev/null || echo "")
    
    # Canon enforcement rules from canon-cache.md
    case "$phase" in
      task_received)
        # Think-First: Must analyze before implementing
        if [[ "$tool" =~ ^(Write|Edit|MultiEdit)$ ]] && [[ "$progress" != "analyzed" ]]; then
          echo '{"permissionDecision": "deny", "reason": "🧠 THINK-FIRST: Analysis required before implementation.\n\nYou must first:\n1. Read and understand existing code\n2. Document what needs to change\n3. Identify potential issues\n\nUse Read/Grep/Glob to explore first."}'
          exit 0
        fi
        ;;
        
      claiming_success)
        # Always-Works: Must verify before claiming done
        if [[ "$tool" == "Bash" ]]; then
          local cmd=$(echo "$input" | jq -r '.tool_input.command // .parameters.command // ""' 2>/dev/null)
          if [[ "$cmd" =~ (commit|push|deploy|merge) ]] && [[ "$progress" != *"tested"* ]]; then
            echo '{"permissionDecision": "deny", "reason": "✅ ALWAYS-WORKS: Verification required before claiming success.\n\nYou must:\n1. Run tests to verify functionality\n2. Check edge cases\n3. Confirm it actually works\n\nRun tests first, then try again."}'
            exit 0
          fi
        fi
        ;;
        
      mismatch_detected)
        # Reality-Check: Must investigate before fixing
        if [[ "$tool" =~ ^(Write|Edit|MultiEdit)$ ]] && [[ "$progress" != "investigated" ]]; then
          echo '{"permissionDecision": "deny", "reason": "🔍 REALITY-CHECK: Investigation required.\n\nWhen expected ≠ actual:\n1. Document what you expected\n2. Document what actually happened\n3. Find the root cause\n\nInvestigate with Read/Grep first."}'
          exit 0
        fi
        ;;
        
      change_requested)
        # Approval-Criteria: In OPTIMIZE mode, already handled by mode logic
        # But reinforce the message
        if [[ "$current_mode" == "OPTIMIZE" ]] && [[ "$tool" =~ ^(Write|Edit|MultiEdit)$ ]]; then
          if [[ -n "$file_path" ]] && ! is_file_approved "$file_path"; then
            echo '{"permissionDecision": "deny", "reason": "📋 APPROVAL-CRITERIA: This change requires explicit approval.\n\nIn OPTIMIZE mode, file modifications need approval.\nThe user must approve with: /approve '"$file_path"'"}'
            exit 0
          fi
        fi
        ;;
        
      significant_change)
        # Close-the-Loop: Major system changes need impact analysis
        if [[ "$tool" =~ ^(Write|Edit|MultiEdit)$ ]] && [[ "$progress" != "analyzed" ]]; then
          if [[ "$current_mode" == "OPTIMIZE" ]]; then
            # 90% enforcement in OPTIMIZE mode
            echo '{"permissionDecision": "deny", "reason": "🔗 CLOSE-THE-LOOP: Major system change requires impact analysis.\n\nBefore implementing:\n1. Analyze effect on documentation\n2. Identify test updates needed\n3. Check configuration dependencies\n4. Review component interactions\n\nUse Read/Grep to analyze impacts first."}'
            exit 0
          elif [[ "$current_mode" == "DISCOVER" ]]; then
            # Occasional enforcement in DISCOVER mode (lighter guidance)
            local should_enforce=$((RANDOM % 10 < 3))  # 30% chance
            if [[ $should_enforce -eq 1 ]]; then
              echo '{"permissionDecision": "deny", "reason": "🔗 CLOSE-THE-LOOP: This appears to be a major system change.\n\nConsider analyzing impact on:\n• Documentation that may need updates\n• Tests that may need modification\n• Configuration dependencies\n\nUse Read/Grep to explore, or /unleash to proceed."}'
              exit 0
            fi
          fi
        fi
        ;;
        
      refactor_wildcard)
        # Refactor wildcard: Lightweight guidance based on mode
        if [[ "$tool" =~ ^(Write|Edit|MultiEdit)$ ]] && [[ "$progress" != "analyzed" ]]; then
          if [[ "$current_mode" == "OPTIMIZE" ]]; then
            # 70% enforcement in OPTIMIZE mode
            local should_enforce=$((RANDOM % 10 < 7))
            if [[ $should_enforce -eq 1 ]]; then
              echo '{"permissionDecision": "deny", "reason": "🔄 REFACTOR-AWARENESS: Refactoring scope unclear.\n\nBefore proceeding:\n• Will this affect multiple components?\n• Are there interface changes involved?\n• Should other parts of the system be updated?\n\nUse Read/Grep to understand scope first."}'
              exit 0
            fi
          elif [[ "$current_mode" == "DISCOVER" ]]; then
            # 30% enforcement in DISCOVER mode
            local should_enforce=$((RANDOM % 10 < 3))
            if [[ $should_enforce -eq 1 ]]; then
              echo '{"permissionDecision": "deny", "reason": "🔄 REFACTOR-AWARENESS: Consider the refactor scope.\n\nQuestions to consider:\n• Is this a simple cleanup or broader change?\n• Will it affect how other code interacts with this?\n\nExplore with Read/Grep, or /unleash to proceed."}'
              exit 0
            fi
          fi
          # UNLEASH mode: No enforcement (internalized)
        fi
        ;;
    esac
  }
  
  # Track progress then enforce
  track_canon_progress
  enforce_canon "$tool_name"
fi

# Check protected paths (applies to all modes)
check_protected_path() {
  local path="$1"
  [[ -z "$path" ]] && return 0
  
  # Check global protected paths
  if [[ -f "$HOME/.cohesion/protected.conf" ]]; then
    while IFS= read -r pattern; do
      [[ -z "$pattern" || "$pattern" =~ ^# ]] && continue
      if [[ "$path" =~ $pattern ]]; then
        echo '{"permissionDecision": "deny", "reason": "Protected path: '"$path"' matches pattern: '"$pattern"'"}'
        exit 0
      fi
    done < "$HOME/.cohesion/protected.conf"
  fi
  
  # Check project protected paths
  if [[ -f "./.claude/protected.conf" ]]; then
    while IFS= read -r pattern; do
      [[ -z "$pattern" || "$pattern" =~ ^# ]] && continue
      if [[ "$path" =~ $pattern ]]; then
        echo '{"permissionDecision": "deny", "reason": "Protected path: '"$path"' matches pattern: '"$pattern"'"}'
        exit 0
      fi
    done < "./.claude/protected.conf"
  fi
  
  return 0
}

# Check if file path is protected
if [[ -n "$file_path" ]]; then
  check_protected_path "$file_path"
fi

# Special handling for slash commands (allowed in all modes)
if [[ "$tool_name" == "Bash" ]]; then
  cmd=$(echo "$input" | jq -r '.tool_input.command // .parameters.command // ""' 2>/dev/null)
  if [[ "$cmd" =~ ^\.claude/commands/ ]]; then
    echo '{
      "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "allow",
        "permissionDecisionReason": "Slash command - always allowed"
      }
    }'
    exit 0
  fi
fi

# Define tool lists for each mode
DISCOVER_TOOLS="Read|NotebookRead|LS|Grep|Glob|WebSearch|WebFetch|TodoRead|TodoWrite"
OPTIMIZE_AUTO="Read|NotebookRead|LS|Grep|Glob|WebSearch|WebFetch|TodoRead|TodoWrite"
OPTIMIZE_APPROVE="Write|Edit|MultiEdit|NotebookEdit|Bash|Agent"

# Mode-based permission decisions
case "$current_mode" in
  DISCOVER)
    # DISCOVER mode: Read-only operations with documentation writing allowed
    if [[ "$tool_name" =~ ^($DISCOVER_TOOLS)$ ]]; then
      # Explicitly approve read-only tools and TodoWrite
      echo '{
        "hookSpecificOutput": {
          "hookEventName": "PreToolUse",
          "permissionDecision": "allow",
          "permissionDecisionReason": "DISCOVER mode - read-only operation"
        }
      }'
    elif [[ "$tool_name" =~ ^(Write|Edit|MultiEdit)$ ]] && [[ "$file_path" =~ (STATE\.md|DETAILED_EXECUTION_PLAN\.md|docs/.*\.md) ]]; then
      # Allow writing documentation files in DISCOVER mode
      echo '{
        "hookSpecificOutput": {
          "hookEventName": "PreToolUse",
          "permissionDecision": "allow",
          "permissionDecisionReason": "DISCOVER mode - documentation writing allowed"
        }
      }'
    elif [[ "$tool_name" == "Bash" ]]; then
      # Check if bash command is safe/read-only
      cmd=$(echo "$input" | jq -r '.tool_input.command // .parameters.command // ""' 2>/dev/null)
      # Extract just the command name (first word)
      cmd_name=$(echo "$cmd" | awk '{print $1}')
      
      # List of safe read-only bash commands (expanded for better exploration)
      safe_commands="ls|cd|cat|pwd|echo|grep|find|head|tail|wc|sort|uniq|diff|file|which|type|env|date|whoami|hostname|uname|tree|du|df|less|more|sed|awk|cut|tr|basename|dirname|readlink|stat|md5sum|sha256sum"
      
      # Check for output redirection or other write operations
      if [[ "$cmd" =~ (\>|\>\>|\|.*\>|tee) ]]; then
        echo '{"permissionDecision": "deny", "reason": "🔍 DISCOVER mode: Output redirection is not allowed. Use read-only commands only."}'
      elif [[ "$cmd_name" =~ ^($safe_commands)$ ]] || [[ "$cmd" =~ ^git[[:space:]]+(status|log|diff|branch|show|remote) ]] || [[ "$cmd" =~ ^ls[[:space:]] ]]; then
        echo '{
          "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "allow",
            "permissionDecisionReason": "DISCOVER mode - safe bash command"
          }
        }'
      else
        echo '{"permissionDecision": "deny", "reason": "🔍 DISCOVER mode: Only read-only bash commands are allowed. Commands like ls, cat, grep, git status are permitted."}'
      fi
    else
      # Block everything else
      echo '{"permissionDecision": "deny", "reason": "🔍 DISCOVER mode: Focusing on understanding and analysis. This operation requires write access."}'
    fi
    ;;
    
  OPTIMIZE)
    # OPTIMIZE mode: Collaborative with approvals
    if [[ "$tool_name" =~ ^($OPTIMIZE_AUTO)$ ]]; then
      # Auto-approve safe operations
      echo '{
        "hookSpecificOutput": {
          "hookEventName": "PreToolUse",
          "permissionDecision": "allow",
          "permissionDecisionReason": "OPTIMIZE mode - auto-approved operation"
        }
      }'
    elif [[ "$tool_name" =~ ^($OPTIMIZE_APPROVE)$ ]]; then
      # Check if file is approved for operations that need approval
      if [[ -n "$file_path" ]]; then
        if is_file_approved "$file_path"; then
          echo '{
            "hookSpecificOutput": {
              "hookEventName": "PreToolUse",
              "permissionDecision": "allow",
              "permissionDecisionReason": "OPTIMIZE mode - file approved for editing"
            }
          }'
        else
          echo '{"permissionDecision": "deny", "reason": "✨ OPTIMIZE mode: Collaborative development - this file needs approval before editing. The user can approve with: /approve '"$file_path"'"}'
        fi
      else
        # For tools without file paths (like Bash), require explicit approval
        echo '{"permissionDecision": "deny", "reason": "✨ OPTIMIZE mode: Collaborative development - this operation requires user approval to proceed."}'
      fi
    else
      # Unknown tools - default to requiring approval
      echo '{"permissionDecision": "deny", "reason": "✨ OPTIMIZE mode: Collaborative development - this operation requires user approval."}'
    fi
    ;;
    
  UNLEASH)
    # UNLEASH mode: Full autonomy (only check protected paths)
    # Protected paths already checked above, so approve everything else
    echo '{
      "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "allow",
        "permissionDecisionReason": "UNLEASH mode - full autonomy enabled"
      }
    }'
    ;;
    
  *)
    # Unknown mode - default to DISCOVER behavior for safety
    if [[ "$tool_name" =~ ^($DISCOVER_TOOLS)$ ]]; then
      echo '{
        "hookSpecificOutput": {
          "hookEventName": "PreToolUse",
          "permissionDecision": "allow",
          "permissionDecisionReason": "Unknown mode - defaulting to safe operation"
        }
      }'
    else
      echo '{"permissionDecision": "deny", "reason": "Mode not recognized - defaulting to read-only for safety. Check system state."}'
    fi
    ;;
esac