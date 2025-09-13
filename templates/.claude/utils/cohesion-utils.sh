#!/usr/bin/env bash
# Cohesion Hook Utilities - Optimized + Approvals
# Minimal, fast utilities for hook operations

# Prevent double-sourcing
if [[ -n "${COHESION_UTILS_LOADED:-}" ]]; then
  return 0
fi
readonly COHESION_UTILS_LOADED=1

set -euo pipefail

# ============================================================================
# CONSTANTS
# ============================================================================
readonly CYAN='\033[0;96m'     # DISCOVER
readonly YELLOW='\033[1;93m'   # UNLEASH
readonly JADE='\033[0;36m'     # OPTIMIZE
readonly AMBER='\033[0;33m'    # Warning
readonly RED='\033[0;91m'      # Error
readonly NC='\033[0m'

# shellcheck disable=SC2034
readonly COHESION_EMOJI="🤝"
readonly DISCOVER_EMOJI="🔍"
readonly UNLEASH_EMOJI="⚡"
readonly OPTIMIZE_EMOJI="✨"
readonly BLOCKED_EMOJI="⏺"
readonly PROTECTED_EMOJI="🛡️"
readonly WARNING_EMOJI="⚠️"

# Paths relative to .claude
CLAUDE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd -P)"
readonly CLAUDE_DIR
PROJECT_DIR="$(cd "$CLAUDE_DIR/.." && pwd -P)"
readonly PROJECT_DIR
readonly HOOKS_DIR="$CLAUDE_DIR/hooks"
readonly STATE_DIR="$CLAUDE_DIR/state"
readonly UTILS_DIR="$CLAUDE_DIR/utils"
readonly PROTECTED_CONF="$CLAUDE_DIR/protected.conf"
readonly LOG_DIR="$HOOKS_DIR/logs"
readonly APPROVALS_FILE="$STATE_DIR/approvals.txt"

# Global cohesion paths (for uninstall scripts)
: "${COHESION_HOME:=${COHESION_DIR:-$HOME/.cohesion}}"
: "${MANIFEST_FILE:=${COHESION_HOME}/.manifest.json}"
: "${GLOBAL_CLAUDE_MD:=$HOME/CLAUDE.md}"
: "${CLAUDE_HOME:=$HOME/.claude}"

mkdir -p "$STATE_DIR" 2>/dev/null || true

# Source docs environment if available
if [[ -f "$CLAUDE_DIR/docs.env" ]]; then
  # shellcheck disable=SC1090
  source "$CLAUDE_DIR/docs.env"
fi

# Set default values if not provided
: "${DOCS_DIR:=$PROJECT_DIR/docs}"
: "${PROGRESS_DIR:=$DOCS_DIR/04-progress}"
: "${ALLOW_DISCOVER_DOC_WRITES:=1}"

# Ensure required directories exist
mkdir -p "$DOCS_DIR" "$PROGRESS_DIR" 2>/dev/null || true

# ============================================================================
# RESPONSE BUILDERS
# ============================================================================
build_response() {
  local continue_val="$1"
  local message="${2:-}"
  if [[ -n "$message" ]]; then
    message="$(printf '%s' "$message" | sed 's/"/\\"/g' | tr '\n' '\\n')"
    printf '{"continue": %s, "systemMessage": "%s"}\n' "$continue_val" "$message"
  else
    printf '{"continue": %s}\n' "$continue_val"
  fi
}

build_success_response(){ build_response "true" "${1:-}"; }
build_error_response(){ 
  local m; m="$(printf '%s' "$1" | sed 's/"/\\"/g' | tr '\n' '\\n')"
  # Show error in RED to stderr, then return JSON response
  printf "${RED}ERROR: %s${NC}\n" "$1" >&2
  printf '{"continue": false, "error": "%s"}\n' "$m"
}
build_warning_response(){
  local m; m="$(printf '%s' "$1" | sed 's/"/\\"/g' | tr '\n' '\\n')"
  # Show warning in AMBER to stderr, then return JSON response
  printf "${AMBER}${WARNING_EMOJI} WARNING: %s${NC}\n" "$1" >&2
  printf '{"continue": true, "systemMessage": "%s"}\n' "$m"
}
build_protection_message(){
  local file="$1"
  printf "${JADE}${PROTECTED_EMOJI} PROTECTED: %s${NC}\n" "$file" >&2
  printf '{"continue": false, "error": "File %s is protected from modification"}\n' "$file"
}

