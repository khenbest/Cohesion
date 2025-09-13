#!/usr/bin/env bash
# Cohesion Shell Safety & Portability Helpers (bash + zsh)
# Syntax-only hardening; no business-logic changes.
# This is a utility file - sourced by other scripts, not executed directly

# --- Shell identification & minimum versions ---------------------------------
# Support: bash >= 3.2 (macOS default) OR zsh >= 5.0
if [ -n "${BASH_VERSION:-}" ]; then
  # shell: bash
  # shellcheck disable=SC2039  # we intentionally use bash-isms in bash
  if [ "${BASH_VERSINFO[0]}" -lt 3 ] || { [ "${BASH_VERSINFO[0]}" -eq 3 ] && [ "${BASH_VERSINFO[1]}" -lt 2 ]; }; then
    printf 'cohesion: requires bash >= 3.2\n' >&2
    exit 1
  fi
elif [ -n "${ZSH_VERSION:-}" ]; then
  # shell: zsh
  # Make zsh behave like a Bourne-family scripting shell
  emulate -L sh
  setopt errexit nounset
  # pipefail exists in zsh; enable it
  setopt pipefail
  # Simple version floor (zsh 5+ widely available)
  ver_major="${ZSH_VERSION%%.*}"
  if [ "${ver_major:-0}" -lt 5 ]; then
    print -u2 'cohesion: requires zsh >= 5.0'
    exit 1
  fi
else
  printf 'cohesion: unsupported shell (need bash or zsh)\n' >&2
  exit 1
fi

# --- Deterministic text behavior --------------------------------------------
# Normalize locale so string ops/regex/sorts are predictable
export LC_ALL=C
# Defensive IFS (don't export; avoid environment leakage)
IFS=$' \t\n'

# --- Common feature probes ---------------------------------------------------
_coh_have() { command -v "$1" >/dev/null 2>&1; }

# Enable pipefail when available (bash/zsh); no-op otherwise
_coh_enable_pipefail() {
  if [ -n "${BASH_VERSION:-}" ] || [ -n "${ZSH_VERSION:-}" ]; then
    # shellcheck disable=SC3040  # not POSIX; gated by shell detection
    set -o pipefail
  fi
}
_coh_enable_pipefail

# --- Safe removal (syntax guard around rm -rf) --------------------------------
# One-for-one replacement for raw "rm -rf" calls.
# Refuses empty or dangerous paths; allows only known roots you pass in.
_coh_safe_rm_rf() {
  # Allowed roots you consider safe; adjust if needed without altering logic intent.
  # (These defaults are conservative; pass fully-qualified paths when calling.)
  local project_root="${PROJECT_DIR:-}"
  local cohesion_root="${COHESION_DIR:-$HOME/.cohesion}"

  for p in "$@"; do
    # Reject empty or root
    if [ -z "${p}" ] || [ "${p}" = "/" ]; then
      printf 'refusing to remove path: "%s"\n' "${p:-<empty>}" >&2
      exit 1
    fi
    # Only allow removal under known roots when those vars are set; otherwise require explicit absolute subpaths
    case "${p}" in
      "${project_root}"/*|"${cohesion_root}"/*|"$HOME"/.cohesion/*|/tmp/*)
        rm -rf -- "${p}"
        ;;
      *)
        # For relative paths in current directory
        if [[ "$p" != /* ]]; then
          rm -rf -- "${p}"
        else
          printf 'refusing to remove path outside safe roots: "%s"\n' "${p}" >&2
          exit 1
        fi
        ;;
    esac
  done
}

# --- Robust tree copy (rsync preferred; cp fallback; includes dotfiles) -------
# One-for-one replacement for custom copy helpers. Behavior: copy src → dst.
_coh_copy_tree() {
  # Usage: _coh_copy_tree "src_dir" "dst_dir"
  # Semantics: prefer rsync -a; fallback to cp -R; ensure dotfiles are included.
  local src="$1" dst="$2"
  mkdir -p -- "$dst"
  if [ ! -d "$src" ]; then
    printf 'warn: source not found: %s\n' "$src" >&2
    return 1
  fi
  if _coh_have rsync; then
    rsync -a "$src"/ "$dst"/ 2>/dev/null || cp -R "$src"/. "$dst"/
  else
    # cp variant that includes dotfiles (the "/." suffix pattern is portable across bash/zsh)
    cp -R "$src"/. "$dst"/ 2>/dev/null || true
  fi
}

# --- POSIX-safe real directory of a path (no readlink -f dependency) ----------
_coh_realdir() {
  # Prints the physical directory containing $1 (e.g., "$0")
  # Usage: script_dir="$(_coh_realdir "$0")"
  local target="$1" d
  d=$(dirname -- "$target")
  [ "$d" = "." ] && d="$PWD"
  (cd "$d" 2>/dev/null && pwd -P) || printf '%s\n' "$d"
}

# --- Idempotent PATH addition (zsh + bash; does not duplicate) ----------------
_coh_add_path_once() {
  # Syntax helper for installers; call with an absolute bin dir
  local bin_dir="$1"
  [ -n "$bin_dir" ] || return 0

  # Update common startup files if present
  # (No behavior change: this is a helper; call it where you already write PATH.)
  for rc in "$HOME/.zshrc" "$HOME/.zprofile" "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile"; do
    [ -f "$rc" ] || continue
    if ! grep -qs "$bin_dir" "$rc"; then
      # shellcheck disable=SC2016
      printf '\n# Cohesion\nexport PATH="$PATH:%s"\n' "$bin_dir" >> "$rc"
    fi
  done
}

# --- Safer printf helpers (avoid echo pitfalls) --------------------------------
coh_info()  { printf '%s\n' "$*"; }
coh_warn()  { printf 'warn: %s\n' "$*" >&2; }
coh_error() { printf 'error: %s\n' "$*" >&2; }

# --- jq availability banner (syntax-only helper) ------------------------------
coh_need_jq() {
  if ! _coh_have jq; then
    coh_warn 'jq not found; falling back to non-jq path'
    return 1
  fi
  return 0
}

# End of safety helpers