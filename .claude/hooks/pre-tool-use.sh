#!/usr/bin/env bash
# Cohesion Pre-Tool-Use Hook — strict gating + per-file approvals
# - Blocks all writes in DISCOVER
# - In OPTIMIZE, writes require explicit per-file approval (is_approved_edit)
# - Dangerous bash blocked always; unsafe bash blocked outside UNLEASH
# - Honors protected.conf for path protection in any state
set -euo pipefail

# --- utils ---------------------------------------------------------------
UTIL="$(cd "$(dirname "$0")/../utils" && pwd)/hook-utils.sh"
if [[ ! -r "$UTIL" ]]; then
  printf '%s\n' '{"continue": false, "error": "Cohesion misinstalled: missing utils/hook-utils.sh"}'
  exit 0
fi
# shellcheck source=/dev/null
. "$UTIL"

# helper: does a shell function exist?
has_func() { declare -F "$1" >/dev/null 2>&1; }

# --- input ---------------------------------------------------------------
input="$(cat)"
tool_name="$(printf '%s' "$input" | jq -r '.tool_name // ""')"
state="$(get_cohesion_state)"
command=""  # will be filled if tool_name == Bash

# --- fast path: no tool name -> allow -----------------------------------
if [[ -z "$tool_name" ]]; then
  build_success_response
  log_message "INFO" "empty tool name allowed ($state)"
  exit 0
fi

# --- writes/edits: protected paths first (any state) ---------------------
if [[ "$tool_name" =~ ^(Write|Edit|MultiEdit|NotebookEdit)$ ]]; then
  file_path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.path // ""')"
  if is_protected_path "$file_path"; then
    build_error_response "${PROTECTED_EMOJI} PROTECTED PATH
Cannot modify: $file_path
To override: edit .claude/protected.conf"
    log_message "WARN" "Protected path blocked: $file_path"
    exit 0
  fi
fi

# --- hard write gate by state -------------------------------------------
if [[ "$tool_name" =~ ^(Write|Edit|MultiEdit|NotebookEdit)$ ]]; then
  case "$state" in
    DISCOVER)
      # Never write in DISCOVER
      build_error_response "$(build_blocked_message "$tool_name")"
      log_message "WARN" "$tool_name blocked (DISCOVER)"
      exit 0
      ;;
    OPTIMIZE)
      # Require explicit per-file approval (function expected in utils)
      file_path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.path // ""')"
      if has_func is_approved_edit; then
        if ! is_approved_edit "$file_path"; then
          build_error_response "${BLOCKED_EMOJI} EDIT NEEDS APPROVAL
Path: $file_path
Action: in chat say -> approve edits to \"$file_path\""
          log_message "WARN" "Edit denied (not approved): $file_path"
          exit 0
        fi
      else
        # Safe default: deny if approvals system is unavailable
        build_error_response "${BLOCKED_EMOJI} EDIT NEEDS APPROVAL
Approval system unavailable (update utils)."
        log_message "WARN" "Edit denied: approvals function missing for $file_path"
        exit 0
      fi
      ;;
    UNLEASH)
      # Even in UNLEASH, we keep minimal safety checks
      # This is belt-and-suspenders given reported Claude bugs
      : # fall through (allowed unless protected above)
      ;;
  esac
fi

# --- bash safety ---------------------------------------------------------
if [[ "$tool_name" == "Bash" ]]; then
  command="$(printf '%s' "$input" | jq -r '.tool_input.command // ""')"

  if [[ "$state" != "UNLEASH" ]]; then
    # In DISCOVER/OPTIMIZE: only allow read-only / obviously safe commands
    if is_dangerous_command "$command" || ! is_safe_bash_command "$command"; then
      build_error_response "$(build_blocked_message "$tool_name")"
      log_message "WARN" "Unsafe bash blocked in $state: $command"
      exit 0
    fi
  else
    # Even in UNLEASH, block clearly dangerous patterns
    if is_dangerous_command "$command"; then
      build_error_response "${WARNING_EMOJI} DANGEROUS COMMAND
Blocked: $command"
      log_message "WARN" "Dangerous bash blocked in UNLEASH: $command"
      exit 0
    fi
  fi
fi

# --- policy gate (final allow/deny by tool list) -------------------------
if has_func is_tool_allowed && ! is_tool_allowed "$tool_name"; then
  build_error_response "$(build_blocked_message "$tool_name")"
  log_message "WARN" "$tool_name blocked by policy in $state"
  exit 0
fi

# --- allow ---------------------------------------------------------------
build_success_response
log_message "INFO" "$tool_name allowed ($state)"
