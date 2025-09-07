#!/usr/bin/env bash
# Cohesion + Claude Code Merge-Aware Installer
# - Global: ~/.cohesion + ~/.claude/settings.json + ~/CLAUDE.md (non-destructive)
# - Project (optional --project): ./.claude/settings.json + ./CLAUDE.md (merge-aware)
# - Prints a diff plan; backups everything it edits
# Dependencies: jq

set -euo pipefail

# ------------------------------- Version --------------------------------------
COHESION_VERSION="2.0.0"

# ------------------------------- Config ---------------------------------------
COHESION_SRC_DIR="${COHESION_SRC_DIR:-$(pwd)}"
COHESION_HOME="${COHESION_HOME:-$HOME/.cohesion}"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
GLOBAL_CLAUDE_MD="${GLOBAL_CLAUDE_MD:-$HOME/CLAUDE.md}"
BIN_DIR="${BIN_DIR:-$HOME/.cohesion/bin}"
MANIFEST_FILE="${COHESION_HOME}/.manifest.json"

# Desired rules for UNLEASH (kept modest; hooks still guard dangerous operations)
DEFAULT_MODE="ask"  # Conservative default; UNLEASH will switch to acceptEdits
ALLOW_RULES=( "Read(./**)" "Glob(./**)" "Grep(./**)" "TodoWrite" "Task" "WebSearch" )
DENY_RULES=( "Read(./.env)" "Read(./.env.*)" "Read(./secrets/**)" "Read(./**/credentials/**)" "Bash(rm -rf /)" "Bash(sudo rm -rf *)" )

# Marker for CLAUDE.md injection
CLAUDE_MD_MARKER="## Cohesion DUO Protocol"
DRY_RUN=0
DO_PROJECT=0

# ------------------------------ Args ------------------------------------------
for arg in "$@"; do
  case "$arg" in
    --dry-run)   DRY_RUN=1 ;;
    --project)   DO_PROJECT=1 ;;
    --help)      
      echo "Usage: ./install.sh [--project] [--dry-run]"
      echo "  --project   Also configure current directory as Cohesion project"
      echo "  --dry-run   Show what would be done without making changes"
      exit 0
      ;;
    *) echo "Unknown arg: $arg"; exit 2 ;;
  esac
done

# ----------------------------- Utilities --------------------------------------
need() { command -v "$1" >/dev/null 2>&1 || { echo "Error: $1 is required. Install it and retry."; exit 1; }; }
ts() { date +"%Y%m%d-%H%M%S"; }
backup() { local f="$1"; [[ -f "$f" ]] && cp -p "$f" "${f}.bak.$(ts)"; }

json_escape() { 
  printf '%s' "$1" | jq -Rs .
}

