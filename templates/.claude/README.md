# .claude Directory Structure

This directory contains the Cohesion framework configuration for Claude Code.

## Directory Layout

```
.claude/
├── commands/         # Slash command implementations
├── hooks/           # Event hooks for Claude Code integration
├── utils/           # Shared utilities and helper functions
├── cohesion-canon/  # The six behavioral principles
├── state/           # Runtime state (gitignored)
├── canon-cache.md   # Optimized canon reference
├── settings.json    # Claude Code configuration
└── COMMANDS.md      # Command reference documentation
```

## Components

### commands/
Contains executable scripts for slash commands:
- `/discover` - Switch to analysis mode
- `/optimize` - Switch to collaborative mode
- `/unleash` - Switch to autonomous mode
- `/status` - Check current state
- `/approve` - Approve files for editing
- `/help` - Show available commands

### hooks/
Single event handler that integrates with Claude Code:
- `pre-tool-use.sh` - **Single hook architecture** - handles session initialization, context restoration, mode transitions, tool restrictions, and state persistence

### utils/
Core functionality:
- `cohesion-utils.sh` - All utility functions for mode management, state persistence, and session handling

### cohesion-canon/
The six principles that guide behavior:
1. Think-First - Analysis before action
2. Always-Works - Maintain functionality
3. Reality-Check - Validate assumptions
4. Approval-Criteria - Respect boundaries
5. Naming-Conventions - Clear identifiers

### state/
Runtime state (automatically managed, gitignored):
- Mode indicator files (DISCOVER/OPTIMIZE/UNLEASH)
- Session context and persistence
- Command history
- Approved files list

## How It Works

1. **Slash Commands** - User types `/discover`, `/optimize`, or `/unleash`
2. **Command Execution** - Claude Code runs the corresponding script
3. **State Transition** - Script updates state files
4. **Hook Enhancement** - Hooks add context to every interaction
5. **Mode Enforcement** - pre-tool-use.sh restricts tools based on mode

## Configuration

The `settings.json` file configures:
- Permission mode (`defaultMode: "default"`)
- Hook registrations for Claude Code events
- Tool restrictions and allowances

## Session Persistence

Your session survives Claude Code restarts:
- Mode persists via state files
- Context saved in `.session_context`
- Command history maintained
- Approved files remembered

## Troubleshooting

**Commands not working?**
- Check command files exist as `.md` files in commands/
- Verify hooks are registered in settings.json

**State issues?**
- Only one mode file should exist in state/
- Check `.session_context` for corruption

**Hook problems?**
- Ensure cohesion-utils.sh is accessible
- Check hook output in Claude Code logs

---

*Managed by Cohesion Framework - Intelligent Development System*