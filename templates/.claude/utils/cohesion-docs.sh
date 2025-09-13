#!/usr/bin/env bash
# Cohesion Documentation Utilities
# Lightweight, append-only documentation functions

# Get today's log file
get_daily_log() {
  local date_stamp=$(date +%Y-%m-%d)
  echo "$DOCS_DIR/04-progress/daily-${date_stamp}.md"
}

# Append entry to daily log (fast, no parsing)
append_to_daily_log() {
  local entry_type="$1"
  local message="$2"
  local timestamp=$(date +"%H:%M:%S")
  local log_file=$(get_daily_log)
  
  mkdir -p "$(dirname "$log_file")" 2>/dev/null || true
  
  # First entry of the day? Add header
  if [[ ! -f "$log_file" ]]; then
    echo "# Daily Activity - $(date +%Y-%m-%d)" >> "$log_file"
    echo "" >> "$log_file"
  fi
  
  # Append entry (single write operation)
  echo "**${timestamp}** [${entry_type}] ${message}" >> "$log_file"
}

# Get recent activity for context (used by /startup)
get_recent_activity() {
  local log_file=$(get_daily_log)
  if [[ -f "$log_file" ]]; then
    tail -5 "$log_file" 2>/dev/null | sed 's/^/  /'
  fi
}

# Record mode transition (used by mode commands)
record_mode_change() {
  local from_mode="$1"
  local to_mode="$2"
  local reason="${3:-Manual transition}"
  
  append_to_daily_log "MODE" "${from_mode} → ${to_mode}: ${reason}"
  
  # Also update STATE.md with latest mode
  local state_file="$DOCS_DIR/STATE.md"
  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  
  if [[ -f "$state_file" ]]; then
    # Just append the transition to history section
    echo "- ${timestamp}: ${from_mode} → ${to_mode}" >> "$state_file"
  else
    # Create initial STATE.md
    cat > "$state_file" <<EOF
# Project State

**Current Mode:** ${to_mode}
**Last Updated:** ${timestamp}

## Mode History
- ${timestamp}: ${from_mode} → ${to_mode}
EOF
  fi
}

# Create progress checkpoint (used by /save)
create_progress_checkpoint() {
  local checkpoint_file="$DOCS_DIR/04-progress/checkpoints.md"
  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  local mode=$(get_cohesion_mode)
  
  mkdir -p "$(dirname "$checkpoint_file")" 2>/dev/null || true
  
  # Initialize file if needed
  if [[ ! -f "$checkpoint_file" ]]; then
    echo "# Progress Checkpoints" > "$checkpoint_file"
    echo "" >> "$checkpoint_file"
  fi
  
  # Append checkpoint
  {
    echo "## Checkpoint: ${timestamp}"
    echo "**Mode:** ${mode}"
    
    # Add git status if available
    if command -v git >/dev/null 2>&1 && git rev-parse --git-dir >/dev/null 2>&1; then
      local changes=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
      if [[ "$changes" -gt 0 ]]; then
        echo "**Uncommitted changes:** ${changes} files"
        echo "\`\`\`"
        git status --short 2>/dev/null | head -5
        echo "\`\`\`"
      fi
    fi
    echo ""
  } >> "$checkpoint_file"
}

# Export functions for use in hooks
export -f get_daily_log
export -f append_to_daily_log
export -f get_recent_activity
export -f record_mode_change
export -f create_progress_checkpoint