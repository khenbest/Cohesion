# 🎓 Cohesion Tutorial

> Interactive walkthrough of the Cohesion workflow system

## Introduction

This tutorial will teach you how to use Cohesion effectively through hands-on exercises. By the end, you'll understand:

- How the three-state system works
- When and how to approve Claude's plans  
- How to recover from blocked states
- Best practices for productive sessions

## Prerequisites

- Cohesion installed and verified (see [Installation Guide](INSTALLATION.md))
- Claude Code running
- A test project directory

## Part 1: Understanding States

### Exercise 1.1: Check Initial State

```bash
# In your project directory
cohesion status
```

**Expected output:**
```
🎯 Cohesion Status
State: DISCOVER
Session: active
Duration: 0m
```

Claude starts in **DISCOVER** state - able to read and analyze, but not write.

### Exercise 1.2: Observe State Restrictions

Try asking Claude to create a file:

```
You: "Create a file called test.txt with 'Hello World' inside"
```

**What happens:**
- Claude will analyze your request
- Present a plan for creating the file
- But CANNOT actually create it yet (in DISCOVER state)

### Exercise 1.3: Transition to UNLEASH

Now approve the plan:

```
You: "approved"
```

**What happens:**
- Cohesion detects the approval keyword
- Transitions Claude to UNLEASH state
- Claude can now create the file
- After completion, returns to DISCOVER

Verify the state changed back:
```bash
cohesion status
# Should show: State: DISCOVER
```

## Part 2: The Approval Workflow

### Exercise 2.1: Multi-Step Task

Ask Claude for something more complex:

```
You: "Create a simple web server with Express.js"
```

**Claude's Response Pattern:**
1. Analyzes requirements (DISCOVER)
2. Presents detailed plan
3. Waits for approval
4. You approve → UNLEASH state
5. Executes plan
6. Returns to DISCOVER

### Exercise 2.2: Conditional Approval

You can request changes before approving:

```
You: "Create a REST API for managing todos"

Claude: [Presents plan with database]

You: "Actually, let's use in-memory storage instead of a database"

Claude: [Revises plan]

You: "Perfect, approved"

Claude: [Executes revised plan]
```

### Exercise 2.3: Rejecting Plans

You can reject and request alternatives:

```
You: "No, I don't like that approach. Can you suggest something simpler?"

Claude: [Stays in DISCOVER, provides alternative]
```

## Part 3: Handling Blocked States

### Exercise 3.1: Simulating a Block

```
You: "I'm stuck on this error, help!"
```

**What happens:**
- Cohesion detects distress keywords
- Transitions to OPTIMIZE state
- Claude cannot use tools
- Waits for your guidance

### Exercise 3.2: Providing Help

```
You: "Try adding 'type: module' to package.json"
```

**What happens:**
- Cohesion detects solution pattern
- Transitions back to DISCOVER
- Claude can now analyze your suggestion
- Can request approval to implement

### Exercise 3.3: Manual State Control

```bash
# Check detailed DUO Protocol state
cohesion duo-status

# Verify
cohesion status

# Return to DISCOVER
cohesion discover
```

## Part 4: Advanced Workflows

### Exercise 4.1: Long-Running Tasks

For complex multi-part tasks:

```
You: "Build a complete todo app with frontend and backend"

Claude: [Presents phased plan]
       "Phase 1: Backend API
        Phase 2: Frontend UI
        Phase 3: Integration
        Shall I proceed with Phase 1?"

You: "approved"

[After Phase 1 completes]

Claude: "Phase 1 complete. Ready for Phase 2?"

You: "approved"
```

### Exercise 4.2: Debugging Workflow

```
You: "The app is crashing, can you debug it?"

Claude: [DISCOVER state - reads logs, analyzes code]
       "I found the issue. Here's my fix plan..."

You: "approved"

Claude: [UNLEASH state - implements fix]

You: "Still broken, I'm stuck"

Claude: [OPTIMIZE state - awaits input]

You: "Check the environment variables"

Claude: [DISCOVER state - investigates further]
```

### Exercise 4.3: Documentation Workflow

```
You: "Document the API we just built"

Claude: [Analyzes code in DISCOVER]
       "I'll create comprehensive API documentation..."

You: "approved"

Claude: [Creates docs in UNLEASH]
```

## Part 5: Best Practices

### Exercise 5.1: Effective Communication

**Good Patterns:**
```
✅ "Approved, go ahead"
✅ "LGTM, proceed with implementation"
✅ "Yes, but use TypeScript instead"
✅ "Help, I'm getting an undefined error"
```

