# Mode Transitions Guide

## Overview

Cohesion uses **slash commands** for reliable, deterministic mode control. No pattern matching, no NLP - just direct commands that always work.

## Core Principle

> **Slash commands provide explicit, reliable control over Cohesion modes**

When you type `/unleash`, it always switches to UNLEASH mode. No ambiguity, no context interpretation - just reliable execution.

## Transition Matrix

### 🔍 DISCOVER → Other Modes

| Command | Destination | Effect |
|---------|------------|--------|
| `/unleash` | UNLEASH | Switch to autonomous mode for building |
| `/optimize` | OPTIMIZE | Switch to collaborative mode with approvals |
| `/discover` | DISCOVER | Stay in analysis mode (no-op) |

### ⚡ UNLEASH → Other Modes

| Command | Destination | Effect |
|---------|------------|--------|
| `/discover` | DISCOVER | Return to analysis mode |
| `/optimize` | OPTIMIZE | Switch to collaborative mode |
| `/unleash` | UNLEASH | Stay in autonomous mode (no-op) |

### ✨ OPTIMIZE → Other Modes

| Command | Destination | Effect |
|---------|------------|--------|
| `/unleash` | UNLEASH | Switch to autonomous mode |
| `/discover` | DISCOVER | Return to analysis mode |
| `/optimize` | OPTIMIZE | Stay in collaborative mode (no-op) |

## Command Usage

### Basic Commands

```bash
/discover           # Switch to analysis mode
/optimize          # Switch to collaborative mode
/unleash           # Switch to autonomous mode
/status            # Check current mode
/help              # Show available commands
```

### With Context

Commands accept optional arguments for focus:

```bash
/discover authentication    # Analyze auth system
/optimize database layer    # Collaborate on DB
/unleash implement cache    # Build caching autonomously
```

### File Approval (OPTIMIZE mode)

```bash
/approve src/index.js      # Approve single file
/approve src/*.js          # Approve pattern
/list-approvals           # Show approved files
/clear-approvals          # Reset approvals
```

## Examples

### Example 1: Feature Development

```
You: /discover user authentication
Claude: 🔍 DISCOVER mode active - Analyzing authentication
        [Explores existing auth implementation]

You: /unleash
Claude: ⚡ UNLEASH mode active - Full autonomy granted
        [Implements authentication improvements]

You: /discover
Claude: 🔍 DISCOVER mode active - Returning to analysis
        [Reviews what was built]
```

### Example 2: Collaborative Refactoring

```
You: /optimize
Claude: ✨ OPTIMIZE mode active - Collaborative editing
        Need approval for each file I edit

You: Refactor the user service
Claude: I'll need to edit UserService.js

You: /approve UserService.js
Claude: ✓ UserService.js approved for editing
        [Makes improvements with oversight]
```

### Example 3: Quick Bug Fix

```
You: /unleash fix the login timeout
Claude: ⚡ UNLEASH mode active - Fixing login timeout
        [Identifies and fixes the bug autonomously]
        ✓ Fixed timeout issue in auth.js
        ✓ Added test coverage
```

## Session Continuity

The system maintains context across transitions:

1. **Pattern Recognition**: Good patterns like "Think→Plan→Approve→Build" are tracked
2. **State Preservation**: Progress is saved when switching modes
3. **Context Restoration**: Previous work informs new mode behavior

## Best Practices

1. **Use slash commands explicitly** - `/unleash` not "unleash" or "go"
2. **Start with /status** - Know your current mode
3. **Add context to commands** - `/discover authentication` is better than just `/discover`
4. **Clear approvals regularly** - Keep OPTIMIZE mode clean with `/clear-approvals`

## Advanced Features

### Session Persistence

Your mode and context persist across Claude Code sessions:

```
Previous session: /unleash implement user API
[Claude Code restarts]
New session: Mode restored to UNLEASH
             Context: "implement user API"
```

### State Files

Mode is controlled by state files in `.claude/state/`:
- `DISCOVER` file → DISCOVER mode
- `OPTIMIZE` file → OPTIMIZE mode  
- `UNLEASH` file → UNLEASH mode
- `.approved_edits` → Approved files list
- `.session_context` → Session persistence

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Command not found" | Ensure `.claude/commands/` exists and scripts are executable |
| "Mode didn't change" | Check state files: `ls .claude/state/` - only one should exist |
| "Lost context" | Check `.claude/state/.session_context` for saved state |
| "Approvals not working" | Must be in OPTIMIZE mode first with `/optimize` |

## Summary

Slash commands make Cohesion reliable and predictable:

- **Explicit control** - Commands always do exactly what they say
- **No ambiguity** - `/unleash` always means UNLEASH mode
- **Fast transitions** - Instant mode switches
- **Session persistence** - Your state survives restarts

This creates a deterministic system where you have complete control over how Claude operates.