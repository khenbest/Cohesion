#!/usr/bin/env bash
# Cohesion Script Header (standardized)
# Requires: bash >= 3.2 or zsh >= 5 (zsh-compatible via cohesion-utils)
set -euo pipefail

_script_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd -P)"
_utils_candidates=(
  "$_script_dir/../.claude/utils/cohesion-utils.sh"
  "$_script_dir/../../.claude/utils/cohesion-utils.sh"
  "$_script_dir/../utils/cohesion-utils.sh"
  "$HOME/.cohesion/utils/cohesion-utils.sh"
  "$PWD/.claude/utils/cohesion-utils.sh"
)
for _u in "${_utils_candidates[@]}"; do
  # shellcheck disable=SC1090
  if [ -f "$_u" ]; then . "$_u"; _found_utils=1; break; fi
done
: "${_found_utils:=0}"
if [ "$_found_utils" -eq 0 ]; then
  printf 'cohesion: missing cohesion-utils.sh\n' >&2; exit 1
fi
unset _script_dir _u _utils_candidates _found_utils

if [[ ! -f "$MANIFEST_FILE" ]]; then
  echo -e "${YELLOW}Warning: No manifest found. Manual uninstall required.${NC}"
  echo ""
  echo "Manual steps:"
  echo "  1. Remove: rm -rf ~/.cohesion"
  echo "  2. Remove PATH entries from ~/.zshrc and ~/.bashrc"
  echo "  3. Remove Cohesion section from ~/CLAUDE.md"
  echo "  4. Review ~/.claude/settings.json for Cohesion entries"
  exit 1
fi

# Read manifest
echo "Reading manifest..."
GLOBAL_FILES=$(jq -r '.global_files[]?' "$MANIFEST_FILE" 2>/dev/null || echo "")
PATH_MODS=$(jq -r '.path_modifications[]?.file' "$MANIFEST_FILE" 2>/dev/null || echo "")
PROJECTS=$(jq -r '.projects | keys[]?' "$MANIFEST_FILE" 2>/dev/null || echo "")

# Confirm
echo ""
echo "This will remove:"
echo "  • Cohesion directory: $COHESION_HOME"
echo "  • Global files tracked in manifest"
echo "  • PATH modifications from shell configs"
echo "  • Cohesion sections from CLAUDE.md"
echo ""
read -p "Continue? [y/N] " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 0
fi

# Remove tracked files
echo ""
echo "Removing tracked files..."
for file in $GLOBAL_FILES; do
  if [[ -f "$file" ]]; then
    rm -f "$file"
    echo "  ✓ Removed $file"
  fi
done

# Remove PATH modifications
echo ""
echo "Cleaning PATH from shell configs..."
for rc in $PATH_MODS; do
  if [[ -f "$rc" ]]; then
    # Remove Cohesion block
    sed -i.cohesion-backup '/# Cohesion/,+1d' "$rc" 2>/dev/null || \
    sed -i '.cohesion-backup' '/# Cohesion/,+1d' "$rc" 2>/dev/null || true
    echo "  ✓ Cleaned $rc"
  fi
done

# Clean CLAUDE.md
if [[ -f "$GLOBAL_CLAUDE_MD" ]]; then
  echo ""
  echo "Cleaning global CLAUDE.md..."
  # Remove Cohesion section
  sed -i.cohesion-backup '/## Cohesion DUO Protocol/,/^##\|^$/d' "$GLOBAL_CLAUDE_MD" 2>/dev/null || \
  sed -i '.cohesion-backup' '/## Cohesion DUO Protocol/,/^##\|^$/d' "$GLOBAL_CLAUDE_MD" 2>/dev/null || true
  
  # Remove file if it's now empty
  if [[ ! -s "$GLOBAL_CLAUDE_MD" ]]; then
    rm -f "$GLOBAL_CLAUDE_MD"
    echo "  ✓ Removed empty CLAUDE.md"
  else
    echo "  ✓ Removed Cohesion section from CLAUDE.md"
  fi
fi

# Clean up project installations
if [[ -n "$PROJECTS" ]]; then
  echo ""
  echo "Cleaning up project installations..."
  for project in $PROJECTS; do
    echo -n "  • $project ... "
    if [[ -d "$project/.claude" ]]; then
      rm -rf "$project/.claude"
      echo "✓ Removed .claude directory"
    else
      echo "already clean"
    fi
    
    # Remove Cohesion section from project CLAUDE.md if it exists
    if [[ -f "$project/CLAUDE.md" ]]; then
      if grep -q "Cohesion DUO Protocol" "$project/CLAUDE.md"; then
        # Remove Cohesion section (from # Cohesion DUO Protocol to end of file)
        sed -i.cohesion-backup '/# Cohesion DUO Protocol/,$d' "$project/CLAUDE.md" 2>/dev/null || true
        echo "    ✓ Removed Cohesion section from CLAUDE.md"
      fi
    fi
  done
fi

# Clean Claude settings (careful - don't remove whole file)
if [[ -f "$CLAUDE_HOME/settings.json" ]]; then
  echo ""
  echo "Reviewing Claude settings..."
  # Just notify, don't auto-remove as it might have other settings
  echo -e "${YELLOW}Note: Review ~/.claude/settings.json for Cohesion entries${NC}"
  echo "  Cohesion-related entries include permissions rules and customInstructions"
fi

# Remove Cohesion directory
echo ""
echo "Removing Cohesion directory..."
rm -rf "$COHESION_HOME"
echo "  ✓ Removed $COHESION_HOME"

# Clean up backups
echo ""
echo "Cleaning backup files..."
find "$HOME" -maxdepth 1 -name "*.cohesion-backup" -delete 2>/dev/null || true
echo "  ✓ Removed backup files"

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║              Uninstallation Complete                      ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
echo "Cohesion has been removed from your system."
echo ""
echo "To reinstall:"
echo "  git clone https://github.com/khenbest/Cohesion"
echo "  cd Cohesion && ./install.sh"
