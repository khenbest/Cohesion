# .claude/hooks/ Directory

This directory contains Claude Code event hooks that automatically execute during session lifecycle events to enforce Cohesion behavior and maintain state consistency.

## Hook Files

### Single Hook Architecture
- `pre-tool-use.sh` - **The only hook** - handles session lifecycle, state management, mode restrictions, canon guidance, and context preservation

🪝 **Why Single Hook?**
- ⚡ **Instant Mode Switching** - No race conditions or timing conflicts
- 🔒 **Bulletproof Reliability** - One checkpoint controls everything
- 🎮 **Complete Control** - Gates all 15 Claude Code tools seamlessly

## Hook Execution Sequence

### Every Tool Call (pre-tool-use.sh)
1. **Mode Detection** - Restore current mode and context if needed
2. **State Management** - Initialize state files, manage transitions
3. **Tool Validation** - Validate tool usage against current mode restrictions
4. **Canon Enforcement** - Apply the Six Canon principles
5. **Session Persistence** - Automatically save state and context
6. **Command Processing** - Handle slash commands (/unleash, /save, etc.)

## Dependencies

### Required Dependencies
All hooks require:
- `../utils/cohesion-utils.sh` - Core state and utility functions
- Proper JSON handling (jq recommended)
- File system access for state management

### Optional Dependencies
Hooks gracefully handle missing:
- `../utils/cohesion-docs-workflow.sh` - Auto-documentation features
- Various project-specific tools and commands

## Mode Enforcement

### DISCOVER Mode (Read-Only)
- **Allowed**: Read, Glob, Grep, safe Bash commands
- **Blocked**: Write, Edit, MultiEdit, dangerous operations
- **Purpose**: Force analysis before action

### OPTIMIZE Mode (Collaborative)
- **Allowed**: All DISCOVER tools + Write/Edit with approval
- **Required**: `/approve [file]` before file modifications
- **Purpose**: Careful, deliberate changes with oversight

### UNLEASH Mode (Autonomous)
- **Allowed**: All tools and operations
- **Restrictions**: None (full autonomy)
- **Purpose**: Rapid implementation with complete freedom

## State Management

### State Files Managed
- `.claude/state/DISCOVER|OPTIMIZE|UNLEASH` - Current mode indicator
- `.claude/state/.session_context` - Session persistence data
- `.claude/state/.command_history` - Command execution log
- `.claude/state/.approved_edits` - Approved files list (OPTIMIZE)

### Recovery Mechanisms
- Session context restored on restart
- Mode state preserved across interruptions
- Command history maintained for continuity
- Error recovery with graceful degradation

## Canon Enforcement

Hooks automatically enforce the Six Canon Constructs:

1. **Think-First** - DISCOVER mode prevents premature action
2. **Always-Works** - Tool restrictions ensure functional code
3. **Reality-Check** - State validation catches inconsistencies
4. **Approval-Criteria** - OPTIMIZE mode requires explicit permissions
5. **Naming-Conventions** - Consistent file and variable naming
6. **Close-the-Loop** - System impact analysis for major changes

## Integration Points

### Claude Code Integration
- Native hook registration via settings.json
- Event-driven execution (no polling)
- Seamless user experience

### Documentation System
- Auto-generation triggers based on activity
- Progress tracking and milestone detection
- Decision record creation for major choices

### Error Handling
- Graceful degradation when components unavailable
- Informative error messages for troubleshooting
- Automatic recovery from common failure modes

---

*Hooks operate transparently to maintain Cohesion behavior without interrupting the natural development flow.*