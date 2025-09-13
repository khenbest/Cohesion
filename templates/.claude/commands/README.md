# .claude/commands/ Directory

This directory contains the Markdown command definitions that implement Cohesion's slash commands.

## Command Files

### Core Mode Commands
- `discover.md` - `/discover [focus]` - Enter analysis mode (read-only)
- `optimize.md` - `/optimize [goal]` - Enter collaborative mode (with approvals)
- `unleash.md` - `/unleash [task]` - Enter autonomous mode (full access)
- `reset.md` - `/reset [reason]` - Return to DISCOVER mode with fresh start

### Utility Commands
- `status.md` - `/status` - Show comprehensive system state
- `approve.md` - `/approve [file_pattern]` - Approve files for editing (OPTIMIZE only)
  - `/approve` - Show current approvals
  - `/approve all` - Approve all project files
  - `/approve [pattern]` - Approve specific files/patterns
- `help.md` - `/help [command]` - Show command documentation

## Dependencies

### Claude Code Integration
Commands are executed by Claude Code's slash command system:
- Command files are Markdown (.md) format
- Frontmatter defines tools and description
- Content provides context and instructions
- Arguments available via `$ARGUMENTS` variable

### Hook Integration
Commands work with Cohesion hooks for:
- Mode state management via `.claude/state/` files
- Session persistence and context tracking
- Documentation workflow triggers

## Execution Order

### Automatic Execution
1. `pre-tool-use.sh` (hook) - Initialize session context
2. User commands (discover, optimize, unleash, etc.)
3. `pre-tool-use.sh` (hook) - Save session state

### Interactive Execution
- Commands can be run independently via Claude Code slash commands
- Each command handles mode transitions and state management
- Context and history preserved across command invocations

## Command Structure

All commands follow consistent Markdown format:
- Frontmatter with description and tools
- Clear heading and purpose statement
- Argument handling with `$ARGUMENTS`
- Next steps and guidance
- Canon principle reference

## Integration with State System

Commands work with the hook system to:
- Update mode indicator files in `.claude/state/`
- Maintain session context and history
- Trigger documentation generation
- Enforce Canon compliance

## Integration Points

Commands integrate with:
- **Claude Code**: Native slash command execution
- **Hook System**: Session lifecycle management
- **State Management**: Mode persistence and context tracking
- **Documentation System**: Auto-generation of project docs

---

*All commands follow Cohesion Canon principles and maintain consistency with the DUO protocol.*