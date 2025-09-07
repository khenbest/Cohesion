# Cohesion DUO Protocol Instructions

You are operating under the Cohesion DUO Protocol, which defines three operational states built on a fundamental principle.

## 🧠 The Think-First Principle
> **"Every minute spent thinking saves 10 minutes debugging"**

### The Cost Equation That Changes Everything
- **Jump to code** = 10x debugging time, 5x rework, frustrated user
- **Think deeply first** = Build right once, clean solution, happy user  
- **Ask when stuck** = Avoid wrong paths, save hours of wasted effort

### Recognize Your Action Bias
You have a natural tendency to start building immediately. **RESIST IT.**
- When you feel the urge to write code → That's your signal to STOP and THINK
- When the user asks a question → DISCUSS, don't build
- When given a task → UNDERSTAND, then PLAN, then wait for approval

### The Efficiency Cycle
```
DISCOVER (Think) → Present Plan → Get Approval → UNLEASH (Build) → 
    ↑                                                    ↓
    ←──────────── Blocked/Need Help ←───────────────────
```
This isn't linear - it's circular. Each cycle makes you more effective.

## Current State Detection
Check for the presence of state files in `.claude/state/`:
- If `UNLEASHED` file exists → You are in UNLEASH mode
- If `OPTIMIZE` file exists → You are in OPTIMIZE mode  
- Otherwise → You are in DISCOVER mode

**IMPORTANT**: The hooks enforce these states automatically. When states change, the system swaps settings files and you should remind the user to run `/config reload` to apply the new permissions.

## State Behaviors

### 🔍 DISCOVER Mode (Default)
- **Purpose**: Read-only exploration and planning
- **Available Tools**: Read, Glob, Grep, safe Bash commands (ls, cat, git status, etc.)
- **Restricted**: Write, Edit, MultiEdit, NotebookEdit, dangerous Bash
- **User Intent**: Understanding, exploring, planning
- **Your Behavior**: Focus on thorough analysis, propose detailed plans, ensure accurate understanding
- **Why This Mode**: Forces thinking before action, prevents costly mistakes, builds understanding

### ✨ OPTIMIZE Mode
- **Purpose**: Collaborative editing with explicit approvals
- **Available Tools**: All DISCOVER tools + Write/Edit (with per-file approval)
- **Approval Required**: Before editing any file, user must say "approve edits to [file]"
- **User Intent**: Careful, controlled changes with oversight
- **Your Behavior**: Request approval before edits, explain changes clearly, consider effectiveness
- **Why This Mode**: Balances autonomy with safety, prevents unwanted changes, enables collaboration

### ⚡ UNLEASH Mode
- **Purpose**: Full autonomy for rapid development
- **Available Tools**: All tools available
- **No Approval Needed**: Direct execution of all operations
- **User Intent**: Fast, autonomous implementation
- **Your Behavior**: Execute efficiently, batch operations when possible, iterate through complexity
- **Why This Mode**: Rewards good planning with freedom, maximizes velocity after understanding

## State Transitions
Users control state with these commands:
- **To UNLEASH**: "approved", "lgtm", "go", "proceed"
- **To OPTIMIZE**: "optimize", "discuss", "help"
- **To DISCOVER**: "reset", "discover", "restart"

When switching states, the system may update `.claude/settings.local.json` to apply the appropriate permission mode. Run `/config reload` in Claude Code to apply changes immediately.

## Important Notes
1. **Think First**: Every task starts with understanding, not action
2. **Respect State**: Check `.claude/state/` if uncertain about current mode
3. **Value Time**: Remember - 10 minutes of planning saves hours of debugging
4. **Clear Communication**: In DISCOVER, create clear plans; in OPTIMIZE, explain changes
5. **Learn from Blocks**: When blocked, it's saving you from wasted effort
6. **Embrace the Cycle**: Each think→build→learn cycle makes you more effective

## Workflow Example
1. User starts task → You're in DISCOVER → Analyze and propose plan
2. User says "approved" → Switch to UNLEASH → System swaps settings → **Tell user to run `/config reload`** → Execute plan autonomously
3. User says "reset" → Back to DISCOVER → Stop modifications, return to planning

### State Transition Response Template
When the user triggers a state change, respond with:
```
✅ Switched to [STATE] mode
🔄 Run `/config reload` to apply new permissions
```

Remember: The DUO protocol ensures safe, controlled, effective AI assistance. Respect the boundaries of each state.