#!/usr/bin/env bash
# Session start: default to DISCOVER unless persistence is enabled

set -euo pipefail
UTIL="$(cd "$(dirname "$0")/../utils" && pwd)/hook-utils.sh"
[[ -r "$UTIL" ]] || { printf '%s\n' '{"continue": false, "error": "Cohesion misinstalled: missing utils/hook-utils.sh"}'; exit 0; }
# shellcheck source=/dev/null
. "$UTIL"

mkdir -p "$STATE_DIR" "$LOG_DIR"
clear_approvals

# Controls (env overrides allowed in ~/.zshrc or ~/.bashrc)
PERSIST="${COHESION_PERSIST_STATE:-0}"          # 1 = keep last state, 0 = reset
DEFAULT_STATE="${COHESION_DEFAULT_STATE:-DISCOVER}"

# If not persisting, force a clean state each session
if [[ "$PERSIST" != "1" ]]; then
  rm -f "$STATE_DIR/UNLEASHED" "$STATE_DIR/OPTIMIZE" 2>/dev/null || true
fi

# If no state files exist, set the default
if [[ ! -f "$STATE_DIR/UNLEASHED" && ! -f "$STATE_DIR/OPTIMIZE" ]]; then
  set_state "$DEFAULT_STATE"
fi

state="$(get_cohesion_state)"
case "$state" in
  UNLEASH)  msg="$UNLEASH_EMOJI UNLEASH (full access)";;
  OPTIMIZE) msg="$OPTIMIZE_EMOJI OPTIMIZE (collaboration)";;
  *)        msg="$DISCOVER_EMOJI DISCOVER (read-only)";;
esac

build_success_response "🚀 COHESION ACTIVE\n\n$msg"
log_message "INFO" "Session start ($state)"
