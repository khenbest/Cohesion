#!/usr/bin/env bash
# Cohesion Script Header (standardized)
# Enhanced Cohesion Doctor - Self-healing system diagnostics and repair
set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Paths
COHESION_HOME="${COHESION_HOME:-$HOME/.cohesion}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Find COHESION_ROOT - could be the parent of script dir or COHESION_HOME itself
if [[ -d "$SCRIPT_DIR/../templates" ]]; then
  COHESION_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
elif [[ -d "$COHESION_HOME/templates" ]]; then
  COHESION_ROOT="$COHESION_HOME"
else
  # Fallback to script parent
  COHESION_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
fi

# Diagnostic results
declare -a ERRORS=()
declare -a WARNINGS=()
declare -a FIXED=()
declare -a UNFIXABLE=()

# ============================================================================
# DIAGNOSTIC FUNCTIONS
# ============================================================================

check_installation_paths() {
  echo -e "${BLUE}Checking installation paths...${NC}"
  
  if [[ ! -d "$COHESION_HOME" ]]; then
    ERRORS+=("Cohesion home directory not found: $COHESION_HOME")
  else
    # Check required directories
    local required_dirs=("bin" "hooks" "utils" "templates" "scripts")
    for dir in "${required_dirs[@]}"; do
      if [[ ! -d "$COHESION_HOME/$dir" ]]; then
        ERRORS+=("Missing required directory: $COHESION_HOME/$dir")
      fi
    done
  fi
  
  return 0
}

check_utils_completeness() {
  echo -e "${BLUE}Checking utility scripts...${NC}"
  
  local required_utils=(
    "cohesion-utils.sh"
    "cohesion-docs.sh"
    "cohesion-docs-workflow.sh"
    "cohesion-shell-safety.sh"
    "script-header.sh"
  )
  
  for util in "${required_utils[@]}"; do
    if [[ ! -f "$COHESION_HOME/utils/$util" ]]; then
      ERRORS+=("Missing utility script: $util")
    elif [[ ! -r "$COHESION_HOME/utils/$util" ]]; then
      WARNINGS+=("Utility script not readable: $util")
    fi
  done
}

check_hooks_completeness() {
  echo -e "${BLUE}Checking hook scripts...${NC}"
  
  # Single hook architecture - only pre-tool-use.sh required
  local required_hooks=(
    "pre-tool-use.sh"
  )
  
  for hook in "${required_hooks[@]}"; do
    if [[ ! -f "$COHESION_HOME/hooks/$hook" ]]; then
      ERRORS+=("Missing hook script: $hook")
    elif [[ ! -x "$COHESION_HOME/hooks/$hook" ]]; then
      WARNINGS+=("Hook script not executable: $hook")
    fi
  done
}

check_cli_installation() {
  echo -e "${BLUE}Checking CLI installation...${NC}"
  
  if [[ ! -f "$COHESION_HOME/bin/cohesion" ]]; then
    ERRORS+=("Cohesion CLI not found in $COHESION_HOME/bin")
  elif [[ ! -x "$COHESION_HOME/bin/cohesion" ]]; then
    WARNINGS+=("Cohesion CLI not executable")
  fi
  
  # Check if in PATH
  if ! command -v cohesion >/dev/null 2>&1; then
    WARNINGS+=("Cohesion not in PATH - add $COHESION_HOME/bin to your PATH")
  fi
  
  return 0
}

check_templates() {
  echo -e "${BLUE}Checking templates...${NC}"
  
  if [[ ! -d "$COHESION_HOME/templates/.claude" ]]; then
    WARNINGS+=("Templates directory structure missing - repairs may be limited")
  else
    # Check for command templates
    local cmd_count=$(find "$COHESION_HOME/templates/.claude/commands" -name "*.md" 2>/dev/null | wc -l)
    if [[ $cmd_count -lt 7 ]]; then
      WARNINGS+=("Incomplete command templates (found $cmd_count, expected at least 7)")
    fi
  fi
  
  return 0
}