# ============================================================================
# STATE
# ============================================================================
get_cohesion_mode() {
  if [[ -z "${_CACHED_MODE:-}" ]]; then
    # Count mode files to detect conflicts
    local mode_count=0
    [[ -f "$STATE_DIR/UNLEASHED" ]] && ((mode_count++))
    [[ -f "$STATE_DIR/OPTIMIZE" ]] && ((mode_count++))
    [[ -f "$STATE_DIR/DISCOVER" ]] && ((mode_count++))

    # If multiple mode files exist, clean up and default to DISCOVER
    if [[ $mode_count -gt 1 ]]; then
      >&2 echo "⚠️  WARNING: Multiple mode files detected. Cleaning up..."
      rm -f "$STATE_DIR/UNLEASHED" "$STATE_DIR/OPTIMIZE" "$STATE_DIR/DISCOVER" 2>/dev/null || true
      echo "DISCOVER mode initialized (conflict resolution)" > "$STATE_DIR/DISCOVER"
      _CACHED_MODE="DISCOVER"
    elif [[ -f "$STATE_DIR/UNLEASHED" ]]; then _CACHED_MODE="UNLEASH"
    elif [[ -f "$STATE_DIR/OPTIMIZE"  ]]; then _CACHED_MODE="OPTIMIZE"
    elif [[ -f "$STATE_DIR/DISCOVER"  ]]; then _CACHED_MODE="DISCOVER"
    else                                       _CACHED_MODE="DISCOVER"  # Default
    fi
  fi
  printf '%s\n' "$_CACHED_MODE"
}

set_mode() {
  local s="${1:?}"
  mkdir -p "$STATE_DIR" 2>/dev/null || true
  rm -f "$STATE_DIR/UNLEASHED" "$STATE_DIR/OPTIMIZE" "$STATE_DIR/DISCOVER" 2>/dev/null || true
  case "$s" in
    UNLEASH) 
      echo "Mode: UNLEASH - Building with earned autonomy" > "$STATE_DIR/UNLEASHED"
      echo "Philosophy: You thought first, now build freely" >> "$STATE_DIR/UNLEASHED"
      echo "Remember: Stay in flow until you need help" >> "$STATE_DIR/UNLEASHED"
      ;;
    OPTIMIZE)
      echo "Mode: OPTIMIZE - Collaborative thinking" > "$STATE_DIR/OPTIMIZE"
      echo "Philosophy: Two minds prevent costly mistakes" >> "$STATE_DIR/OPTIMIZE"
      echo "Remember: Discussion deepens understanding" >> "$STATE_DIR/OPTIMIZE"
      ;;
    *)
      echo "Mode: DISCOVER - Understanding before action" > "$STATE_DIR/DISCOVER"
      echo "Philosophy: 10 minutes thinking = 1 hour saved" >> "$STATE_DIR/DISCOVER"
      echo "Remember: The best code is written in your mind first" >> "$STATE_DIR/DISCOVER"
      ;;
  esac
  _CACHED_MODE="" # clear cache
  date -u +"%Y-%m-%dT%H:%M:%SZ" > "$STATE_DIR/.last_transition"
}

# Complete state transition with settings file management
transition_to_mode() {
  local target_mode="${1:?}"
  
  # Set the mode state (which also records timestamp)
  set_mode "$target_mode"
  
  # Log the transition for debugging
  log_message "INFO" "Mode transition to $target_mode completed"
  
  # Update STATE.md if it exists (lightweight sync)
  if [[ -f "$PROJECT_DIR/docs/STATE.md" ]]; then
    # Update just the mode line without full regeneration
    if grep -q "^**Current Mode:**" "$PROJECT_DIR/docs/STATE.md" 2>/dev/null; then
      local mode_emoji=""
      case "$target_mode" in
        UNLEASH)  mode_emoji="$UNLEASH_EMOJI UNLEASH" ;;
        OPTIMIZE) mode_emoji="$OPTIMIZE_EMOJI OPTIMIZE" ;;
        *)        mode_emoji="$DISCOVER_EMOJI DISCOVER" ;;
      esac
      # Use sed to update the mode line in-place
      sed -i.bak "s/^\*\*Current Mode:\*\*.*/\*\*Current Mode:\*\* $mode_emoji/" "$PROJECT_DIR/docs/STATE.md" 2>/dev/null || true
      rm -f "$PROJECT_DIR/docs/STATE.md.bak" 2>/dev/null || true
    fi
  fi
  
  # No longer swap settings files - hooks enforce restrictions
  # Settings.local.json now has all permissions, hooks block based on state
  # This prevents race conditions and allows immediate mode transitions
}

