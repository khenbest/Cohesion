#!/usr/bin/env bash
# Cohesion Documentation Workflow Intelligence
# Event-driven documentation management - pure intelligence, no manual commands

# Import base utilities for colors, state management, etc.
_script_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd -P)"
if [ -f "$_script_dir/cohesion-utils.sh" ]; then
  source "$_script_dir/cohesion-utils.sh"
fi
if [ -f "$_script_dir/cohesion-docs.sh" ]; then
  source "$_script_dir/cohesion-docs.sh"
fi

# =============================================================================
# INTELLIGENCE FUNCTIONS - When to create what documentation
# =============================================================================

detect_effort_complexity() {
  local prompt="$1"
  local mode="$2"
  
  # Simple heuristics for complexity detection
  local word_count=$(echo "$prompt" | wc -w)
  local complexity_indicators="implement|design|build|create|refactor|analyze|understand|investigate|architecture|system"
  local feature_indicators="add|implement|build|create|develop"
  local discovery_indicators="understand|analyze|investigate|research|explore|review"
  local major_indicators="design|architecture|system|redesign|migration|integration"
  
  # Simple tasks - short prompts or basic operations
  if [[ $word_count -lt 8 && ! "$prompt" =~ $complexity_indicators ]]; then
    echo "simple"
    return
  fi
  
  # Discovery work - understanding/analysis focused
  if [[ "$mode" == "DISCOVER" && "$prompt" =~ $discovery_indicators ]]; then
    echo "discovery"
    return
  fi
  
  # Major initiatives - architecture/system level
  if [[ "$prompt" =~ $major_indicators ]]; then
    echo "major"
    return
  fi
  
  # Feature work - implementation focused
  if [[ "$prompt" =~ $feature_indicators ]]; then
    echo "feature"
    return
  fi
  
  # Default to simple for unclear cases
  echo "simple"
}

should_create_execution_plan() {
  local complexity="$1"
  local existing_plan="$DOCS_DIR/DETAILED_EXECUTION_PLAN.md"
  
  # Don't create if we already have an active plan
  [[ -f "$existing_plan" ]] && return 1
  
  # Create for complex work only
  case "$complexity" in
    "discovery"|"feature"|"major") return 0 ;;
    *) return 1 ;;
  esac
}

detect_decision_points() {
  local prompt="$1"
  
  # Look for decision language
  local decision_indicators="should we|which approach|choose between|decide on|options are|vs|versus|alternative"
  [[ "$prompt" =~ $decision_indicators ]] && return 0
  
  # Look for architecture/tech decisions
  local tech_indicators="database|framework|library|architecture|design pattern|technology|tool|approach"
  [[ "$prompt" =~ $tech_indicators ]] && return 0
  
  # Look for implementation choices
  local impl_indicators="implement|solution|strategy|method|way to"
  [[ "$prompt" =~ $impl_indicators && $(echo "$prompt" | wc -w) -gt 10 ]] && return 0
  
  return 1
}

# =============================================================================
# DOCUMENT CREATION FUNCTIONS
# =============================================================================

create_contextual_execution_plan() {
  local effort_type="$1"
  local title="$2"
  local context="$3"
  local plan_file="$DOCS_DIR/DETAILED_EXECUTION_PLAN.md"
  
  mkdir -p "$(dirname "$plan_file")" 2>/dev/null || true
  
  # Get current timestamp and mode
  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  local current_mode=$(get_cohesion_mode)
  
  # Create plan based on effort type
  case "$effort_type" in
    "discovery")
      create_discovery_execution_plan "$plan_file" "$title" "$context" "$timestamp" "$current_mode"
      ;;
    "feature")
      create_feature_execution_plan "$plan_file" "$title" "$context" "$timestamp" "$current_mode"
      ;;
    "major")
      create_full_execution_plan "$plan_file" "$title" "$context" "$timestamp" "$current_mode"
      ;;
  esac
  
  append_to_daily_log "DOCS" "Auto-created $effort_type execution plan: $title"
}