check_syntax_errors() {
  echo -e "${BLUE}Checking script syntax...${NC}"
  
  # Check all shell scripts for syntax errors
  for script in "$COHESION_HOME"/hooks/*.sh "$COHESION_HOME"/utils/*.sh; do
    if [[ -f "$script" ]]; then
      if ! bash -n "$script" 2>/dev/null; then
        ERRORS+=("Syntax error in: $(basename "$script")")
      fi
    fi
  done
}

# ============================================================================
# REPAIR FUNCTIONS
# ============================================================================

fix_missing_utils() {
  local util="$1"
  echo -e "  ${YELLOW}Fixing:${NC} Installing missing utility: $util"
  
  local source_file="$COHESION_ROOT/templates/.claude/utils/$util"
  local dest_file="$COHESION_HOME/utils/$util"
  
  if [[ -f "$source_file" ]]; then
    cp "$source_file" "$dest_file"
    chmod 644 "$dest_file"
    FIXED+=("Installed missing utility: $util")
    return 0
  else
    echo -e "    ${RED}Cannot fix:${NC} Template not found at $source_file"
    UNFIXABLE+=("Missing utility: $util (template not found)")
    return 1
  fi
}

fix_missing_hooks() {
  local hook="$1"
  echo -e "  ${YELLOW}Fixing:${NC} Installing missing hook: $hook"
  
  local source_file="$COHESION_ROOT/templates/.claude/hooks/$hook"
  local dest_file="$COHESION_HOME/hooks/$hook"
  
  if [[ -f "$source_file" ]]; then
    cp "$source_file" "$dest_file"
    chmod 755 "$dest_file"
    FIXED+=("Installed missing hook: $hook")
    return 0
  else
    echo -e "    ${RED}Cannot fix:${NC} Template not found at $source_file"
    UNFIXABLE+=("Missing hook: $hook (template not found)")
    return 1
  fi
}

fix_permissions() {
  echo -e "${YELLOW}Fixing permissions...${NC}"
  
  local perm_errors=0
  
  # Fix CLI permissions
  if [[ -f "$COHESION_HOME/bin/cohesion" ]]; then
    if chmod 755 "$COHESION_HOME/bin/cohesion" 2>/dev/null; then
      FIXED+=("Fixed CLI permissions")
    else
      echo -e "    ${RED}Cannot fix:${NC} Unable to change permissions on cohesion CLI"
      UNFIXABLE+=("Cannot fix CLI permissions (permission denied?)")
      ((perm_errors++))
    fi
  fi
  
  # Fix hook permissions
  local hooks_fixed=0
  for hook in "$COHESION_HOME"/hooks/*.sh; do
    if [[ -f "$hook" ]]; then
      if chmod 755 "$hook" 2>/dev/null; then
        ((hooks_fixed++))
      else
        ((perm_errors++))
      fi
    fi
  done
  if [[ $hooks_fixed -gt 0 ]]; then
    FIXED+=("Fixed permissions on $hooks_fixed hook(s)")
  fi
  
  # Fix utils permissions
  local utils_fixed=0
  for util in "$COHESION_HOME"/utils/*.sh; do
    if [[ -f "$util" ]]; then
      if chmod 644 "$util" 2>/dev/null; then
        ((utils_fixed++))
      else
        ((perm_errors++))
      fi
    fi
  done
  if [[ $utils_fixed -gt 0 ]]; then
    FIXED+=("Fixed permissions on $utils_fixed utility script(s)")
  fi
  
  if [[ $perm_errors -gt 0 ]]; then
    UNFIXABLE+=("$perm_errors permission fix(es) failed - check file ownership")
  fi
}

fix_missing_directories() {
  echo -e "${YELLOW}Creating missing directories...${NC}"
  
  local required_dirs=("bin" "hooks" "utils" "templates" "scripts" "state")
  for dir in "${required_dirs[@]}"; do
    if [[ ! -d "$COHESION_HOME/$dir" ]]; then
      if mkdir -p "$COHESION_HOME/$dir" 2>/dev/null; then
        FIXED+=("Created directory: $COHESION_HOME/$dir")
      else
        echo -e "    ${RED}Cannot create:${NC} $COHESION_HOME/$dir (permission denied?)"
        UNFIXABLE+=("Cannot create directory: $COHESION_HOME/$dir")
      fi
    fi
  done
}

# ============================================================================
# PROJECT REPAIR FUNCTIONS
# ============================================================================

fix_project() {
  local project_dir="${1:-.}"
  echo -e "${BLUE}Checking project: $project_dir${NC}"
  
  if [[ ! -d "$project_dir/.claude" ]]; then
    echo -e "  ${YELLOW}Not a Cohesion project (no .claude directory)${NC}"
    return 1
  fi
  
  # Check for missing utils in project
  local project_utils="$project_dir/.claude/utils"
  if [[ -d "$project_utils" ]]; then
    for util in cohesion-utils.sh cohesion-docs.sh cohesion-docs-workflow.sh; do
      if [[ ! -f "$project_utils/$util" ]]; then
        echo -e "  ${YELLOW}Fixing:${NC} Copying missing $util to project"
        if [[ -f "$COHESION_HOME/utils/$util" ]]; then
          cp "$COHESION_HOME/utils/$util" "$project_utils/"
          FIXED+=("Added $util to project")
        fi
      fi
    done
  fi
  
  # Check for missing commands
  local cmd_count=$(find "$project_dir/.claude/commands" -name "*.md" 2>/dev/null | wc -l)
  if [[ $cmd_count -lt 7 ]]; then
    echo -e "  ${YELLOW}Warning:${NC} Incomplete commands (found $cmd_count)"
    if [[ "$FIX_MODE" == "true" ]]; then
      echo -e "  ${YELLOW}Fixing:${NC} Copying missing command templates"
      cp -n "$COHESION_HOME/templates/.claude/commands"/*.md "$project_dir/.claude/commands/" 2>/dev/null
      FIXED+=("Updated command templates in project")
    fi
  fi
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
  local FIX_MODE=true
  local PROJECT_MODE=false
  
  # Parse arguments  
  for arg in "$@"; do
    case "$arg" in
      --project) PROJECT_MODE=true ;;
      --help)
        echo "Usage: cohesion doctor [OPTIONS]"
        echo "Options:"
        echo "  --project    Also check and repair current project"
        echo ""
        echo "Doctor automatically repairs issues by default."
        exit 0
        ;;
    esac
  done
  
  echo -e "${GREEN}═══════════════════════════════════════${NC}"
  echo -e "${GREEN}    Cohesion Doctor - System Health    ${NC}"
  echo -e "${GREEN}═══════════════════════════════════════${NC}"
  echo ""
  
  # Run diagnostics
  check_installation_paths
  check_cli_installation
  check_utils_completeness
  check_hooks_completeness
  check_templates
  check_syntax_errors  # Always check syntax - it's important
  
  if [[ "$PROJECT_MODE" == "true" ]]; then
    fix_project "$(pwd)"
  fi
  
  # Apply fixes if requested
  if [[ "$FIX_MODE" == "true" ]]; then
    echo ""
    echo -e "${YELLOW}═══════════════════════════════════════${NC}"
    echo -e "${YELLOW}         Applying Repairs...           ${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════${NC}"
    echo ""
    
    fix_missing_directories
    
    # Fix missing utils (only if errors exist)
    if [[ ${#ERRORS[@]} -gt 0 ]]; then
      for error in "${ERRORS[@]}"; do
        if [[ "$error" =~ "Missing utility script: "(.*) ]]; then
          fix_missing_utils "${BASH_REMATCH[1]}" || true
        fi
      done
    fi
    
    # Fix missing hooks (only if errors exist)
    if [[ ${#ERRORS[@]} -gt 0 ]]; then
      for error in "${ERRORS[@]}"; do
        if [[ "$error" =~ "Missing hook script: "(.*) ]]; then
          fix_missing_hooks "${BASH_REMATCH[1]}" || true
        fi
      done
    fi
    
    fix_permissions
  fi
  
  # Report results
  echo ""
  echo -e "${BLUE}═══════════════════════════════════════${NC}"
  echo -e "${BLUE}           Diagnostic Report           ${NC}"
  echo -e "${BLUE}═══════════════════════════════════════${NC}"
  echo ""
  
  if [[ ${#ERRORS[@]} -eq 0 ]]; then
    echo -e "${GREEN}✓ No critical errors found${NC}"
  else
    echo -e "${RED}✗ ${#ERRORS[@]} error(s) found:${NC}"
    for error in "${ERRORS[@]}"; do
      echo -e "  ${RED}•${NC} $error"
    done
  fi
  
  echo ""
  
  if [[ ${#WARNINGS[@]} -gt 0 ]]; then
    echo -e "${YELLOW}⚠ ${#WARNINGS[@]} warning(s):${NC}"
    for warning in "${WARNINGS[@]}"; do
      echo -e "  ${YELLOW}•${NC} $warning"
    done
    echo ""
  fi
  
  if [[ ${#FIXED[@]} -gt 0 ]]; then
    echo -e "${GREEN}✓ ${#FIXED[@]} issue(s) fixed:${NC}"
    for fix in "${FIXED[@]}"; do
      echo -e "  ${GREEN}•${NC} $fix"
    done
    echo ""
  fi
  
  if [[ ${#UNFIXABLE[@]} -gt 0 ]]; then
    echo -e "${RED}✗ ${#UNFIXABLE[@]} issue(s) could not be fixed:${NC}"
    for issue in "${UNFIXABLE[@]}"; do
      echo -e "  ${RED}•${NC} $issue"
    done
    echo ""
    echo -e "${YELLOW}Manual intervention required:${NC}"
    echo -e "  1. Ensure Cohesion source is complete at: $COHESION_ROOT"
    echo -e "  2. Check templates exist at: $COHESION_ROOT/templates/.claude/"
    echo -e "  3. Consider reinstalling Cohesion from GitHub"
    echo ""
  fi
  
  # Final status
  if [[ ${#ERRORS[@]} -eq 0 && ${#UNFIXABLE[@]} -eq 0 ]]; then
    echo -e "${GREEN}═══════════════════════════════════════${NC}"
    echo -e "${GREEN}      System Health: EXCELLENT         ${NC}"
    echo -e "${GREEN}═══════════════════════════════════════${NC}"
    exit 0
  elif [[ "$FIX_MODE" == "true" && ${#FIXED[@]} -gt 0 && ${#UNFIXABLE[@]} -eq 0 ]]; then
    echo -e "${YELLOW}═══════════════════════════════════════${NC}"
    echo -e "${YELLOW}    System Health: RECOVERING          ${NC}"
    echo -e "${YELLOW}  Run doctor again to verify fixes     ${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════${NC}"
    exit 0
  elif [[ ${#UNFIXABLE[@]} -gt 0 ]]; then
    echo -e "${RED}═══════════════════════════════════════${NC}"
    echo -e "${RED}   System Health: NEEDS MANUAL REPAIR  ${NC}"
    echo -e "${RED}     Some issues could not be fixed    ${NC}"
    echo -e "${RED}═══════════════════════════════════════${NC}"
    exit 1
  else
    echo -e "${RED}═══════════════════════════════════════${NC}"
    echo -e "${RED}     System Health: NEEDS REPAIR       ${NC}"
    echo -e "${RED}   Could not automatically fix issues   ${NC}"
    echo -e "${RED}═══════════════════════════════════════${NC}"
    exit 1
  fi
}

# Run main function
main "$@"