get_state_emoji() {
  case "$(get_cohesion_mode)" in
    UNLEASH)  echo "$UNLEASH_EMOJI" ;;
    OPTIMIZE) echo "$OPTIMIZE_EMOJI" ;;
    *)        echo "$DISCOVER_EMOJI" ;;
  esac
}

# ============================================================================
# LOGGING (opt-in)
# ============================================================================
log_message() {
  local level="$1" msg="$2"
  if [[ -n "${COHESION_LOG:-}" || -n "${DEBUG:-}" ]]; then
    local ts; ts="$(date '+%Y-%m-%d %H:%M:%S')"
    local line="[$ts] [$level] $msg"
    if [[ -n "${COHESION_LOG:-}" ]]; then
      mkdir -p "$LOG_DIR" 2>/dev/null || true
      echo "$line" >> "$LOG_DIR/cohesion.log"
    fi
    [[ -n "${DEBUG:-}" ]] && echo "$line" >&2 || true
  fi
}

# ============================================================================
# TOOL POLICY
# ============================================================================
is_tool_allowed() {
  local tool="$1" mode; mode="$(get_cohesion_mode)"
  case "$mode" in
    UNLEASH) return 0 ;;
    OPTIMIZE)
      case "$tool" in
        Read|Grep|Glob|WebSearch|WebFetch|TodoWrite|TodoRead|Bash|Write|Edit|MultiEdit|NotebookEdit) return 0 ;;
        *) return 1 ;;
      esac
      ;;
    DISCOVER)
      case "$tool" in
        Read|Grep|Glob|WebSearch|WebFetch|TodoWrite|TodoRead|Bash) return 0 ;;
        *) return 1 ;;
      esac
      ;;
  esac
}

