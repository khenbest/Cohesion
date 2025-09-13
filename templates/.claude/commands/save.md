---
description: "Save session context and update project documentation"
allowed-tools: Bash(*:*), Read(*:*), Write(*:*)
---

## Session Save & Documentation Update

!`.claude/commands/save $ARGUMENTS`

# 💾 Save Command - Session Context & Documentation Bridge

Transform session endpoints into documentation events that feed the project's living memory system.

## Usage

- `/save [context]` - Session checkpoint with optional context note
- `/save --milestone "Description"` - Major milestone with full Close-the-Loop analysis

## What Gets Saved

### Session Save (Default)
- Current progress and context
- Mode transitions and approved files  
- Updates STATE.md and daily activity log
- Lightweight, quick execution

### Milestone Save
- Comprehensive Close-the-Loop analysis
- Documentation synchronization 
- Execution plan updates
- ADR generation for major decisions

## Integration Points

**Always Updated:**
- `STATE.md` - Current focus and progress
- `docs/04-progress/daily-YYYY-MM-DD.md` - Session summary

**Milestone Updates:**
- `DETAILED_EXECUTION_PLAN.md` - Task completion
- `docs/05-decisions/` - Architecture decisions
- Documentation gap analysis and suggestions

---

*Canon Principle: Close-the-Loop - Every session contributes to permanent project wisdom.*