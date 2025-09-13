# Cohesion Configuration Hierarchy

## How Claude Code Merges Settings

Claude Code follows a strict precedence order when merging configuration from multiple sources:

```
1. Runtime /config commands (highest priority)
   ↓
2. Project .claude/settings.local.json
   ↓
3. Project .claude/settings.json
   ↓
4. Global ~/.claude/settings.json (lowest priority)
```

## Verification Commands

In Claude Code, verify your effective configuration:

```bash
/permissions          # Shows all active permissions and their source
/config get          # Shows current runtime configuration
/config reload       # Reloads settings from disk
```

## State Management

Cohesion v1.0.0 uses a unified settings approach with runtime state tracking:

**Settings Files:**
- `.claude/settings.json` - Base project settings (all modes)
- `.claude/settings.local.json` - User customizations (if needed)

**State Tracking:**
- `.claude/state/DISCOVER` - Discovery mode active marker
- `.claude/state/OPTIMIZE` - Optimize mode active marker  
- `.claude/state/UNLEASH` - Unleash mode active marker
- `.claude/state/.approved_edits` - OPTIMIZE approved files list
- `.claude/state/.canon_active` - Canon V1 enforcement enabled

These don't interfere with Claude Code's native settings.

### DISCOVER Mode (Default)
```json
{
  "permissions": {
    "defaultMode": "ask",
    "allow": ["Read(./**)", "Glob(./**)", "Grep(./**)"],
    "deny": ["Edit(./**)", "Write(./**)", "Bash(*)"]
  }
}
```

### OPTIMIZE Mode
```json
{
  "permissions": {
    "defaultMode": "ask",
    "allow": ["Read(./**)", "Edit(./**) with approval"],
    "deny": ["Bash(rm*)", "Write(./secrets/**)"]
  }
}
```

### UNLEASH Mode
```json
{
  "permissions": {
    "defaultMode": "acceptEdits",  // ← KEY: This enables autonomy
    "allow": ["Edit(./**)", "Write(./**)", "Bash(*)"],
    "deny": ["Read(./.env)", "Bash(rm -rf /)"]  // Still protected
  }
}
```

## Key Settings Explained

### `permissions.defaultMode`
- `"ask"` - Claude prompts for each tool use (default)
- `"acceptEdits"` - Claude executes without prompting (UNLEASH)
- `"reject"` - Claude blocks all tools (lockdown)

### `permissions.allow` / `permissions.deny`
- Patterns use glob syntax: `Edit(./**)`, `Bash(npm *)`
- Deny rules ALWAYS override allow rules
- More specific patterns override general ones

### Protected Paths (via hooks)
Even when settings allow, hooks enforce additional protection:
- `.git/` directories
- `.env` files
- `node_modules/`
- System directories

## Testing Your Configuration

After changing states, verify:

1. **Check active permissions:**
   ```
   /permissions
   ```
   Look for "Sourced from: [filename]" to verify precedence

2. **Test a safe edit:**
   ```
   /edit test.txt
   ```
   - DISCOVER: Should be blocked
   - OPTIMIZE: Should require approval
   - UNLEASH: Should execute immediately

3. **Verify dangerous commands are blocked:**
   ```
   /bash rm -rf /
   ```
   Should ALWAYS be blocked by deny rules

## Troubleshooting

### "Permissions not updating"
- Run `/config reload` in Claude Code
- Check for `.claude/settings.local.json` overriding global
- Verify state file exists: `.claude/state/UNLEASHED`

### "UNLEASH not autonomous"
- Ensure `defaultMode: "acceptEdits"` is set
- Check that settings.unleash.json was copied to settings.local.json
- Run `/config set permissions.defaultMode acceptEdits` manually

### "Unexpected denials"
- Check deny rules with `/permissions`
- Look for project-specific overrides
- Verify hooks aren't adding extra restrictions

## Configuration Sources

- **Global**: `~/.claude/settings.json` (all projects)
- **Project**: `.claude/settings.json` (this project)
- **Local**: `.claude/settings.local.json` (this machine only)
- **Runtime**: `/config set` commands (this session only)

Remember: More specific settings override general ones, and deny always wins over allow.