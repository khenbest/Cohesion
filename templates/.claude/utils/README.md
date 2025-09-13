# .claude/utils/ Directory

This directory contains shared utility functions and helper scripts that provide core functionality for Cohesion commands and hooks.

## Utility Files

### Core Utilities
- `cohesion-utils.sh` - Primary utility library with all core functions
- `script-header.sh` - Standardized script header for consistent sourcing

### Documentation Utilities (Complementary)
- `cohesion-docs.sh` - Simple documentation functions (append-only logging)
- `cohesion-docs-workflow.sh` - Intelligent workflow detection and auto-documentation
  - *Note: Imports and extends cohesion-docs.sh functions*

## Core Functions (cohesion-utils.sh)

### Mode Management
- `get_cohesion_mode()` - Determine current mode from state files
- `transition_to_mode(mode)` - Switch between DISCOVER/OPTIMIZE/UNLEASH
- `validate_mode_transition()` - Ensure valid mode changes

### State Management
- `save_session_context()` - Persist session data
- `restore_session_context()` - Load previous session state
- `reset_session_state()` - Clear state for fresh start

### File Operations
- `approve_edit(file)` - Add file to approved list (OPTIMIZE mode)
- `is_edit_approved(file)` - Check if file modification allowed
- `track_file_change()` - Log file modifications

### Command Context
- `save_command_context()` - Record command execution with context
- `get_command_history()` - Retrieve recent command history
- `log_message(level, message)` - Structured logging

### Validation Functions
- `ensure_state_structure()` - Create required directories and files
- `validate_state_consistency()` - Check state file integrity
- `cleanup_stale_state()` - Remove orphaned state files

## Documentation Functions

### Auto-Documentation (cohesion-docs-workflow.sh)
- `create_execution_plan()` - Generate detailed project plans
- `update_execution_plan_progress()` - Track task completion
- `create_decision_record()` - Auto-generate ADR templates
- `append_to_daily_log()` - Record daily activity

### Documentation Management (cohesion-docs.sh)
- `generate_project_summary()` - Create project overview
- `update_state_documentation()` - Sync STATE.md with reality
- `create_progress_checkpoint()` - Milestone documentation

## Usage Patterns

### In Commands
```bash
# Standard sourcing pattern
source ../utils/cohesion-utils.sh

# Mode operations
current_mode=$(get_cohesion_mode)
transition_to_mode "UNLEASH"

# Context management
save_command_context "discover" "authentication flow"
```

### In Hooks
```bash
# Hook-specific operations
ensure_state_structure
validate_mode_consistency

# Documentation triggers
if command -v create_progress_checkpoint >/dev/null 2>&1; then
  create_progress_checkpoint
fi
```

## Dependencies

### Required
- bash >= 3.2 or zsh >= 5.0
- Standard UNIX utilities (find, grep, sed, awk)
- JSON handling capability (jq preferred)

### Optional
- rsync (for efficient file operations)
- git (for repository operations)
- Project-specific tools (npm, cargo, etc.)

## Error Handling Philosophy

Utilities follow defensive programming principles:

1. **Graceful Degradation** - Functions work with reduced functionality when dependencies missing
2. **Informative Errors** - Clear messages about what failed and why
3. **Recovery Assistance** - Suggestions for resolving common issues
4. **State Protection** - Never corrupt state files, use atomic operations

## Cross-Platform Compatibility

### Shell Compatibility
- Works in bash 3.2+ (macOS default)
- Compatible with zsh 5.0+ (modern default)
- Proper quoting and variable handling

### File System
- Handles spaces in paths correctly
- Uses portable path operations
- Respects file permissions and ownership

### External Tools
- Checks for tool availability before use
- Provides fallbacks when possible
- Clear error messages for missing requirements

## Integration Architecture

```
Commands → cohesion-utils.sh → State Files
   ↓              ↓               ↓
Hooks → cohesion-docs.sh → Documentation
   ↓              ↓               ↓
Events → workflow.sh → Auto-Generation
```

## Development Guidelines

When modifying utilities:

1. **Backward Compatibility** - Don't break existing command/hook interfaces
2. **Error Checking** - Validate inputs and handle edge cases
3. **Documentation** - Update function comments and this README
4. **Testing** - Verify changes work across supported platforms

---

*Utilities form the stable foundation that enables Cohesion's consistent behavior across all environments.*