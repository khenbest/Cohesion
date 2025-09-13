---
description: "Initialize Cohesion session and ensure system health"
allowed-tools: Bash(*:*), Read(*:*)
---

## Cohesion Startup - Session Initialization

!`.claude/commands/startup`

# 🚀 Startup Command - Reliable Session Initialization

Ensures Cohesion is properly initialized regardless of session-start hook status.

## Features

### Self-Healing Initialization
- Creates missing directories automatically
- Restores session context if available
- Sets default mode if none exists
- Loads canon patterns when present

### First-Time Detection
- Special guidance for new projects
- Interactive tips for getting started
- Links to documentation and tutorials

### Continual Sessions
- Shows last session context
- Preserves approved files (OPTIMIZE mode)
- Displays today's activity log
- Increments session counter

## When to Use

- **Beginning of session** - Ensure proper initialization
- **After errors** - Reset and repair state
- **Mode confusion** - Verify current mode
- **Missing features** - Self-heal missing components

## What It Does

1. **Detects startup type** (first-time vs returning)
2. **Runs health checks** (self-healing)
3. **Displays beautiful banner** with mode info
4. **Shows contextual guidance** based on session type
5. **Marks session as initialized**

---

*Canon Principle: Always-Works - Cohesion self-heals to maintain functionality.*