create_discovery_execution_plan() {
  local plan_file="$1"
  local title="$2"
  local context="$3"
  local timestamp="$4"
  local mode="$5"
  
  cat > "$plan_file" <<EOF
# 📋 DETAILED EXECUTION PLAN: $title

**Created**: $timestamp | **Type**: Discovery Analysis  
**Status**: In Progress | **Mode**: $mode

---

## 🎯 **DISCOVERY PHASE** (Priority 1)

### **Understanding Current State** (Analysis Focus)

#### **Current State Analysis**
Based on initial investigation:
- 🔄 **Research Needed**: $context
- ❓ **Questions to Answer**: [To be determined during analysis]
- 📋 **Documentation to Review**: [To be identified]

#### **Investigation Steps**

**Step 1: Initial Exploration** (⏱️ 1-2 hours)
- [ ] Review existing documentation
- [ ] Examine current implementation
- [ ] Identify key components and patterns

**Expected Output**:
- Understanding of current architecture
- List of key files and components
- Initial questions and areas of interest

**Validation**:
- [ ] Can explain current system to someone else
- [ ] Have identified main components
- [ ] Know what questions need answering

---

**Step 2: Deep Analysis** (⏱️ 2-4 hours)  
**Context**: Detailed investigation of specific areas

**Actions**:
1. [ ] Analyze core functionality
2. [ ] Document current behavior
3. [ ] Identify improvement opportunities
4. [ ] Note any issues or concerns

**Testing**:
- [ ] Verify understanding through testing
- [ ] Document current behavior
- [ ] Note any unexpected findings

---

## 🔍 **VALIDATION & NEXT STEPS**

### **Discovery Acceptance Criteria**
- [ ] Current state fully understood
- [ ] Key questions answered
- [ ] Documentation updated with findings
- [ ] Clear path forward identified

### **Potential Next Steps**
- [ ] Create implementation plan if changes needed
- [ ] Document recommendations
- [ ] Identify additional research areas
- [ ] Prepare for next phase

---

## 📝 **EXECUTION LOG**

### **Session 1** - $timestamp (Active)
**Planned**:
- 🔄 Begin discovery of: $context

**Next Steps**:
- [ ] Start initial exploration
- [ ] Document findings as we go

---

**Execution Status**: In Progress  
**Discovery Progress**: 0% Complete  
**Next Review**: After initial exploration
EOF
}

create_feature_execution_plan() {
  local plan_file="$1"
  local title="$2"
  local context="$3"
  local timestamp="$4"
  local mode="$5"
  
  cat > "$plan_file" <<EOF
# 📋 DETAILED EXECUTION PLAN: $title

**Created**: $timestamp | **Type**: Feature Implementation  
**Status**: Planning | **Mode**: $mode

---

## 🎯 **IMPLEMENTATION PHASE** (Priority 1)

### **Feature Development** (Implementation Focus)

#### **Current State Analysis**
Based on requirements:
- ✅ **Requirements**: $context
- 🔄 **Implementation Needed**: [To be detailed]
- ❌ **Blockers**: None identified yet

#### **Implementation Steps**

**Step 1: Setup & Planning** (⏱️ 30-60 minutes)
- [ ] Review requirements
- [ ] Design approach
- [ ] Identify dependencies
- [ ] Create task breakdown

**Expected Output**:
- Clear implementation approach
- List of required changes
- Testing strategy

**Validation**:
- [ ] Approach approved (if needed)
- [ ] Dependencies identified
- [ ] Ready to implement

---

**Step 2: Core Implementation** (⏱️ Variable)
**Context**: Build the main functionality

**Actions**:
1. [ ] Implement core feature
2. [ ] Add necessary tests
3. [ ] Update documentation
4. [ ] Handle edge cases

**Testing**:
- [ ] Unit tests passing
- [ ] Integration tests passing
- [ ] Manual testing completed

---

## 🔍 **VALIDATION & TESTING**

### **Acceptance Criteria**
- [ ] Feature works as specified
- [ ] Tests are passing
- [ ] Documentation is updated
- [ ] No regressions introduced

### **Testing Strategy**
- [ ] Unit tests for core functionality
- [ ] Integration tests for system interaction
- [ ] Manual testing for user experience

---

## 📝 **EXECUTION LOG**

### **Session 1** - $timestamp (Active)
**Planned**:
- 🔄 Begin implementation of: $context

**Next Steps**:
- [ ] Start with setup and planning
- [ ] Break down into specific tasks

---

**Execution Status**: Planning  
**Implementation Progress**: 0% Complete  
**Next Review**: After planning phase
EOF
}

