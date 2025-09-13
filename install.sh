#!/usr/bin/env bash
# Cohesion Script Header (standardized)
# Requires: bash >= 3.2, jq - Standalone installer (no cohesion-utils)
set -euo pipefail

# Get the directory where install.sh is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd -P)"

# Critical operations that should NEVER be allowed
DENY_RULES=( 
  "Bash(rm -rf /)" 
  "Bash(sudo rm -rf *)"
  "Bash(:(){ :|:& };:)"  # Fork bomb protection
)
# Minimal allow for fallback if hooks fail
ALLOW_RULES=( "Read" )  # Ensures Claude can at least read if hooks fail
DEFAULT_MODE="read-write"  # Default permission mode

# Version
COHESION_VERSION="1.0.0"

# Installation paths
COHESION_HOME="${COHESION_HOME:-$HOME/.cohesion}"
BIN_DIR="${BIN_DIR:-$COHESION_HOME/bin}"
MANIFEST_FILE="${MANIFEST_FILE:-$COHESION_HOME/.manifest.json}"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/Library/Application Support/Claude}"
GLOBAL_CLAUDE_MD="${GLOBAL_CLAUDE_MD:-$CLAUDE_HOME/CLAUDE.md}"

# Marker for CLAUDE.md injection
CLAUDE_MD_MARKER="## Cohesion DUO Protocol"
DRY_RUN=0
DO_PROJECT=0
NON_INTERACTIVE="${NON_INTERACTIVE:-0}"

# ------------------------------ Args ------------------------------------------
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --project) DO_PROJECT=1 ;;
    --non-interactive) NON_INTERACTIVE=1; export NON_INTERACTIVE ;;
    --help)      
      echo "Usage: ./install.sh [--project] [--dry-run] [--non-interactive]"
      echo "  --project   Also configure current directory as Cohesion project"
      echo "  --dry-run   Show what would be done without making changes"
      echo "  --non-interactive   Skip all prompts (for CI/automation)"
      exit 0
      ;;
    *) echo "Unknown arg: $arg"; exit 2 ;;
  esac
done

# ----------------------------- Utilities --------------------------------------
need() { command -v "$1" >/dev/null 2>&1 || { echo "Error: $1 is required. Install it and retry."; exit 1; }; }
ts() { date +"%Y%m%d-%H%M%S"; }
backup() { local f="$1"; [[ -f "$f" ]] && cp -p "$f" "${f}.bak.$(ts)" || true; }

# jq filter to merge settings - simplified for new permission model
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

def set_if_not_empty(path; items):
  if (items | length) > 0 then setpath(path; items) else . end;

. as \$root
| ( \$root // {} )
| ensure_permissions
| ensure_default_mode
| set_if_not_empty(["permissions","allow"]; $allow_json)
| set_if_not_empty(["permissions","deny"];  $deny_json)
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
  if [[ $DRY_RUN -eq 1 ]]; then 
    echo "[DRY] mkdir -p $1"
  else 
    mkdir -p "$1"
  fi
}

write_file() {
  local path="$1" content="$2"
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "[DRY] Would write: $path"
    return 0
  fi
  backup "$path"
  # Ensure parent directory exists
  mkdir -p "$(dirname "$path")"
  printf '%s\n' "$content" > "$path"
}

track_file() {
  local f="$1"
  [[ $DRY_RUN -eq 1 ]] && return 0
  if [[ -f "$MANIFEST_FILE" ]] && command -v jq >/dev/null 2>&1; then
    local tmp="${MANIFEST_FILE}.tmp"
    jq --arg f "$f" '.global_files += [$f] | .global_files |= unique' "$MANIFEST_FILE" > "$tmp" && mv "$tmp" "$MANIFEST_FILE" 2>/dev/null || true
  fi
  return 0
}

