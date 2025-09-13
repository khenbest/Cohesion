# Quick Start Guide

## 2-Minute Setup

```bash
# Install globally
git clone https://github.com/khenbest/Cohesion && cd Cohesion && ./install.sh

# Initialize in your project
cd ~/your-project
cohesion init

# Start Claude Code
claude
```

## How Cohesion Works

### Slash Commands Control Everything

Cohesion uses **slash commands** to switch between three intelligent modes:

- `/discover` - Analysis and planning (read-only)
- `/optimize` - Collaborative editing (requires approvals)
- `/unleash` - Full autonomy (unrestricted access)

### The Three Modes

1. **DISCOVER** 🔍 (Default)
   - Read-only access
   - Claude analyzes and plans
   - Cannot modify files
   - Perfect for understanding before building

2. **UNLEASH** ⚡ 
   - Full access granted
   - Use `/unleash` to activate
   - Claude executes plans autonomously
   - Maximum efficiency for trusted tasks

3. **OPTIMIZE** ✨
   - Collaboration mode
   - Use `/optimize` to activate
   - Requires `/approve <file>` before edits
   - Balance between safety and productivity

### Basic Workflow

```
You: Fix the authentication bug

Claude: [DISCOVER] Let me analyze the authentication system...
        Found issue in auth.js line 47
        The token validation is missing expiry check
        
        Plan: Add expiry validation to JWT tokens
        Ready to implement when you give me access
        
You: /unleash

Claude: [UNLEASH] ⚡ Switching to full autonomy mode
        Executing the authentication fix...
        ✓ Updated auth.js with expiry validation
        ✓ Added tests for token expiration
        ✓ All tests passing

You: /discover

Claude: [DISCOVER] 🔍 Switching back to analysis mode
        What would you like to explore next?
```

### Collaborative Workflow (OPTIMIZE)

```
You: /optimize

Claude: [OPTIMIZE] ✨ Collaborative mode active
        I'll need your approval for each file I edit
        
You: Update the login component styling

Claude: [OPTIMIZE] I need to edit Login.jsx for styling
        Would you like to approve this?
        
You: /approve Login.jsx

Claude: [OPTIMIZE] ✓ Login.jsx approved for editing
        Updating the component styling...
        ✓ Applied new design system
```

## Essential Commands

### In Claude Code
- `/discover` - Switch to analysis mode
- `/optimize` - Switch to collaborative mode
- `/unleash` - Switch to autonomous mode
- `/status` - Check current mode and session
- `/help` - Show all available commands
- `/approve <file>` - Approve file for editing (OPTIMIZE mode)

### In Terminal
- `cohesion init` - Set up in project
- `cohesion status` - Check installation
- `cohesion doctor` - Diagnose issues
- `cohesion upgrade` - Update Cohesion

## Why Cohesion?

### The 10x Productivity Gain

**Without Cohesion:**
- Jump to code → 10x debugging time
- Assumptions → Complete rewrites
- Missed edge cases → Production failures

**With Cohesion:**
- Think first → Build right the first time
- Test assumptions → Avoid dead ends
- Canon enforcement → Robust solutions

### Session Persistence

Your mode and context persist across Claude Code sessions. When you return:
- Same mode active
- Approved files remembered (OPTIMIZE)
- Session context restored
- Continue exactly where you left off

## The Canon Principles

Cohesion enforces six principles automatically:

1. **Think-First** - Analysis before action saves 10x debugging
2. **Always-Works** - Every change maintains functionality
3. **Reality-Check** - Validate assumptions continuously
4. **Approval-Criteria** - Respect boundaries in each mode
5. **Naming-Conventions** - Clear, self-documenting code

## Next Steps

1. Try each mode: `/discover`, `/optimize`, `/unleash`
2. Check your status: `/status`
3. Read the [Canon principles](cohesion-methodologies/README.md)
4. Explore [advanced workflows](MODE-TRANSITIONS.md)

---

**Remember:** Cohesion adapts to YOUR workflow. Start in DISCOVER to understand, switch to UNLEASH to build, use OPTIMIZE when you want oversight.