create_full_execution_plan() {
  local plan_file="$1"
  local title="$2"
  local context="$3"
  local timestamp="$4"
  local mode="$5"
  
  # Copy the full template and customize it
  local template_file
  # Try different possible locations for the template
  for possible_template in \
    "$_script_dir/../../docs/DETAILED_EXECUTION_PLAN.md" \
    "$PROJECT_DIR/docs/DETAILED_EXECUTION_PLAN.md" \
    "$DOCS_DIR/DETAILED_EXECUTION_PLAN.md"; do
    if [[ -f "$possible_template" ]]; then
      template_file="$possible_template"
      break
    fi
  done
  if [[ -f "$template_file" ]]; then
    cp "$template_file" "$plan_file"
    
    # Customize the template
    sed -i "s/\[Project Name\]/$title/g" "$plan_file"
    sed -i "s/\[Date\]/$timestamp/g" "$plan_file"
    sed -i "s/\[Sprint\/Phase Name\]/Major Initiative/g" "$plan_file"
    sed -i "s/\[Draft\/Ready\/In Progress\]/In Progress/g" "$plan_file"
    sed -i "s/\[X-Y hours\]/To be estimated/g" "$plan_file"
    
    # Add initial context
    sed -i "/Based on \[analysis source\]:/a\\
- 🔄 **Initiative**: $context\\
- ❓ **Scope**: To be defined\\
- 📋 **Planning**: Required" "$plan_file"
  else
    # Fallback if template not found
    create_feature_execution_plan "$plan_file" "$title" "$context" "$timestamp" "$mode"
  fi
  
  append_to_daily_log "DOCS" "Created major initiative plan from template"
}

create_adr_template() {
  local title="$1"
  local adr_number=$(get_next_adr_number)
  local safe_title=$(echo "$title" | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-zA-Z0-9-]//g')
  local adr_file="$DOCS_DIR/05-decisions/adr-$adr_number-$safe_title.md"
  
  mkdir -p "$(dirname "$adr_file")" 2>/dev/null || true
  
  # Copy ADR template and customize  
  local template_file
  # Try different possible locations for the ADR template
  for possible_template in \
    "$_script_dir/../../docs/05-decisions/adr-template.md" \
    "$PROJECT_DIR/docs/05-decisions/adr-template.md" \
    "$DOCS_DIR/05-decisions/adr-template.md"; do
    if [[ -f "$possible_template" ]]; then
      template_file="$possible_template"
      break
    fi
  done
  if [[ -f "$template_file" ]]; then
    cp "$template_file" "$adr_file"
    sed -i "s/\[NUMBER\]/$adr_number/g" "$adr_file"
    sed -i "s/\[Title\]/$title/g" "$adr_file"
    sed -i "s/YYYY-MM-DD/$(date +%Y-%m-%d)/g" "$adr_file"
  else
    # Fallback basic ADR
    cat > "$adr_file" <<EOF
# ADR-$adr_number: $title

**Status**: Proposed  
**Date**: $(date +%Y-%m-%d)  
**Deciders**: [Team members involved]

## Context and Problem Statement

[Describe the decision point that was detected]

## Considered Options

1. **Option 1**: [First approach]
2. **Option 2**: [Alternative approach]
3. **Option 3**: [Do nothing]

## Decision Outcome

**Chosen option**: "[To be decided]"

## Pros and Cons

### Option 1
**Pros**: [Benefits]
**Cons**: [Drawbacks]

### Option 2  
**Pros**: [Benefits]
**Cons**: [Drawbacks]

## Implementation Plan

- [ ] Define implementation steps
- [ ] Assign responsibilities
- [ ] Set timeline

---
*Auto-generated by Cohesion based on detected decision point*
EOF
  fi
  
  append_to_daily_log "DOCS" "Auto-created ADR-$adr_number: $title"
  echo "$adr_file"
}