# jq filter to merge settings
jq_merge_template() {
  local mode="$1"; shift
  local allow_json="$1"; shift
  local deny_json="$1"; shift
  cat <<JQ
def ensure_permissions:
  if has("permissions") and (.permissions|type=="object") then . 
  else . + {permissions:{}} end;

def ensure_default_mode:
  if (.permissions.defaultMode // null) then .
  else .permissions.defaultMode = "$mode" end;

def add_unique(path; items):
  setpath(path; (getpath(path) // []) + items | unique);

. as \$root
| ( \$root // {} )
| ensure_permissions
| ensure_default_mode
| add_unique(["permissions","allow"]; $allow_json)
| add_unique(["permissions","deny"];  $deny_json)
| .customInstructions.globalClaudeMd = "~/CLAUDE.md"
| .customInstructions.autoLoadGlobal = true
| .telemetry.enabled = false
JQ
}

emit_diff() {
  local before="$1" after="$2" label="$3"
  if [[ "$before" != "$after" ]]; then
    echo "Changes for $label:"
    diff -u <(echo "$before" | jq -S .) <(echo "$after" | jq -S .) || true
    echo ""
  fi
}

ensure_dir() { 
  [[ $DRY_RUN -eq 1 ]] && echo "[DRY] mkdir -p $1" || mkdir -p "$1"
}

write_file() {
  local path="$1" content="$2"
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "[DRY] Would write: $path"
    return 0
  fi
  backup "$path"
  printf '%s\n' "$content" > "$path"
}

track_file() {
  local f="$1"
  [[ $DRY_RUN -eq 1 ]] && return 0
  if [[ -f "$MANIFEST_FILE" ]]; then
    local tmp="${MANIFEST_FILE}.tmp"
    jq --arg f "$f" '.global_files += [$f] | .global_files |= unique' "$MANIFEST_FILE" > "$tmp" && mv "$tmp" "$MANIFEST_FILE"
  fi
}

init_manifest() {
  [[ $DRY_RUN -eq 1 ]] && return 0
  [[ -f "$MANIFEST_FILE" ]] && return 0
  ensure_dir "$COHESION_HOME"
  cat > "$MANIFEST_FILE" <<EOF
{
  "version": "$COHESION_VERSION",
  "installed_at": "$(date -u +%FT%TZ)",
  "install_source": "$(pwd)",
  "global_files": [],
  "path_modifications": [],
  "projects": {}
}
EOF
}

rules_to_json() {
  local -a arr=("$@")
  printf '%s\n' "${arr[@]}" | jq -Rs 'split("\n") | map(select(length > 0))'
}

merge_settings() {
  local path="$1" scope="$2"
  local before="{}"
  
  if [[ -f "$path" ]]; then
    before="$(cat "$path" 2>/dev/null || echo "{}")"
  fi

  local allow_json deny_json
  allow_json="$(rules_to_json "${ALLOW_RULES[@]}")"
  deny_json="$(rules_to_json "${DENY_RULES[@]}")"

  local filter
  filter="$(jq_merge_template "$DEFAULT_MODE" "$allow_json" "$deny_json")"

  local after
  if ! after="$(echo "$before" | jq "$filter" 2>/dev/null)"; then
    echo "Warning: Invalid JSON in $path, creating new"
    after="$(echo "{}" | jq "$filter")"
  fi

  if [[ "$before" != "$after" ]]; then
    emit_diff "$before" "$after" "$scope"
    write_file "$path" "$after"
    track_file "$path"
    echo "✓ Updated $scope settings"
  else
    echo "✓ $scope settings already up to date"
  fi
}

install_cohesion() {
  echo ""
  echo "Installing Cohesion core..."
  ensure_dir "$COHESION_HOME"
  ensure_dir "$BIN_DIR"
  init_manifest
  
  # Install cohesion CLI
  if [[ -f "./cohesion" ]]; then
    if [[ $DRY_RUN -eq 0 ]]; then
      install -m 755 ./cohesion "$BIN_DIR/cohesion"
      track_file "$BIN_DIR/cohesion"
    fi
    echo "  ✓ Installed cohesion CLI"
  fi
  
  # Install scripts
  if [[ -d "./scripts" ]]; then
    ensure_dir "$COHESION_HOME/scripts"
    if [[ $DRY_RUN -eq 0 ]]; then
      for script in ./scripts/*.sh; do
        [[ -f "$script" ]] || continue
        install -m 755 "$script" "$COHESION_HOME/scripts/$(basename "$script")"
        track_file "$COHESION_HOME/scripts/$(basename "$script")"
      done
      
      # Special case: uninstall script needs to be in bin for cohesion CLI
      if [[ -f "./scripts/uninstall-global.sh" ]]; then
        install -m 755 "./scripts/uninstall-global.sh" "$BIN_DIR/cohesion-uninstall-global.sh"
        track_file "$BIN_DIR/cohesion-uninstall-global.sh"
      fi
      
      # Also install doctor to bin
      if [[ -f "./scripts/doctor.sh" ]]; then
        install -m 755 "./scripts/doctor.sh" "$BIN_DIR/cohesion-doctor.sh"
        track_file "$BIN_DIR/cohesion-doctor.sh"
      fi
    fi
    echo "  ✓ Installed scripts"
  fi
  
  # Copy templates
  if [[ -d "./templates" ]]; then
    ensure_dir "$COHESION_HOME/templates"
    [[ $DRY_RUN -eq 1 ]] || rsync -a ./templates/ "$COHESION_HOME/templates/"
    echo "  ✓ Copied templates"
  fi
  
  # Copy hooks/utils
  if [[ -d "./.claude" ]]; then
    ensure_dir "$COHESION_HOME/hooks"
    ensure_dir "$COHESION_HOME/utils"
    if [[ $DRY_RUN -eq 0 ]]; then
      rsync -a ./.claude/hooks/ "$COHESION_HOME/hooks/" 2>/dev/null || true
      rsync -a ./.claude/utils/ "$COHESION_HOME/utils/" 2>/dev/null || true
    fi
    echo "  ✓ Copied hooks and utils"
  fi
  
  # Add to PATH
  for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
    if [[ -f "$rc" ]] && ! grep -q "$BIN_DIR" "$rc"; then
      if [[ $DRY_RUN -eq 0 ]]; then
        backup "$rc"
        echo "" >> "$rc"
        echo "# Cohesion" >> "$rc"
        echo "export PATH=\"\$PATH:$BIN_DIR\"" >> "$rc"
        
        # Track the modification
        if [[ -f "$MANIFEST_FILE" ]]; then
          local tmp="${MANIFEST_FILE}.tmp"
          jq --arg file "$rc" --arg line "export PATH=\"\$PATH:$BIN_DIR\"" \
            '.path_modifications += [{"file":$file,"line":$line}]' \
            "$MANIFEST_FILE" > "$tmp" && mv "$tmp" "$MANIFEST_FILE"
        fi
      fi
      echo "  ✓ Added to PATH in $rc"
    fi
  done
}

install_global_claude() {
  echo ""
  echo "Configuring global Claude integration..."
  ensure_dir "$CLAUDE_HOME"
  
  # Merge settings
  merge_settings "$CLAUDE_HOME/settings.json" "global"
  
  # Create/update CLAUDE.md
  if [[ ! -f "$GLOBAL_CLAUDE_MD" ]] || ! grep -q "$CLAUDE_MD_MARKER" "$GLOBAL_CLAUDE_MD" 2>/dev/null; then
    if [[ $DRY_RUN -eq 0 ]]; then
      backup "$GLOBAL_CLAUDE_MD"
      cat >> "$GLOBAL_CLAUDE_MD" << 'MD'

## Cohesion DUO Protocol

When a project has `.claude/hooks/`, follow the DUO protocol:

1. Check `.claude/state/` for current mode:
   - `UNLEASHED` → Full autonomy (acceptEdits mode)
   - `OPTIMIZE` → Collaborative (require approvals)
   - Otherwise → DISCOVER (read-only)

2. State commands:
   - "approved", "lgtm", "go" → UNLEASH
   - "optimize", "discuss" → OPTIMIZE
   - "reset", "discover" → DISCOVER

3. Verify with:
   - `/permissions` - Show active permissions
   - `/config reload` - Reload after state change
MD
      track_file "$GLOBAL_CLAUDE_MD"
    fi
    echo "  ✓ Updated global CLAUDE.md"
  else
    echo "  ✓ Global CLAUDE.md already configured"
  fi
}

install_project() {
  echo ""
  echo "Configuring project..."
  
  # Run cohesion init
  if [[ $DRY_RUN -eq 0 ]]; then
    if command -v cohesion >/dev/null 2>&1; then
      cohesion init
    else
      # Manual setup if cohesion not in PATH yet
      ensure_dir "./.claude"
      rsync -a "$COHESION_HOME/hooks/" "./.claude/hooks/" 2>/dev/null || true
      rsync -a "$COHESION_HOME/utils/" "./.claude/utils/" 2>/dev/null || true
      echo "  ✓ Manually copied hooks and utils"
    fi
  fi
  
  # Merge project settings
  ensure_dir "./.claude"
  merge_settings "./.claude/settings.json" "project"
  
  # Create project CLAUDE.md if missing
  if [[ ! -f "./CLAUDE.md" ]]; then
    if [[ $DRY_RUN -eq 0 ]]; then
      cat > "./CLAUDE.md" << 'MD'
# Project Configuration

This project uses Cohesion DUO Protocol.

## Current State
Check `.claude/state/` directory for active mode.

## Commands
- `approved` → UNLEASH mode (full autonomy)
- `optimize` → OPTIMIZE mode (collaborative)
- `reset` → DISCOVER mode (read-only)

## Verification
Run `/permissions` in Claude Code to verify settings.
MD
    fi
    echo "  ✓ Created project CLAUDE.md"
  fi
  
  # Update manifest with project
  if [[ $DRY_RUN -eq 0 ]] && [[ -f "$MANIFEST_FILE" ]]; then
    local tmp="${MANIFEST_FILE}.tmp"
    jq --arg proj "$(pwd)" --arg time "$(date -u +%FT%TZ)" \
      '.projects[$proj] = {"installed_at": $time}' \
      "$MANIFEST_FILE" > "$tmp" && mv "$tmp" "$MANIFEST_FILE"
  fi
}

# ----------------------------- Main -------------------------------------------
need jq

echo "╔══════════════════════════════════════════════════════════╗"
echo "║        Cohesion + Claude Code Installer v$COHESION_VERSION            ║"
echo "╚══════════════════════════════════════════════════════════╝"

install_cohesion
install_global_claude

if [[ $DO_PROJECT -eq 1 ]]; then
  install_project
fi

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║                    Installation Complete                  ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
echo "Next steps:"
echo "  1. Restart shell or run: source ~/.zshrc"
echo "  2. Initialize a project: cd <project> && cohesion init"
echo "  3. Start Claude Code and run: /permissions"
echo "  4. Control state with: approved, optimize, reset"
echo ""
echo "Documentation: https://github.com/khenbest/Cohesion"