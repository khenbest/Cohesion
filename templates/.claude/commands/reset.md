---
description: "Return to DISCOVER mode with fresh perspective"
---

```bash
# Source utilities and transition to DISCOVER mode
if [ -f "$PWD/.claude/utils/cohesion-utils.sh" ]; then
    source "$PWD/.claude/utils/cohesion-utils.sh"
    transition_to_mode "DISCOVER"
    echo "🔄 RESET TO DISCOVER MODE"
elif [ -f "$HOME/.cohesion/utils/cohesion-utils.sh" ]; then
    source "$HOME/.cohesion/utils/cohesion-utils.sh"
    transition_to_mode "DISCOVER"
    echo "🔄 RESET TO DISCOVER MODE"
else
    echo "❌ ERROR: cohesion-utils.sh not found"
    exit 1
fi
```

# 🔄 Fresh Start - Reset to DISCOVER

Save current progress and return to analysis mode for a new perspective.

**Reset Reason:** $ARGUMENTS

## What Reset Does

1. **Save Progress** - Current session state preserved as snapshot
2. **Clear Context** - Remove approved files and reset session focus  
3. **Return to DISCOVER** - Switch back to analysis mode
4. **Preserve History** - Command history and decisions maintained

## When to Reset

- Current approach isn't working effectively
- Need fresh perspective on the problem
- Want to step back and reconsider fundamentals
- Switching to different task or focus area

## What Gets Preserved

- **Session Snapshots** - Saved in `.claude/state/reset_snapshots/`
- **Command History** - Previous commands and context maintained
- **Documentation** - Progress and decisions remain in docs
- **Git State** - Your code changes are unaffected

## Next Steps

After reset, you'll be in DISCOVER mode:
1. **Analyze** the situation with fresh eyes
2. **Review** what was learned from previous attempt
3. **Plan** a new approach based on insights gained
4. **Use** `/unleash` or `/optimize` when ready to proceed

---

*Sometimes the best progress comes from stepping back and thinking differently.*