# =============================================================================
# UPDATE FUNCTIONS
# =============================================================================

update_execution_plan_progress() {
  local plan_file="$DOCS_DIR/DETAILED_EXECUTION_PLAN.md"
  local session_summary="$1"
  
  [[ ! -f "$plan_file" ]] && return 0
  
  local timestamp=$(date +%Y-%m-%d)
  local time_stamp=$(date +%H:%M)
  
  # Check if today's session already exists
  if grep -q "Session.*$timestamp" "$plan_file"; then
    # Update existing session
    sed -i "/Session.*$timestamp/,/### Session\\|^---\\|^$/{ 
      /^\*\*Next Steps\*\*:/,/^$/{
        /^- \[ \]/d
      }
    }" "$plan_file"
    sed -i "/Session.*$timestamp/,/### Session\\|^---\\|^$/{
      /^\*\*Completed\*\*:/a\\
- ✅ $session_summary ($time_stamp)
      /^\*\*Next Steps\*\*:/a\\
- [ ] Continue from current progress
    }" "$plan_file"
  else
    # Add new session entry
    local session_entry="### Session - $timestamp
**Completed**:
- ✅ $session_summary ($time_stamp)

**Next Steps**:
- [ ] Continue from current progress

"
    
    # Insert after "## 📝 EXECUTION LOG" 
    sed -i "/## 📝 \*\*EXECUTION LOG\*\*/a\\
\\
$session_entry" "$plan_file"
  fi
}

# =============================================================================
# WORKFLOW EVENT HANDLERS  
# =============================================================================

handle_session_start_docs() {
  local mode="$1"
  
  # Show documentation context
  show_documentation_context
  
  # Log session start
  append_to_daily_log "SESSION" "Started in $mode mode"
  update_state_dashboard "session_start" "$mode"
}

handle_mode_change_docs() {
  local from_mode="$1"
  local to_mode="$2" 
  local context="$3"
  
  # Log the transition
  record_mode_change "$from_mode" "$to_mode" "$context"
  
  # Check if documentation should be created for significant context
  if [[ -n "$context" && $(echo "$context" | wc -w) -gt 3 ]]; then
    local complexity=$(detect_effort_complexity "$context" "$to_mode")
    
    if should_create_execution_plan "$complexity"; then
      create_contextual_execution_plan "$complexity" "$context" "$context"
      echo "📋 Auto-created $complexity execution plan based on your transition" >&2
    fi
  fi
  
  update_state_dashboard "mode_change" "$from_mode → $to_mode" "$context"
}

