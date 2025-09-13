#!/usr/bin/env bash
# Cohesion Script Header (standardized)
# Requires: bash >= 3.2 or zsh >= 5 (zsh-compatible via cohesion-utils)
set -euo pipefail

_script_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd -P)"
_utils_candidates=(
  "$_script_dir/../utils/cohesion-utils.sh"
  "$_script_dir/../../utils/cohesion-utils.sh"
  "$HOME/.cohesion/utils/cohesion-utils.sh"
  "$PWD/.claude/utils/cohesion-utils.sh"
)
for _u in "${_utils_candidates[@]}"; do
  # shellcheck disable=SC1090
  if [ -f "$_u" ]; then . "$_u"; _found_utils=1; break; fi
done

# Source documentation utilities if available
if [ -f "$_script_dir/../utils/cohesion-docs.sh" ]; then
  . "$_script_dir/../utils/cohesion-docs.sh"
fi

# Source documentation workflow intelligence
if [ -f "$_script_dir/../utils/cohesion-docs-workflow.sh" ]; then
  . "$_script_dir/../utils/cohesion-docs-workflow.sh"
fi

: "${_found_utils:=0}"
if [ "$_found_utils" -eq 0 ]; then
  printf 'cohesion: missing cohesion-utils.sh\n' >&2; exit 1
fi
unset _script_dir _u _utils_candidates _found_utils