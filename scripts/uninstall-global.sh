#!/usr/bin/env bash
# Cohesion Global Uninstaller
# Uses manifest to cleanly remove all Cohesion artifacts

set -euo pipefail

COHESION_HOME="${COHESION_HOME:-$HOME/.cohesion}"
MANIFEST_FILE="${COHESION_HOME}/.manifest.json"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
GLOBAL_CLAUDE_MD="${GLOBAL_CLAUDE_MD:-$HOME/CLAUDE.md}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "╔══════════════════════════════════════════════════════════╗"
echo "║              Cohesion Global Uninstaller                  ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# Check for manifest
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

# Warn about projects
if [[ -n "$PROJECTS" ]]; then
  echo ""
  echo -e "${YELLOW}Warning: Found Cohesion in these projects:${NC}"
  for project in $PROJECTS; do
    echo "  • $project"
  done
  echo ""
  echo "To remove from projects, run in each:"
  echo "  cd <project> && cohesion uninstall"
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