# Cohesion System Architecture

## Core Philosophy
Cohesion creates a **progressive trust system** for AI-assisted development:
- **DISCOVER** 🔍 - Read-only exploration
- **OPTIMIZE** ✨ - Collaborative editing with per-file approval
- **UNLEASH** ⚡ - Full autonomy

## System Components

### 1. State Management
```
.claude/state/
├── OPTIMIZE          # State marker file (or UNLEASHED, or neither for DISCOVER)
├── approvals.txt     # List of approved file paths
└── .last_transition  # Timestamp of last state change
```

### 2. Hook System
```
.claude/hooks/
├── pre-tool-use.sh   # Gates tool usage based on state
└── user-prompt.sh    # Handles state transitions and approvals
```

### 3. Utilities
```
.claude/utils/
└── hook-utils.sh     # Shared functions and constants
```

## Data Flow

### State Transitions
```
User: "optimize" → user-prompt.sh → set_state("OPTIMIZE") → Creates .claude/state/OPTIMIZE
User: "approved" → user-prompt.sh → set_state("UNLEASH") → Creates .claude/state/UNLEASHED  
User: "reset"    → user-prompt.sh → set_state("DISCOVER") → Removes state files
```

### File Approval Flow (OPTIMIZE mode)
```
1. AI attempts Write("file.txt") → pre-tool-use.sh
2. Check: is_approved_edit("file.txt")? 
   - No → Block with "approve edits to file.txt"
   - Yes → Allow
3. User: "approve edits to file.txt" → user-prompt.sh
4. approve_edit("file.txt") → Adds to .claude/state/approvals.txt
5. Next Write("file.txt") → Allowed
```

## Path Resolution
All paths are canonicalized to absolute paths:
- `./README.md` → `${COHESION_DIR:-$HOME/Cohesion}/README.md`
- `../project/file.txt` → `$HOME/Claude/project/file.txt`
- Ensures consistency between approval and checking

## Safety Mechanisms

### Tool Gating
- **DISCOVER**: Read, Grep, Glob, safe Bash only
- **OPTIMIZE**: Above + Write/Edit (with approval)
- **UNLEASH**: All tools allowed

### Command Safety
- Dangerous commands blocked always (rm -rf, chmod 777, etc.)
- Unsafe commands blocked in DISCOVER/OPTIMIZE
- Safe commands (ls, git status, etc.) always allowed

### Protected Paths
Optional `.claude/protected.conf` can list patterns for files that should never be modified.

## Error Recovery

### Diagnostic Tool
```bash
cohesion doctor   # Check system health
```
Verifies:
- Directory structure
- Current state
- Active approvals
- Hook executability
- Common issues

### Repair Tool
```bash
cohesion repair   # Auto-fix common issues
```
Fixes:
- Duplicate state directories
- Permission issues
- Conflicting states
- Old format migrations

## Key Design Decisions

1. **Single Source of Truth**: State in `.claude/state/` only
2. **Fail-Safe Defaults**: Unknown state = DISCOVER (read-only)
3. **Explicit Approval**: Each file needs individual approval in OPTIMIZE
4. **Path Canonicalization**: Prevents approval bypass via path tricks
5. **Stateless Hooks**: Each hook run is independent
6. **Self-Healing**: Diagnostic and repair tools maintain consistency

## Testing
Comprehensive test suite (`/tmp/test_cohesion_final.sh`) validates:
- All state transitions
- Approval flow
- Path handling
- Command filtering
- State persistence
- Edge cases

## Common Issues & Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| "EDIT NEEDS APPROVAL" after approving | Path mismatch | Check canonicalized paths match |
| State not persisting | Wrong state directory | Run `cohesion repair` |
| Hooks not running | Not executable | `chmod +x .claude/hooks/*.sh` |
| Conflicting states | Manual editing | Run `cohesion repair` |

## Security Model
- **Defense in Depth**: Multiple layers of protection
- **Principle of Least Privilege**: Start restricted, grant incrementally
- **Explicit Authorization**: User must approve specific actions
- **Audit Trail**: All transitions and approvals logged

This architecture ensures Cohesion remains **robust**, **predictable**, and **self-correcting**.