handle_user_prompt_docs() {
  local prompt="$1"
  local mode="$2"
  
  # Log user intention (first 100 chars)
  local log_prompt=$(echo "$prompt" | head -c 100 | tr '\n' ' ' | sed 's/[[:space:]]+/ /g')
  [[ -n "$log_prompt" ]] && append_to_daily_log "PROMPT" "$log_prompt"
  
  # Auto-detect and auto-create documentation
  local complexity=$(detect_effort_complexity "$prompt" "$mode")
  
  # Auto-create execution plan if complexity detected
  if should_create_execution_plan "$complexity"; then
    # Extract a clean title from the prompt
    local title=$(echo "$prompt" | head -c 80 | sed 's/[^a-zA-Z0-9 ]//g' | xargs)
    create_contextual_execution_plan "$complexity" "$title" "$prompt"
    echo "📋 Auto-created $complexity execution plan based on your request" >&2
  fi
  
  # Auto-create ADR if decision point detected
  if detect_decision_points "$prompt"; then
    local decision_title=$(echo "$prompt" | head -c 60 | sed 's/[^a-zA-Z0-9 ]//g' | xargs)
    local adr_file=$(create_adr_template "$decision_title")
    echo "🤔 Auto-created decision record: $(basename "$adr_file")" >&2
    echo "💡 Please review and approve this decision in $adr_file" >&2
  fi
  
  # Update dashboard with current focus (if significant)
  if [[ $(echo "$prompt" | wc -w) -gt 5 ]]; then
    update_state_dashboard "prompt_analysis" "$prompt"
  fi
}

handle_session_end_docs() {
  local mode="$1"
  local duration="$2"
  
  # Update execution plan if exists
  if [[ -n "$duration" ]]; then
    update_execution_plan_progress "Session completed ($duration)"
  else
    update_execution_plan_progress "Session completed"
  fi
  
  # Log session end
  append_to_daily_log "SESSION" "Ended in $mode mode${duration:+ ($duration)}"
  update_state_dashboard "session_end" "${duration:-completed}"
}

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

show_documentation_context() {
  local state_file="$DOCS_DIR/STATE.md"
  local plan_file="$DOCS_DIR/DETAILED_EXECUTION_PLAN.md"
  
  echo "📚 Documentation Context:" >&2
  
  if [[ -f "$plan_file" ]]; then
    # Try to extract the title from the plan
    local plan_title=$(head -5 "$plan_file" | grep "^# " | sed 's/^# 📋 DETAILED EXECUTION PLAN: //' | head -1)
    echo "  📋 Active execution plan: ${plan_title:-Active}" >&2
  fi
  
  # Count decision records
  local adr_count=0
  if [[ -d "$DOCS_DIR/05-decisions" ]]; then
    adr_count=$(find "$DOCS_DIR/05-decisions" -name "adr-*.md" -type f 2>/dev/null | wc -l)
  fi
  if [[ $adr_count -gt 0 ]]; then
    echo "  🤔 Decision records: $adr_count ADRs" >&2
  fi
  
  # Show recent activity if available
  if command -v get_recent_activity >/dev/null 2>&1; then
    local recent=$(get_recent_activity)
    if [[ -n "$recent" ]]; then
      echo "  📈 Recent activity:" >&2
      echo "$recent" >&2
    fi
  fi
}

get_next_adr_number() {
  local adr_dir="$DOCS_DIR/05-decisions"
  local highest=0
  
  if [[ -d "$adr_dir" ]]; then
    for file in "$adr_dir"/adr-*.md; do
      [[ -f "$file" ]] || continue
      local num=$(basename "$file" | sed 's/adr-\([0-9]*\)-.*/\1/')
      if [[ $num =~ ^[0-9]+$ ]] && [[ $num -gt $highest ]]; then
        highest=$num
      fi
    done
  fi
  
  printf "%03d" $((highest + 1))
}

update_state_dashboard() {
  local event_type="$1"
  local data="$2"
  local context="${3:-}"
  
  # Use existing dashboard functions from cohesion-docs.sh if available
  if command -v smart_dashboard_update >/dev/null 2>&1; then
    smart_dashboard_update "$event_type" "$data" "$context"
  fi
}

# Export all functions for use in hooks
export -f detect_effort_complexity
export -f should_create_execution_plan
export -f detect_decision_points
export -f create_contextual_execution_plan
export -f create_adr_template
export -f update_execution_plan_progress
export -f update_state_dashboard
export -f handle_session_start_docs
export -f handle_mode_change_docs
export -f handle_user_prompt_docs
export -f handle_session_end_docs
export -f show_documentation_context
export -f get_next_adr_number