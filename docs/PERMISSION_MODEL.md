# Cohesion Permission Model

## Overview

Cohesion uses a **hook-driven permission system** that leverages Claude Code's PreToolUse hook capability to override the default permission system. This provides dynamic, mode-based access control without maintaining exhaustive tool lists.

## Architecture

### 1. Minimal Base Permissions (settings.json)

```json
{
  "permissions": {
    "allow": ["Read"],  // Minimal fallback if hooks fail
    "deny": [
      "Bash(rm -rf /)",
      "Bash(sudo rm -rf *)",
      "Bash(:(){ :|:& };:)"  // Fork bomb
    ]
  }
}
```

**Purpose**: 
- `allow: ["Read"]` ensures Claude can read files if hooks fail
- `deny` list blocks catastrophic operations that should NEVER run

### 2. Hook as Permission Controller

The `pre-tool-use.sh` hook returns JSON decisions that **bypass Claude Code's permission system entirely**:

```json
{"decision": "approve"}  // Bypasses permission checks, allows tool
{"decision": "block", "reason": "..."}  // Prevents tool execution
```

### 3. Mode-Based Tool Control

#### DISCOVER Mode (Read-Only)
**Approved Tools**: `Read, NotebookRead, LS, Grep, Glob, WebSearch, WebFetch, TodoRead`
**Blocked**: All write/edit/execute operations
**Message**: "Focusing on understanding and analysis"

#### OPTIMIZE Mode (Collaborative)
**Auto-Approved**: All DISCOVER tools + `TodoWrite`
**Requires Approval**: `Write, Edit, MultiEdit, NotebookEdit, Bash, Agent`
**Process**: Files must be approved via `/approve <file>` before editing

#### UNLEASH Mode (Full Autonomy)
**Approved**: Everything except protected paths
**Protection**: Checks `~/.cohesion/protected.conf` and `./.claude/protected.conf`

## Key Benefits

1. **Future-Proof**: New Claude Code tools automatically work (no list maintenance)
2. **Single Source of Truth**: All permission logic in hooks
3. **Dynamic Control**: Permissions change based on mode without config changes
4. **Fail-Safe**: Minimal Read permission ensures basic functionality if hooks fail

## How It Works

1. Claude Code attempts to use a tool
2. PreToolUse hook intercepts the request
3. Hook checks:
   - Current mode (DISCOVER/OPTIMIZE/UNLEASH)
   - Protected paths (if applicable)
   - Approved files (in OPTIMIZE mode)
4. Hook returns decision:
   - `approve` → Tool runs (bypasses permission system)
   - `block` → Tool blocked with reason shown to Claude

## Protected Paths

Protected paths are checked in ALL modes:
- Global: `~/.cohesion/protected.conf`
- Project: `./.claude/protected.conf`

Patterns are regex-based:
```
\.env$
\.env\..*
/secrets/
/credentials/
\.pem$
\.key$
```

## Migration from Old Model

### Old Model (Problems)
- Required exhaustive allow lists
- Broke when new tools added
- Mixed permission logic between settings.json and hooks
- No wildcard support

### New Model (Solutions)
- Minimal allow list (just "Read")
- Hook decisions override everything
- All logic centralized in hooks
- Automatically supports new tools

## Testing the System

```bash
# Check current mode
cohesion status

# Test in DISCOVER (should block writes)
echo "test" > test.txt  # Should be blocked

# Switch to UNLEASH
# Now same command works

# Test protected paths
echo "secret" > .env  # Should be blocked even in UNLEASH
```

## Debugging

Hook decisions are logged to:
- `.claude/state/.hook_debug` - All hook inputs/outputs
- `.claude/state/.tool_usage` - Tool usage history

To see why something was blocked:
```bash
tail -f .claude/state/.hook_debug
```

## Important Notes

1. **Hooks must return valid JSON** - Invalid output defaults to deny
2. **Protected paths apply to ALL modes** - Even UNLEASH respects them
3. **Unknown tools default to block** - Safety first for new/unrecognized tools
4. **Mode messages reinforce goals** - Don't suggest mode changes, explain current mode's purpose