# ============================================================================
# PATH PROTECTION
# ============================================================================
is_protected_path() {
  local file_path="${1:-}"
  [[ -z "$file_path" ]] && return 1
  [[ -f "$PROTECTED_CONF" ]] || return 1
  while IFS= read -r pattern; do
    [[ -z "$pattern" || "$pattern" =~ ^# ]] && continue
    [[ "$file_path" =~ $pattern ]] && return 0
  done < "$PROTECTED_CONF"
  return 1
}

# ============================================================================
# SHELL SAFETY
# ============================================================================
is_dangerous_command() {
  local cmd="${1:-}"
  [[ "$cmd" =~ (rm[[:space:]].*-rf|rm[[:space:]].*-fr|chmod[[:space:]].*777|curl.*\|.*sh|\>[[:space:]]*\/dev\/sd|dd.*if=\/dev\/zero.*of=\/dev) ]]
}

is_safe_bash_command() {
  local cmd="${1:-}"
  [[ "$cmd" =~ ^(ls|pwd|echo|cat|grep|find|which|whoami|date|env|ps|df|du|head|tail|wc|sort|uniq|diff|file|stat|readlink|dirname|basename|git\ (status|log|diff|branch|remote)|npm\ (list|outdated)|yarn\ list)(\ |$) ]]
}

# ============================================================================
# APPROVALS (new)
# ============================================================================
canonicalize_path() {
  local p="${1:?}"
  # Make absolute relative to project root
  if [[ "$p" != /* ]]; then
    p="$PROJECT_DIR/$p"
  fi
  # Collapse via cd trick
  local d b
  d="$(dirname -- "$p")" || return 1
  b="$(basename -- "$p")" || return 1
  (cd "$d" 2>/dev/null && printf '%s/%s\n' "$(pwd -P)" "$b") || return 1
}

approve_edit() {
  local raw="${1:?}"
  mkdir -p "$STATE_DIR" 2>/dev/null || true
  local canon; canon="$(canonicalize_path "$raw")" || return 1
  touch "$APPROVALS_FILE"
  # de-dup exact lines
  if ! grep -Fxq "$canon" "$APPROVALS_FILE"; then
    echo "$canon" >> "$APPROVALS_FILE"
  fi
  printf '%s\n' "$canon"
}

is_approved_edit() {
  local raw="${1:-}"
  [[ -s "$APPROVALS_FILE" ]] || return 1
  local canon; canon="$(canonicalize_path "$raw")" || return 1
  while IFS= read -r allow; do
    [[ -z "$allow" ]] && continue
    # exact file or inside approved directory
    if [[ "$canon" == "$allow" || "$canon" == "$allow"/* ]]; then
      return 0
    fi
  done < "$APPROVALS_FILE"
  return 1
}

list_approvals() { [[ -s "$APPROVALS_FILE" ]] && cat "$APPROVALS_FILE" || true; }
clear_approvals(){ rm -f "$APPROVALS_FILE"; }

# ============================================================================
# MESSAGES
# ============================================================================
build_blocked_message() {
  local tool="$1" mode; mode="$(get_cohesion_mode)"
  case "$mode" in
    OPTIMIZE)
      printf "%s COHESION: %s blocked in OPTIMIZE mode\n%s Collaboration mode active\n💡 Why blocked: Prevents unwanted changes, ensures quality\nTo proceed: \"approve edits to ./path/file\"\nRemember: 10 min planning = 1 hour saved" "${BLOCKED_EMOJI}" "$tool" "${OPTIMIZE_EMOJI}"
      ;;
    UNLEASH)
      printf "%s COHESION: %s blocked in UNLEASH mode\n%s Autonomous mode active\n💡 Why blocked: Safety check triggered\nTo proceed: Address the issue or override protection" "${BLOCKED_EMOJI}" "$tool" "${UNLEASH_EMOJI}"
      ;;
    *)
      printf "%s COHESION: %s blocked in DISCOVER mode\n%s Thinking mode active\n💡 Why blocked: You're saving future debugging time by thinking first\nWhat's your understanding of the problem?\nPresent your plan, then get approval with \"approved\"" "${BLOCKED_EMOJI}" "$tool" "${DISCOVER_EMOJI}"
      ;;
  esac
}

build_blocked_message_colored() {
  local tool="$1" mode; mode="$(get_cohesion_mode)"
  case "$mode" in
    OPTIMIZE)
      printf "${JADE}%s COHESION: %s blocked in OPTIMIZE mode${NC}\n${JADE}%s Collaboration mode active${NC}\n💡 Why blocked: Prevents unwanted changes, ensures quality\nTo proceed: \"approve edits to ./path/file\"\nRemember: 10 min planning = 1 hour saved" "${BLOCKED_EMOJI}" "$tool" "${OPTIMIZE_EMOJI}"
      ;;
    UNLEASH)
      printf "${YELLOW}%s COHESION: %s blocked in UNLEASH mode${NC}\n${YELLOW}%s Autonomous mode active${NC}\n💡 Why blocked: Safety check triggered\nTo proceed: Address the issue or override protection" "${BLOCKED_EMOJI}" "$tool" "${UNLEASH_EMOJI}"
      ;;
    *)
      printf "${CYAN}%s COHESION: %s blocked in DISCOVER mode${NC}\n${CYAN}%s Thinking mode active${NC}\n💡 Why blocked: You're saving future debugging time by thinking first\nWhat's your understanding of the problem?\nPresent your plan, then get approval with \"approved\"" "${BLOCKED_EMOJI}" "$tool" "${DISCOVER_EMOJI}"
      ;;
  esac
}

# ============================================================================
# SESSION CONTEXT MANAGEMENT
# ============================================================================

# Save session context for persistence
save_session_context() {
  local session_id="${1:-unknown}"
  local context_file="$STATE_DIR/.session_context"
  local timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  
  # Get current mode
  local current_mode="$(get_cohesion_mode)"
  
  # Create context JSON
  cat > "$context_file" <<EOF
{
  "session_id": "$session_id",
  "timestamp": "$timestamp",
  "mode": "$current_mode",
  "project_dir": "$PROJECT_DIR",
  "state_dir": "$STATE_DIR",
  "approvals": $(list_approved_files_json 2>/dev/null || echo "[]"),
  "last_transition": "$(cat "$STATE_DIR/.last_transition" 2>/dev/null || echo "")"
}
EOF
  
  log_message "INFO" "Session context saved: $session_id in $current_mode mode"
}

# Restore session context
restore_session_context() {
  local context_file="$STATE_DIR/.session_context"
  
  if [[ -f "$context_file" ]]; then
    local mode="$(jq -r '.mode // "DISCOVER"' "$context_file" 2>/dev/null || echo "DISCOVER")"
    local session_id="$(jq -r '.session_id // "unknown"' "$context_file" 2>/dev/null)"
    local timestamp="$(jq -r '.timestamp // ""' "$context_file" 2>/dev/null)"
    
    echo "{
      \"mode\": \"$mode\",
      \"session_id\": \"$session_id\",
      \"timestamp\": \"$timestamp\",
      \"restored\": true
    }"
    
    log_message "INFO" "Session context restored: $session_id from $timestamp"
  else
    echo '{"mode": "DISCOVER", "restored": false}'
    log_message "INFO" "No session context to restore - starting fresh"
  fi
}

# List approved files as JSON array
list_approved_files_json() {
  local approvals_file="$STATE_DIR/.approved_edits"
  if [[ -f "$approvals_file" ]]; then
    # Convert each line to JSON string and wrap in array
    echo -n "["
    local first=true
    while IFS= read -r file; do
      [[ -z "$file" ]] && continue
      if [[ "$first" == "true" ]]; then
        echo -n "\"$file\""
        first=false
      else
        echo -n ",\"$file\""
      fi
    done < "$approvals_file"
    echo "]"
  else
    echo "[]"
  fi
}

# Save command context for slash commands
save_command_context() {
  local command="$1"
  local context="$2"
  local timestamp="$(date +%s)"
  
  # Update command history
  echo "$timestamp:$command:$context" >> "$STATE_DIR/.command_history"
  
  # Keep only last 20 commands
  if [[ -f "$STATE_DIR/.command_history" ]]; then
    tail -20 "$STATE_DIR/.command_history" > "$STATE_DIR/.command_history.tmp"
    mv "$STATE_DIR/.command_history.tmp" "$STATE_DIR/.command_history"
  fi
  
  # Update current session context
  if [[ -f "$STATE_DIR/.session_context" ]]; then
    # Update existing context with new command info
    local temp_file="$(mktemp)"
    jq --arg cmd "$command" --arg ctx "$context" --arg ts "$timestamp" '
      .last_command = $cmd |
      .last_context = $ctx |
      .last_command_time = $ts
    ' "$STATE_DIR/.session_context" > "$temp_file" && mv "$temp_file" "$STATE_DIR/.session_context"
  fi
}

# Approve all pending edits (for OPTIMIZE mode)
approve_all_pending_edits() {
  local approvals_file="$STATE_DIR/.approved_edits"
  local count=0
  
  # For now, approve common project files
  # In future, this could read from a pending list
  for file in server.js package.json routes/*.js middleware/*.js; do
    if [[ -f "$PROJECT_DIR/$file" ]]; then
      echo "$PROJECT_DIR/$file" >> "$approvals_file"
      ((count++))
    fi
  done
  
  echo "$count"
}

# Generate STATE.md documentation
generate_state_documentation() {
  local project_name="${1:-Project}"
  local session_id="${2:-unknown}"
  local state_file="$PROJECT_DIR/docs/STATE.md"
  
  # Create docs directory if needed
  mkdir -p "$PROJECT_DIR/docs"
  
  local current_mode="$(get_cohesion_mode)"
  local timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  
  cat > "$state_file" <<EOF
# Project State Documentation
**Last Updated:** $timestamp
**Session ID:** $session_id
**Current Mode:** $current_mode

## 🎯 Project Status

### Current State
- **Mode:** $current_mode
- **Project Directory:** $PROJECT_DIR

### Session History
EOF

  # Add session history if available
  if [[ -d "$STATE_DIR/session_history" ]]; then
    echo "| Session | Mode | Timestamp |" >> "$state_file"
    echo "|---------|------|-----------|" >> "$state_file"
    for session_file in "$STATE_DIR/session_history"/*.json; do
      if [[ -f "$session_file" ]]; then
        local s_id="$(jq -r '.session_id' "$session_file" 2>/dev/null)"
        local s_mode="$(jq -r '.mode' "$session_file" 2>/dev/null)"
        local s_time="$(jq -r '.timestamp' "$session_file" 2>/dev/null)"
        echo "| $s_id | $s_mode | $s_time |" >> "$state_file"
      fi
    done
  fi
  
  echo "" >> "$state_file"
  echo "## 📁 Project Structure" >> "$state_file"
  echo '```' >> "$state_file"
  tree -L 2 "$PROJECT_DIR" 2>/dev/null | head -20 >> "$state_file" || ls -la "$PROJECT_DIR" >> "$state_file"
  echo '```' >> "$state_file"
  
  echo "" >> "$state_file"
  echo "---" >> "$state_file"
  echo "*Generated by Cohesion /save command*" >> "$state_file"
  
  log_message "INFO" "STATE.md generated at $state_file"
}

# ============================================================================
# EXPORTS
# ============================================================================
export -f build_success_response
export -f build_error_response
export -f build_warning_response
export -f build_protection_message
export -f get_cohesion_mode
export -f set_mode
export -f transition_to_mode
export -f get_state_emoji
export -f log_message
export -f is_tool_allowed
export -f is_protected_path
export -f is_dangerous_command
export -f is_safe_bash_command
export -f build_blocked_message
export -f canonicalize_path
export -f approve_edit
export -f is_approved_edit
export -f list_approvals
export -f clear_approvals
export -f save_session_context
export -f restore_session_context
export -f list_approved_files_json
export -f approve_all_pending_edits
export -f generate_state_documentation