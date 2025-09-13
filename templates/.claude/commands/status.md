---
description: "Show comprehensive Cohesion state and session information"
allowed-tools: Bash(*:*)
---

## Current Status

!`.claude/commands/status`

# 📊 Cohesion Status Check

Display current mode, session context, and system state.

Run the status check to see:

- **Current Mode:** DISCOVER/OPTIMIZE/UNLEASH
- **Session Information:** Duration, ID, focus area
- **Recent Commands:** Command history and context
- **Approved Files:** Files available for editing (OPTIMIZE mode)
- **Git Status:** Uncommitted changes and recent activity
- **Documentation:** Active execution plans and decision records

## Status Information

Check `.claude/state/` directory for current mode indicators:
- `DISCOVER` file = Analysis mode active
- `OPTIMIZE` file = Collaborative mode active  
- `UNLEASH` file = Autonomous mode active

## Troubleshooting

If status shows unexpected results:
1. Check for multiple mode files in `.claude/state/`
2. Verify hooks are executing properly
3. Review session context in `.claude/state/.session_context`
4. Run `/reset` to clear corrupted state

---

*Use `/status` regularly to maintain awareness of your development context.*