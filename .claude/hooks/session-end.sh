#!/usr/bin/env bash
# Session end: clear ephemeral approvals

set -euo pipefail
UTIL="$(cd "$(dirname "$0")/../utils" && pwd)/hook-utils.sh"
[[ -r "$UTIL" ]] || { printf '%s\n' '{"continue": true}'; exit 0; }
# shellcheck source=/dev/null
. "$UTIL"

clear_approvals
build_success_response
log_message "INFO" "Session end ($(get_cohesion_state))"
