#!/usr/bin/env bash
# Cohesion Hook Utilities - Optimized + Approvals
# Minimal, fast utilities for hook operations

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

readonly DISCOVER_EMOJI="🔍"
readonly UNLEASH_EMOJI="⚡"
readonly OPTIMIZE_EMOJI="✨"
readonly BLOCKED_EMOJI="⏺"
readonly PROTECTED_EMOJI="🛡️"
readonly WARNING_EMOJI="⚠️"

# Paths relative to .claude
readonly CLAUDE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
readonly HOOKS_DIR="$CLAUDE_DIR/hooks"
readonly STATE_DIR="$CLAUDE_DIR/state"
readonly PROTECTED_CONF="$HOOKS_DIR/protected.conf"
readonly LOG_DIR="$HOOKS_DIR/logs"
readonly APPROVALS_FILE="$STATE_DIR/approvals.txt"
readonly PROJECT_DIR="$(cd "$CLAUDE_DIR/.." && pwd -P)"

mkdir -p "$STATE_DIR" 2>/dev/null || true

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
build_error_response(){ local m; m="$(printf '%s' "$1" | sed 's/"/\\"/g' | tr '\n' '\\n')"; printf '{"continue": false, "error": "%s"}\n' "$m"; }

# ============================================================================
# STATE
# ============================================================================
get_cohesion_state() {
  if [[ -z "${_CACHED_STATE:-}" ]]; then
    if   [[ -f "$STATE_DIR/UNLEASHED" ]]; then _CACHED_STATE="UNLEASH"
    elif [[ -f "$STATE_DIR/OPTIMIZE"  ]]; then _CACHED_STATE="OPTIMIZE"
    else                                       _CACHED_STATE="DISCOVER"
    fi
  fi
  printf '%s\n' "$_CACHED_STATE"
}

set_state() {
  local s="${1:?}"
  mkdir -p "$STATE_DIR" 2>/dev/null || true
  rm -f "$STATE_DIR/UNLEASHED" "$STATE_DIR/OPTIMIZE" 2>/dev/null || true
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
      echo "Mode: DISCOVER - Understanding before action" > "$STATE_DIR/.mode"
      echo "Philosophy: 10 minutes thinking = 1 hour saved" >> "$STATE_DIR/.mode"
      echo "Remember: The best code is written in your mind first" >> "$STATE_DIR/.mode"
      ;; # DISCOVER
  esac
  _CACHED_STATE="" # clear cache
  : > "$STATE_DIR/.last_transition"
  date -u +"%Y-%m-%dT%H:%M:%SZ" >> "$STATE_DIR/.last_transition"
}

get_state_emoji() {
  case "$(get_cohesion_state)" in
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
  local tool="$1" state; state="$(get_cohesion_state)"
  case "$state" in
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
  [[ "$cmd" =~ (rm[[:space:]].*-rf|rm[[:space:]].*-fr|chmod[[:space:]].*777|curl.*\|.*sh|>\ *\/dev\/sd|dd.*if=\/dev\/zero.*of=\/dev) ]]
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
  local tool="$1" state; state="$(get_cohesion_state)"
  local emoji; emoji="$(get_state_emoji)"
  case "$state" in
    OPTIMIZE)
      echo "${BLOCKED_EMOJI} COHESION: $tool blocked in OPTIMIZE state\\n${OPTIMIZE_EMOJI} Collaboration mode active\\n💡 Why blocked: Prevents unwanted changes, ensures quality\\nTo proceed: \\\"approve edits to ./path/file\\\"\\nRemember: 10 min planning = 1 hour saved"
      ;;
    *)
      echo "${BLOCKED_EMOJI} COHESION: $tool blocked in DISCOVER state\\n${DISCOVER_EMOJI} Thinking mode active\\n💡 Why blocked: You're saving future debugging time by thinking first\\nWhat's your understanding of the problem?\\nPresent your plan, then get approval with \\\"approved\\\""
      ;;
  esac
}

# ============================================================================
# EXPORTS
# ============================================================================
export -f build_success_response
export -f build_error_response
export -f get_cohesion_state
export -f set_state
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