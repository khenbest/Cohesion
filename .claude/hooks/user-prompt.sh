#!/usr/bin/env bash
# Cohesion User Prompt Hook with Approvals support

set -euo pipefail
UTIL="$(cd "$(dirname "$0")/../utils" && pwd)/hook-utils.sh"
[[ -r "$UTIL" ]] || { printf '%s\n' '{"continue": false, "error": "Cohesion misinstalled: missing utils/hook-utils.sh"}'; exit 0; }
# shellcheck source=/dev/null
. "$UTIL"

# Read raw prompt and a lowercased copy
input="$(cat)"
prompt_raw="$(printf '%s' "$input" | jq -r '.prompt // ""')"
prompt_lc="$(printf '%s' "$prompt_raw" | tr '[:upper:]' '[:lower:]')"

# ---- Approvals: "approve edits to <path>" (check before state transitions) --
if [[ "$prompt_lc" =~ approve[[:space:]]+edits[[:space:]]+to[[:space:]]+ ]]; then
  # Extract quoted or unquoted tail after 'approve edits to '
  # Examples handled:
  #   approve edits to "./README.md"
  #   approve edits to ./README.md
  #   approve edits to docs/src
  path_extract="$(printf '%s' "$prompt_raw" | sed -E 's/.*[Aa]pprove[[:space:]]+edits[[:space:]]+to[[:space:]]+["'\'' ]?([^"'\''\n]+)["'\'' ]?.*/\1/')"
  if [[ -n "${path_extract:-}" ]]; then
    approved_abs="$(approve_edit "$path_extract")" || approved_abs="$path_extract"
    build_success_response "Approved for edits:\n - ${approved_abs}"
    log_message "INFO" "Approved edit: $approved_abs"
    exit 0
  fi
fi

# Support: list approvals / clear approvals
if [[ "$prompt_lc" =~ ^(list|show)[[:space:]]+approvals ]]; then
  lines="$(list_approvals || true)"
  msg="No approvals yet"
  [[ -n "${lines:-}" ]] && msg="Current approvals:\n$(printf '%s\n' "$lines" | sed 's/^/ - /')"
  build_success_response "$msg"
  exit 0
fi

if [[ "$prompt_lc" =~ ^(clear|reset)[[:space:]]+approvals ]]; then
  clear_approvals
  build_success_response "Cleared all approvals"
  log_message "INFO" "Approvals cleared"
  exit 0
fi

# ---- State transitions ------------------------------------------------------
if [[ "$prompt_lc" =~ ^(approved|approve|lgtm|yes|go|proceed)($|[[:space:]]) ]]; then
  set_state "UNLEASH"
  
  # Track successful pattern
  echo "$(date '+%Y-%m-%d %H:%M:%S'): Think→Plan→Approve→Build cycle completed" >> "$STATE_DIR/.good_patterns"
  
  # Swap to UNLEASH settings for true autonomy
  if [[ -f "$PROJECT_DIR/.claude/settings.unleash.json" ]]; then
    cp "$PROJECT_DIR/.claude/settings.json" "$PROJECT_DIR/.claude/settings.backup.json" 2>/dev/null || true
    cp "$PROJECT_DIR/.claude/settings.unleash.json" "$PROJECT_DIR/.claude/settings.local.json"
    build_success_response "$UNLEASH_EMOJI UNLEASH ACTIVATED\n✅ Good pattern: Think→Plan→Build\n💡 You've earned autonomy through clear thinking\nBuild freely until you need help\nRun /config reload to apply new permissions"
  else
    build_success_response "$UNLEASH_EMOJI UNLEASH ACTIVATED\n✅ Good pattern: Think→Plan→Build\n💡 You've earned autonomy through clear thinking\nBuild freely until you need help"
  fi
  log_message "INFO" "State: UNLEASH - Good thinking pattern recognized"
  exit 0
elif [[ "$prompt_lc" =~ ^(optimize|discuss|collaborate|help|unclear)($|[[:space:]]) ]]; then
  set_state "OPTIMIZE"
  
  # Swap to OPTIMIZE settings for collaborative mode
  if [[ -f "$PROJECT_DIR/.claude/settings.optimize.json" ]]; then
    cp "$PROJECT_DIR/.claude/settings.json" "$PROJECT_DIR/.claude/settings.backup.json" 2>/dev/null || true
    cp "$PROJECT_DIR/.claude/settings.optimize.json" "$PROJECT_DIR/.claude/settings.local.json"
    build_success_response "$OPTIMIZE_EMOJI OPTIMIZE ACTIVATED\n🤝 Collaboration mode - let's work together\n💡 Perfect for complex problems needing discussion\nApprove specific files as we go\nRun /config reload to apply"
  else
    build_success_response "$OPTIMIZE_EMOJI OPTIMIZE ACTIVATED\n🤝 Collaboration mode - let's work together\n💡 Perfect for complex problems needing discussion"
  fi
  log_message "INFO" "State: OPTIMIZE - Collaborative thinking"
  exit 0
elif [[ "$prompt_lc" =~ ^(reset|discover|restart|stop)($|[[:space:]]) ]]; then
  set_state "DISCOVER"
  build_success_response "$DISCOVER_EMOJI DISCOVER ACTIVATED\n🧠 Thinking mode - understanding before action\n💡 This is where great solutions begin\nTake time to analyze, then present your plan"
  log_message "INFO" "State: DISCOVER - Back to thinking"
  exit 0
fi

# No state change / no approvals – acknowledge
build_success_response