**Ambiguous (Avoid):**
```
❌ "OK" (unclear if approval)
❌ "Fine" (could mean anything)
❌ "Whatever" (ambiguous intent)
```

### Exercise 5.2: State Verification

Make it a habit to check state:

```bash
# Before important operations
cohesion status

# After approvals
cohesion status

# When confused
cohesion status
```

### Exercise 5.3: Recovery Procedures

If things go wrong:

```bash
# Complete reset
cohesion reset

# Check current state and capabilities
cohesion duo-status  # Detailed state information
cohesion reset       # Reset to DISCOVER state

# Check logs
tail -f .claude/state/*.log
```

## Part 6: Real-World Scenarios

### Scenario 1: Feature Development

```
You: "Add user authentication to the app"

Claude: [Analyzes existing code]
       "I'll implement JWT authentication:
        1. Install dependencies
        2. Create auth middleware
        3. Add login/signup endpoints
        4. Protect existing routes"

You: "Sounds good, but use sessions instead of JWT"

Claude: "Updated plan with session-based auth:
        1. Install express-session
        2. Configure session store
        3. Create auth endpoints
        4. Add session middleware"

You: "approved"

Claude: [Implements authentication]
```

### Scenario 2: Bug Fixing

```
You: "Users report the app crashes when submitting forms"

Claude: [Investigates in DISCOVER]
       "Found potential issue: no validation on form inputs.
        Plan: Add validation middleware and error handling"

You: "approved"

Claude: [Fixes bug in UNLEASH]
       "Fix implemented. Also added:
        - Input sanitization
        - Better error messages
        - Logging for debugging"
```

### Scenario 3: Performance Optimization

```
You: "The API is too slow"

Claude: [Analyzes performance in DISCOVER]
       "Identified bottlenecks:
        1. N+1 queries in /users endpoint
        2. No caching
        3. Synchronous operations
        
        Optimization plan..."

You: "Focus on the queries first"

Claude: "Revised plan: Optimize database queries only"

You: "approved"
```

## Part 7: Automation Tips

### Creating Shortcuts

Add to your shell profile:

```bash
# ~/.bashrc or ~/.zshrc
alias cs='cohesion status'
alias cd='cohesion duo-status'
alias cr='cohesion reset'
alias cc='cohesion safety-check'
```

### Project Templates

Create a template with Cohesion pre-configured:

```bash
# Create template
mkdir ~/templates/cohesion-project
cp -r .claude ~/templates/cohesion-project/

# Use template
cp -r ~/templates/cohesion-project/.claude new-project/
cd new-project
./.claude/install.sh
```

### Session Scripts

Automate common workflows:

```bash
#!/bin/bash
# start-session.sh
cohesion reset
echo "📝 Session started at $(date)"
cohesion status
```

## Quiz: Test Your Knowledge

1. **What state does Claude start in?**
   - Answer: DISCOVER

2. **Which keywords trigger UNLEASH state?**
   - Answer: "approved", "lgtm", "proceed"

3. **What can Claude do in OPTIMIZE state?**
   - Answer: Nothing - no tool access

4. **How do you manually enter UNLEASH state?**
   - Answer: Say "approved", "lgtm", or "proceed" after Claude presents a plan

5. **What happens after Claude completes a task in UNLEASH?**
   - Answer: Returns to DISCOVER

## Troubleshooting Common Issues

### Issue: Claude isn't respecting states

**Solution:**
```bash
# Check hooks are active
tail -f .claude/state/*.log

# Restart Claude Code
# Verify with:
cohesion status
```

### Issue: Stuck in wrong state

**Solution:**
```bash
# Force reset
cohesion reset

# Or manually set
.claude/utils/state.sh set DISCOVER "Manual reset"
```

### Issue: Approval not working

**Solution:**
```bash
# Check keyword detection
grep "approved" .claude/hooks/detect-intent.sh

# Test manually
echo "approved" | .claude/hooks/detect-intent.sh
```

## Next Steps

Congratulations! You now understand:
- ✅ The three-state system
- ✅ Approval workflows
- ✅ State transitions
- ✅ Recovery procedures
- ✅ Best practices

**Continue learning:**
1. Read [Workflow Patterns](WORKUNLEASH.md) for advanced techniques
2. Explore [Configuration](reference/CONFIGURATION.md) for customization
3. Check [Best Practices](guides/BEST_PRACTICES.md) for pro tips

---

**Questions?** See [FAQ](guides/FAQ.md) or [open an issue](https://github.com/khenbest/Cohesion/issues)