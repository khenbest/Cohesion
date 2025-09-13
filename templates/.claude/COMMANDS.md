# Cohesion Commands Reference

Complete documentation for all Cohesion slash commands.

## Core Mode Commands

### `/discover`
Switch to DISCOVER mode for read-only analysis and planning.
- **Effect**: Enables read-only tools (Read, Grep, Glob)
- **Restrictions**: No file modifications allowed
- **Use case**: Understanding code, planning changes

### `/optimize`
Switch to OPTIMIZE mode for collaborative editing with approvals.
- **Effect**: Enables editing with per-file approval requirement
- **Restrictions**: Must approve each file before editing
- **Use case**: Careful, controlled changes with oversight

### `/unleash`
Switch to UNLEASH mode for full autonomous development.
- **Effect**: All tools available without restrictions
- **Restrictions**: None
- **Use case**: Trusted tasks requiring speed and autonomy

## Status Commands

### `/status`
Display current Cohesion mode and session information.
- **Shows**: Current mode, session ID, approved files
- **Use case**: Check your current working context

### `/help`
Show available commands and their descriptions.
- **Shows**: List of all commands with brief descriptions
- **Use case**: Quick reference for available commands

## Approval Commands (OPTIMIZE Mode)

### `/approve <filename>`
Approve a specific file for editing in OPTIMIZE mode.
- **Example**: `/approve src/main.js`
- **Effect**: Adds file to approved list for current session

### `/approve`
Show all currently approved files.
- **Shows**: List of files approved for editing
- **Use case**: Review what files you can edit

## Session Commands

### `/reset`
Reset Cohesion state and clear session context.
- **Effect**: Clears state files and starts fresh
- **Use case**: Recover from corrupted state

## Command Arguments

Commands that accept arguments use the `$ARGUMENTS` variable:
- `/approve $ARGUMENTS` - The filename to approve
- Custom commands can access arguments as `$1`, `$2`, etc.

## Creating Custom Commands

Add new commands by creating Markdown files in `.claude/commands/`:

```markdown
---
description: "Brief description of what this command does"
tools: ["Read", "Write", "Bash"]
---

# My Custom Command

Your command instructions and context here.

Arguments provided: $ARGUMENTS

Perform the desired actions...
```

Save as:
```bash
# Create the command file
echo "Your command content..." > .claude/commands/mycommand.md
```

Then use it:
```
/mycommand
```

## Tips

1. **Mode Persistence**: Your mode persists across sessions
2. **Tab Completion**: Command names support tab completion
3. **Error Recovery**: If a command fails, check `/status`
4. **Batch Operations**: In UNLEASH mode, batch similar operations for efficiency

## Troubleshooting

**Command not found?**
- Check if the command file exists in `.claude/commands/`
- Ensure the file has `.md` extension

**Mode not changing?**
- Check for errors in the command output
- Run `/doctor` to diagnose issues

**Approvals not working?**
- Ensure you're in OPTIMIZE mode first
- Use full relative paths for files