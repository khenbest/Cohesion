# /save Command - Session Context Bridge

## Overview

The `/save` command transforms session endpoints into documentation events that feed Cohesion's living memory system. Instead of losing valuable context between AI sessions, `/save` actively maintains project continuity by updating documentation and preserving session state.

## Core Philosophy

**Problem Solved**: AI sessions create valuable thinking and context that evaporates between conversations, breaking project continuity and losing institutional knowledge.

**Solution**: Every `/save` creates a permanent artifact in the project's documentation system, ensuring no session is ever truly "lost."

## Command Syntax

### Basic Session Save
```
/save [optional context message]
```

**Examples:**
- `/save`
- `/save "Fixed authentication bug, ready to test"`
- `/save "Analysis complete, moving to implementation phase"`

### Milestone Save (Phase 2)
```
/save --milestone "Description of major accomplishment"
```

**Examples:**
- `/save --milestone "Authentication system fully implemented"`
- `/save --milestone "Performance optimization complete - 50% improvement"`

## What Happens When You /save

### Session Save (Current Implementation)

**1. Session Metadata Capture**

Creates `.claude/state/sessions/YYYYMMDD-HHMMSS.json`:
```json
{
  "save_id": "20250912-143000",
  "type": "session", 
  "timestamp": "2025-09-12T14:30:00Z",
  "context": "Your context message",
  "session": {
    "duration_minutes": 45,
    "final_mode": "DISCOVER",
    "files_modified": "src/main.js,README.md",
    "approved_files": "src/auth.js,src/utils.js"
  }
}
```

**2. STATE.md Update**

Updates the "Current Focus" section with your context:
```markdown
## Current Focus

Focus: Fixed authentication bug, ready to test
```

**3. Daily Activity Log**

Appends to `docs/04-progress/daily-YYYY-MM-DD.md`:
```markdown
### Session Save - 14:30
- **Mode**: DISCOVER
- **Duration**: 45 minutes  
- **Context**: Fixed authentication bug, ready to test
- **Files modified**: src/main.js,README.md
```

**4. Mode Preservation**

- Current mode (DISCOVER/OPTIMIZE/UNLEASH) maintained
- In OPTIMIZE mode: Approved files list preserved
- Session context prepared for next AI interaction

## Integration with Cohesion Modes

### DISCOVER Mode
- **Focus**: Captures thinking and analysis progress
- **Typical saves**: "Completed requirements analysis", "Identified 3 design approaches"
- No file approvals to preserve

### OPTIMIZE Mode  
- **Focus**: Collaborative checkpoint with approval context
- **Typical saves**: "Updated authentication module", "Fixed validation logic"
- **Preserves**: List of approved files for next session

### UNLEASH Mode
- **Focus**: Implementation milestone capture
- **Typical saves**: "Feature complete and tested", "Refactoring finished"
- Full autonomy maintained across sessions

## Git Integration

The command automatically detects:
- Modified files since last git commit
- Working directory state for context
- Change scope for documentation purposes

**Note**: No git commits are created - `/save` is purely for documentation.

## When to Use /save

### Session Checkpoints ("I'm done for now")
- `/save "Good stopping point - auth system designed"`
- `/save "Bug investigation complete, found root cause"`
- `/save` (simple checkpoint, no context)

### Context Handoffs ("Setting up tomorrow's work")
- `/save "Ready to implement user registration flow"`
- `/save "Tests passing, need to add error handling next"`
- `/save "Design approved, moving to implementation"`

### Problem Resolution Points
- `/save "Fixed the database connection issue"`
- `/save "Performance optimization complete - 50% improvement"`
- `/save "Security audit addressed all findings"`

## What /save Does NOT Do

- ❌ **No git commits** - Purely documentation focused
- ❌ **No file modifications** - Only updates documentation
- ❌ **No mode changes** - Preserves current working mode
- ❌ **No destructive operations** - Always additive

## File Structure Created

```
project/
├── STATE.md                          # Always updated
├── docs/04-progress/
│   └── daily-2025-09-12.md          # Session log
└── .claude/state/
    ├── sessions/
    │   ├── 20250912-143000.json     # Session metadata
    │   └── 20250912-151500.json     # Next session
    └── .last_save -> sessions/20250912-151500.json  # Symlink
```

## Error Handling

The command gracefully handles:
- **Missing directories** - Creates `docs/04-progress/` automatically
- **No git repository** - Works without git integration
- **Permission issues** - Fails safely with clear error messages
- **Concurrent saves** - Unique timestamps prevent conflicts

## Performance

- **Session saves**: < 5 seconds typical execution
- **File system impact**: Minimal - only creates small text files
- **Memory usage**: Negligible - pure shell script execution
- **Storage growth**: ~1KB per save session

## Privacy & Security

- **Local only** - No external services called
- **Plain text storage** - Easy to inspect and modify
- **Git-ignored paths** - Session metadata not committed
- **No sensitive data capture** - Only file names and timestamps

## Advanced Usage Patterns

### Daily Workflow Integration
```
# Morning startup
/save "Starting work on user authentication"

# Mid-session checkpoints
/save "Login form complete, testing validation"

# End of day
/save "Day complete - auth 80% done, API integration tomorrow"
```

### Problem-Solving Sessions
```
# Investigation phase
/save "Bug reproduced, investigating database queries"

# Root cause found  
/save "Found issue in connection pooling, planning fix"

# Resolution
/save "Bug fixed and tested, monitoring for 24h"
```

### Collaboration Handoffs
```
# Before team meeting
/save "Prepared demo of new dashboard features"

# After code review
/save "Addressed all review feedback, ready to merge"
```

## Best Practices

### 1. Use Descriptive Context
**Good**: `/save "Database migration complete, all tests passing"`
**Less helpful**: `/save "Done with DB stuff"`

### 2. Save at Natural Breakpoints
- End of analysis phases
- After completing features  
- Before switching contexts
- When handing off to others

### 3. Include Next Steps
`/save "User service complete - next: implement admin panel"`

### 4. Be Consistent
- Use similar language patterns
- Save regularly during long sessions
- Include blockers or concerns

## Future Enhancements (Phase 2)

### Milestone Saves
- Full Close-the-Loop analysis
- DETAILED_EXECUTION_PLAN.md updates
- ADR template generation
- Documentation gap detection

### Canon Metrics
- Think-First ratio calculation
- Always-Works compliance scoring
- Reality-Check event tracking

### Advanced Integration
- Automatic triggers on mode transitions
- Pre-commit hook integration
- Learning corpus generation

---

The `/save` command transforms the ephemeral nature of AI sessions into permanent project memory, ensuring that every moment of thinking contributes to the project's growing intelligence.