init_manifest() {
  [[ $DRY_RUN -eq 1 ]] && return 0
  [[ -f "$MANIFEST_FILE" ]] && return 0
  ensure_dir "$COHESION_HOME"
  # Create manifest without requiring jq
  cat > "$MANIFEST_FILE" <<EOF
{
  "version": "$COHESION_VERSION",
  "installed_at": "$(date -u +%FT%TZ 2>/dev/null || date)",
  "install_source": "$SCRIPT_DIR",
  "global_files": [],
  "path_modifications": [],
  "projects": {}
}
EOF
  return 0
}

rules_to_json() {
  local -a arr=("$@")
  printf '%s\n' "${arr[@]}" | jq -Rs 'split("\n") | map(select(length > 0))'
}

merge_settings() {
  local path="$1" scope="$2"
  local before="{}"
  
  # Ensure directory exists
  mkdir -p "$(dirname "$path")"
  
  if [[ -f "$path" ]]; then
    before="$(cat "$path" 2>/dev/null || echo "{}")"
  else
    # Create empty JSON file if it doesn't exist
    echo '{}' > "$path"
  fi

  local allow_json deny_json
  if [[ ${#ALLOW_RULES[@]} -gt 0 ]]; then
    allow_json="$(rules_to_json "${ALLOW_RULES[@]:-}")"
  else
    allow_json="[]"
  fi
  if [[ ${#DENY_RULES[@]} -gt 0 ]]; then
    deny_json="$(rules_to_json "${DENY_RULES[@]:-}")"
  else
    deny_json="[]"
  fi

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
  
  # Ensure function returns success
  return 0
}

install_cohesion() {
  echo ""
  echo "Installing Cohesion core..."
  ensure_dir "$COHESION_HOME"
  ensure_dir "$BIN_DIR"
  init_manifest || true  # Don't fail if manifest already exists
  
  # Install cohesion CLI
  if [[ -f "$SCRIPT_DIR/cohesion" ]]; then
    if [[ $DRY_RUN -eq 0 ]]; then
      # Use cp instead of install for better cross-platform compatibility
      cp "$SCRIPT_DIR/cohesion" "$BIN_DIR/cohesion"
      chmod 755 "$BIN_DIR/cohesion"
      track_file "$BIN_DIR/cohesion"
    fi
    echo "  ✓ Installed cohesion CLI"
  fi
  
  # Install scripts
  if [[ -d "$SCRIPT_DIR/scripts" ]]; then
    ensure_dir "$COHESION_HOME/scripts"
    if [[ $DRY_RUN -eq 0 ]]; then
      for script in "$SCRIPT_DIR"/scripts/*.sh; do
        [[ -f "$script" ]] || continue
        cp "$script" "$COHESION_HOME/scripts/$(basename "$script")"
        chmod 755 "$COHESION_HOME/scripts/$(basename "$script")"
        track_file "$COHESION_HOME/scripts/$(basename "$script")"
      done
      
      # Special case: uninstall script needs to be in bin for cohesion CLI
      if [[ -f "$SCRIPT_DIR/scripts/cohesion-uninstall-global.sh" ]]; then
        cp "$SCRIPT_DIR/scripts/cohesion-uninstall-global.sh" "$BIN_DIR/cohesion-uninstall-global.sh"
        chmod 755 "$BIN_DIR/cohesion-uninstall-global.sh"
        track_file "$BIN_DIR/cohesion-uninstall-global.sh"
      fi
      
      # Install doctor script to bin
      if [[ -f "$SCRIPT_DIR/scripts/cohesion-doctor.sh" ]]; then
        cp "$SCRIPT_DIR/scripts/cohesion-doctor.sh" "$BIN_DIR/cohesion-doctor.sh"
        chmod 755 "$BIN_DIR/cohesion-doctor.sh"
        track_file "$BIN_DIR/cohesion-doctor.sh"
        echo "  ✓ Doctor script installed (auto-repair enabled)"
      fi
    fi
    echo "  ✓ Installed scripts"
  fi
  
  # Copy templates
  if [[ -d "$SCRIPT_DIR/templates" ]]; then
    ensure_dir "$COHESION_HOME/templates"
    if [[ $DRY_RUN -eq 0 ]]; then
      # Use rsync if available for proper copying, otherwise use find+cp
      if command -v rsync >/dev/null 2>&1; then
        rsync -a "$SCRIPT_DIR/templates/" "$COHESION_HOME/templates/" --exclude='.DS_Store'
      else
        # Copy all files and directories from templates, excluding . and ..
        find "$SCRIPT_DIR/templates" -mindepth 1 -maxdepth 1 -exec cp -r {} "$COHESION_HOME/templates/" \;
      fi
    fi
    echo "  ✓ Copied templates"
  fi
  
  # Copy hooks/utils
  if [[ -d "$SCRIPT_DIR/templates/.claude" ]]; then
    ensure_dir "$COHESION_HOME/hooks"
    ensure_dir "$COHESION_HOME/utils"
    if [[ $DRY_RUN -eq 0 ]]; then
      # Use cp instead of rsync for better compatibility
      # Copy from templates directory (has all files)
      INSTALL_WARNINGS=0
      if [[ -d "$SCRIPT_DIR/templates/.claude/hooks" ]]; then
        mkdir -p "$COHESION_HOME/hooks/"
        if ! cp -r "$SCRIPT_DIR"/templates/.claude/hooks/* "$COHESION_HOME/hooks/" 2>/dev/null; then
          echo "⚠️  WARNING: Failed to copy hooks from $SCRIPT_DIR/templates/.claude/hooks/"
          echo "   Projects may not have full functionality"
          echo "   Recovery: Run 'cohesion doctor' after installation"
          ((INSTALL_WARNINGS++))
        else
          # Set execute permissions on all hooks
          chmod 755 "$COHESION_HOME/hooks/"*.sh 2>/dev/null || true
        fi
      fi
      if [[ -d "$SCRIPT_DIR/templates/.claude/utils" ]]; then
        mkdir -p "$COHESION_HOME/utils/"
        if ! cp -r "$SCRIPT_DIR"/templates/.claude/utils/* "$COHESION_HOME/utils/" 2>/dev/null; then
          echo "⚠️  WARNING: Failed to copy utils from $SCRIPT_DIR/templates/.claude/utils/"
          echo "   Core functionality may be limited"
          echo "   Recovery: Run 'cohesion doctor' after installation"
          ((INSTALL_WARNINGS++))
        else
          # Set execute permissions on all utils
          chmod 755 "$COHESION_HOME/utils/"*.sh 2>/dev/null || true
        fi
      fi
    fi
    echo "  ✓ Copied hooks and utils"
  fi
  
  # Add to PATH - handle multiple shell configurations
  local shells_configured=0
  
  # Check for shell config files in order of preference
  local shell_configs=()
  [[ -f "$HOME/.zshrc" ]] && shell_configs+=("$HOME/.zshrc")
  [[ -f "$HOME/.bashrc" ]] && shell_configs+=("$HOME/.bashrc")
  [[ -f "$HOME/.bash_profile" ]] && shell_configs+=("$HOME/.bash_profile")
  [[ -f "$HOME/.profile" ]] && shell_configs+=("$HOME/.profile")
  
  # Handle WSL/Windows
  if [[ "$(uname -r)" =~ Microsoft|WSL ]]; then
    # On WSL, prefer .bashrc
    [[ -f "$HOME/.bashrc" ]] || touch "$HOME/.bashrc"
  fi
  
  if [[ ${#shell_configs[@]} -gt 0 ]]; then
    for rc in "${shell_configs[@]:-}"; do
      if [[ -f "$rc" ]] && ! grep -q "$BIN_DIR" "$rc"; then
        if [[ $DRY_RUN -eq 0 ]]; then
          backup "$rc"
          {
            echo ""
            echo "# Cohesion"
            echo "export COHESION_HOME=\"\${COHESION_HOME:-$COHESION_HOME}\""
            echo "export PATH=\"\$PATH:$BIN_DIR\""
          } >> "$rc"
          
          # Track the modification
          if [[ -f "$MANIFEST_FILE" ]]; then
            local tmp="${MANIFEST_FILE}.tmp"
            jq --arg file "$rc" --arg line "export PATH=\"\$PATH:$BIN_DIR\"" \
              '.path_modifications += [{"file":$file,"line":$line}]' \
              "$MANIFEST_FILE" > "$tmp" && mv "$tmp" "$MANIFEST_FILE"
          fi
          echo "  ✓ Added to PATH in $rc"
        else
          echo "  [DRY] Would add to PATH in $rc"
        fi
        shells_configured=$((shells_configured + 1))
      elif grep -q "$BIN_DIR" "$rc"; then
        echo "  ✓ PATH already configured in $rc"
        shells_configured=$((shells_configured + 1))
      fi
    done
  fi
  
  if [[ $shells_configured -eq 0 ]]; then
    echo "  ⚠️  No shell configuration files found. Creating .bashrc"
    if [[ $DRY_RUN -eq 0 ]]; then
      {
        echo "# Cohesion"
        echo "export COHESION_HOME=\"\${COHESION_HOME:-$COHESION_HOME}\""
        echo "export PATH=\"\$PATH:$BIN_DIR\""
      } >> "$HOME/.bashrc"
      echo "  ✓ Created .bashrc with PATH"
    else
      echo "  [DRY] Would create .bashrc with PATH"
    fi
  fi
  
  # Ensure function returns success
  return 0
}

install_global_claude() {
  echo ""
  echo "Configuring global Claude integration..."
  ensure_dir "$CLAUDE_HOME"
  
  # Merge settings
  merge_settings "$CLAUDE_HOME/settings.json" "global"
  
  # Create/update CLAUDE.md - use explicit test to avoid grep exit code issues
  local needs_update=0
  if [[ ! -f "$GLOBAL_CLAUDE_MD" ]]; then
    needs_update=1
  elif ! grep -q "$CLAUDE_MD_MARKER" "$GLOBAL_CLAUDE_MD" 2>/dev/null; then
    needs_update=1
  fi
  
  if [[ $needs_update -eq 1 ]]; then
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
  
  # Ensure function returns success
  return 0
}

# Template processing function
process_project_templates() {
  local project_name="$1"
  local daily_start_time="$2"
  local daily_end_time="$3"
  local work_block_duration="$4"
  local status_check_command="$5"
  local test_command="$6"
  local lint_command="$7"
  local weekly_review_day="$8"
  local current_timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  
  echo "  🔧 Processing project templates..."
  
  # Template substitution mappings
  local -A template_vars=(
    ["{{PROJECT_NAME}}"]="$project_name"
    ["{{DAILY_START_TIME}}"]="$daily_start_time"
    ["{{DAILY_END_TIME}}"]="$daily_end_time"
    ["{{STARTUP_DURATION}}"]="15 minutes"
    ["{{WRAPUP_DURATION}}"]="15 minutes"
    ["{{WORK_BLOCK_DURATION}}"]="$work_block_duration"
    ["{{STATUS_CHECK_COMMAND}}"]="$status_check_command"
    ["{{ENV_CHECK_COMMAND}}"]="echo \"Environment OK\""
    ["{{TEST_COMMAND}}"]="$test_command"
    ["{{LINT_COMMAND}}"]="$lint_command"
    ["{{WEEKLY_REVIEW_DAY}}"]="$weekly_review_day"
    ["{{LAST_UPDATED}}"]="$current_timestamp"
    ["{{REVIEW_FREQUENCY}}"]="Weekly"
    ["{{SESSION_ID}}"]="[Auto-generated]"
    ["{{SESSION_START_TIME}}"]="[Auto-generated]"
    ["{{CURRENT_MODE}}"]="[Auto-managed]"
    ["{{LAST_COMMAND}}"]="[Auto-managed]"
    ["{{CURRENT_FOCUS}}"]="[Set by commands with arguments]"
    ["{{APPROVED_FILES_LIST}}"]="[Auto-managed]"
    ["{{RECENT_COMMANDS}}"]="[Auto-managed]"
    ["{{MODE_TRANSITIONS}}"]="[Auto-managed]"
    ["{{CURRENT_TASK}}"]="[Set manually or auto-detected]"
    ["{{TASK_STATUS}}"]="[Set manually]"
    ["{{CURRENT_BLOCKERS}}"]="[Set manually]"
    ["{{COMPLETED_TASKS}}"]="[Updated daily]"
    ["{{PENDING_TASKS}}"]="[Updated daily]"
    ["{{THINK_FIRST_LOG}}"]="[Auto-populated by hooks]"
    ["{{REALITY_CHECK_LOG}}"]="[Auto-populated by hooks]"
    ["{{ALWAYS_WORKS_LOG}}"]="[Auto-populated by hooks]"
    ["{{KEY_DECISIONS}}"]="[Updated as needed]"
    ["{{LESSONS_LEARNED}}"]="[Updated as needed]"
    ["{{LAST_UPDATE_TIME}}"]="[Auto-managed by hooks]"
  )
  
  # Process template files in key locations
  local template_files=(
    "./docs/WORKFLOW.md"
    "./docs/STATE.md"
    "./CLAUDE.md"
  )
  
  for file in "${template_files[@]}"; do
    if [[ -f "$file" ]]; then
      local temp_file="${file}.tmp"
      cp "$file" "$temp_file"
      
      # Apply all template substitutions
      for placeholder in "${!template_vars[@]}"; do
        local value="${template_vars[$placeholder]}"
        # Escape special characters for sed
        value=$(printf '%s\n' "$value" | sed 's/[[\.*^$()+?{|]/\\&/g')
        placeholder_escaped=$(printf '%s\n' "$placeholder" | sed 's/[[\.*^$()+?{|]/\\&/g')
        sed "s/$placeholder_escaped/$value/g" "$temp_file" > "${temp_file}.2"
        mv "${temp_file}.2" "$temp_file"
      done
      
      mv "$temp_file" "$file"
      echo "    ✓ Processed $file"
    fi
  done
  
  # Clean up .DS_Store files
  find . -name ".DS_Store" -type f -delete 2>/dev/null || true
  
  # Copy gitignore if needed
  if [[ -f "./.claude/.gitignore.cohesion" ]] && [[ ! -f "./.gitignore" ]]; then
    cp "./.claude/.gitignore.cohesion" "./.gitignore"
    echo "    ✓ Created .gitignore from template"
  elif [[ -f "./.claude/.gitignore.cohesion" ]]; then
    echo "    💡 Consider merging .claude/.gitignore.cohesion into your .gitignore"
  fi
}

install_project() {
  echo ""
  echo "Configuring project..."
  
  # Collect project configuration for template processing
  local project_config_file="./.claude/project-config.json"
  if [[ $NON_INTERACTIVE -eq 0 ]]; then
    echo ""
    echo "🔧 Project Template Configuration"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    read -p "Project name: " project_name
    project_name="${project_name:-$(basename "$(pwd)")}"
    
    read -p "Daily start time (default: 09:00): " daily_start_time
    daily_start_time="${daily_start_time:-09:00}"
    
    read -p "Daily end time (default: 17:00): " daily_end_time
    daily_end_time="${daily_end_time:-17:00}"
    
    read -p "Work block duration (default: 90 minutes): " work_block_duration
    work_block_duration="${work_block_duration:-90 minutes}"
    
    read -p "Status check command (default: npm run lint): " status_check_command
    status_check_command="${status_check_command:-npm run lint}"
    
    read -p "Test command (default: npm test): " test_command
    test_command="${test_command:-npm test}"
    
    read -p "Lint command (default: npm run lint): " lint_command
    lint_command="${lint_command:-npm run lint}"
    
    read -p "Weekly review day (default: Friday): " weekly_review_day
    weekly_review_day="${weekly_review_day:-Friday}"
    
    echo ""
  else
    # Non-interactive defaults
    project_name="$(basename "$(pwd)")"
    daily_start_time="09:00"
    daily_end_time="17:00"
    work_block_duration="90 minutes"
    status_check_command="npm run lint"
    test_command="npm test"
    lint_command="npm run lint"
    weekly_review_day="Friday"
  fi
  
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
    
    # Store project configuration (removed unused cohesion directory)
    cat > "$project_config_file" << EOF
{
  "project_name": "$project_name",
  "daily_start_time": "$daily_start_time",
  "daily_end_time": "$daily_end_time",
  "work_block_duration": "$work_block_duration",
  "status_check_command": "$status_check_command",
  "test_command": "$test_command",
  "lint_command": "$lint_command",
  "weekly_review_day": "$weekly_review_day",
  "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "cohesion_version": "$COHESION_VERSION"
}
EOF
    
    # Process template files
    process_project_templates "$project_name" "$daily_start_time" "$daily_end_time" "$work_block_duration" "$status_check_command" "$test_command" "$lint_command" "$weekly_review_day"
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
Your Cohesion setup is complete and ready to use.
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

# Verify installation completeness
verify_installation() {
  local errors=0
  echo ""
  echo "Verifying installation..."
  
  # Check all utils are installed
  local required_utils=(
    "cohesion-utils.sh"
    "cohesion-docs.sh"
    "cohesion-docs-workflow.sh"
    "cohesion-shell-safety.sh"
    "script-header.sh"
  )
  
  for util in "${required_utils[@]}"; do
    if [[ ! -f "$COHESION_HOME/utils/$util" ]]; then
      echo "  ✗ Missing: utils/$util"
      ((errors++))
    fi
  done
  
  # Check the single required hook is installed
  local required_hooks=(
    "pre-tool-use.sh"
  )
  
  for hook in "${required_hooks[@]}"; do
    if [[ ! -f "$COHESION_HOME/hooks/$hook" ]]; then
      echo "  ✗ Missing: hooks/$hook"
      ((errors++))
    fi
  done
  
  # Check CLI
  if [[ ! -x "$COHESION_HOME/bin/cohesion" ]]; then
    echo "  ✗ CLI not executable"
    ((errors++))
  fi
  
  if [[ $errors -gt 0 ]]; then
    echo ""
    echo "  ⚠️  Installation incomplete - found $errors issues"
    echo "  💡 Run 'cohesion doctor' to verify and auto-fix any issues"
    return 1
  else
    echo "  ✓ All components verified"
    return 0
  fi
}

verify_installation

echo ""
if [[ "${INSTALL_WARNINGS:-0}" -gt 0 ]]; then
  echo "╔══════════════════════════════════════════════════════════╗"
  echo "║              Installation Complete with Warnings ⚠️        ║"
  echo "╚══════════════════════════════════════════════════════════╝"
  echo ""
  echo "⚠️  $INSTALL_WARNINGS warning(s) occurred during installation"
  echo "   The system is functional but some features may be limited"
  echo "   Run 'cohesion doctor' to diagnose and auto-repair issues"
else
  echo "╔══════════════════════════════════════════════════════════╗"
  echo "║                    Installation Complete! 🎉              ║"
  echo "╚══════════════════════════════════════════════════════════╝"
fi

# Check if this is a first-time install (no previous state)
if [[ ! -d "$HOME/.cohesion/state" ]] && [[ $DRY_RUN -eq 0 ]]; then
  if [[ "$NON_INTERACTIVE" -eq 0 ]]; then
    echo ""
    echo "📚 Starting interactive tutorial..."
    echo ""
    sleep 1
    # Run the learn command if it exists
    if [[ -x "$HOME/.cohesion/scripts/cohesion-learn.sh" ]]; then
      "$HOME/.cohesion/scripts/cohesion-learn.sh" --first-run
    elif [[ -x "$COHESION_HOME/scripts/cohesion-learn.sh" ]]; then
      "$COHESION_HOME/scripts/cohesion-learn.sh" --first-run
    else
      echo "💡 Run 'cohesion learn' anytime to explore the Core Principles"
    fi
  else
    echo ""
    echo "📚 Skipping interactive tutorial (non-interactive mode)"
    echo "Run 'cohesion learn' anytime to explore the Core Principles"
  fi
fi

# Prompt to run protect wizard if not already configured
if [[ ! -f "$HOME/.cohesion/protected.conf" ]] && [[ $DRY_RUN -eq 0 ]]; then
  if [[ "$NON_INTERACTIVE" -eq 0 ]]; then
    echo ""
    echo "🛡️  Would you like to configure protected paths?"
    echo "This wizard helps you specify files that Claude Code should never modify."
    echo ""
    read -p "Run the protect wizard now? [Y/n] " -r
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
      echo ""
      echo "Starting protect wizard..."
      echo "(Note: If cohesion is not in PATH yet, restart your shell first)"
      echo ""
      if command -v cohesion >/dev/null 2>&1; then
        cohesion protect --wizard
      else
        echo "Please run after restarting shell: cohesion protect --wizard"
      fi
    else
      echo ""
      echo "You can run the wizard later with: cohesion protect --wizard"
    fi
  else
    echo ""
    echo "🛡️  Skipping protect wizard (non-interactive mode)"
    echo "Run 'cohesion protect --wizard' later to configure protected paths"
  fi
fi

echo ""
echo "Next steps:"

# Detect which shell config was updated for better instructions
if [[ -f "$HOME/.zshrc" ]] && grep -q "$BIN_DIR" "$HOME/.zshrc"; then
  echo "  1. Restart shell or run: source ~/.zshrc"
elif [[ -f "$HOME/.bashrc" ]] && grep -q "$BIN_DIR" "$HOME/.bashrc"; then
  echo "  1. Restart shell or run: source ~/.bashrc"
elif [[ -f "$HOME/.bash_profile" ]] && grep -q "$BIN_DIR" "$HOME/.bash_profile"; then
  echo "  1. Restart shell or run: source ~/.bash_profile"
else
  echo "  1. Restart your shell to load PATH changes"
fi
if [[ ! -f "$HOME/.cohesion/protected.conf" ]]; then
  echo "  2. Configure protections: cohesion protect --wizard"
  echo "  3. Initialize a project: cd <project> && cohesion init"
  echo "  4. Control state with: approved, optimize, reset"
else
  echo "  2. Initialize a project: cd <project> && cohesion init"
  echo "  3. Control state with: approved, optimize, reset"
fi
echo ""
echo "Documentation: https://github.com/khenbest/Cohesion"

# Post-install smoke test
if [[ $DRY_RUN -eq 0 ]]; then
  if [[ -x "$BIN_DIR/cohesion" ]]; then
    if "$BIN_DIR/cohesion" help 2>/dev/null | grep -q "Cohesion"; then
      echo ""
      echo "✅ Installation verified successfully!"
      echo ""
      echo "🔄 IMPORTANT: If you have Claude Code open, run '/config reload' to activate hooks"
    else
      echo ""
      echo "⚠️  Installation complete but cohesion command may need shell reload"
      echo "Run: exec \$SHELL or open a new terminal"
      echo ""
      echo "🔄 IMPORTANT: If you have Claude Code open, run '/config reload' to activate hooks"
    fi
  fi
fi

# Ensure clean exit
exit 0
