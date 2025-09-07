#!/usr/bin/env bash
set -euo pipefail

echo "🏥 COHESION DOCTOR"
echo "=================="
echo "Diagnosing: ${PWD}"
echo "Timestamp: $(date)"

ok(){ printf '✅ OK: %s\n' "$1"; }
warn(){ printf '⚠️  WARN: %s\n' "$1"; }
fail(){ printf '❌ FAIL: %s\n' "$1"; exit 1; }

# jq
command -v jq >/dev/null 2>&1 && ok "jq present" || fail "jq missing (brew install jq | sudo apt-get install jq)"

# global install
COH="${HOME}/.cohesion"
[[ -d "$COH" ]] && ok "~/.cohesion exists" || fail "~/.cohesion not found; run ./install.sh"
[[ -x "$COH/bin/cohesion" ]] && ok "cohesion binary present" || fail "binary missing in ~/.cohesion/bin"

# manifest
[[ -s "$COH/.manifest.json" ]] && ok "manifest present" || fail "manifest missing/empty"

# hooks/utils (global)
[[ -d "$COH/hooks" ]] && ok "global hooks dir" || fail "global hooks dir missing"
[[ -d "$COH/utils" ]] && ok "global utils dir" || fail "global utils dir missing"

# project checks (if .claude exists)
if [[ -d ".claude" ]]; then
  [[ -x ".claude/hooks/pre-tool-use.sh" ]] && ok "project hooks executable" || fail "project hooks missing or non-exec"
  [[ -r ".claude/utils/hook-utils.sh" ]] && ok "project utils readable" || fail "project utils missing"
  # fast state sanity
  if [[ -f ".claude/state/UNLEASHED" ]]; then
    warn "project is in UNLEASH"
  else
    ok "project not forced to UNLEASH"
  fi
else
  warn "project not initialized (.claude missing) — run: cohesion init"
fi

echo "All checks complete."
