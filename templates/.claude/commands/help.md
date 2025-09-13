---
description: "Show comprehensive Cohesion command reference"
---

# ❓ Cohesion Command Help

Complete reference for all available slash commands.

**Help Topic:** $ARGUMENTS

## Core Mode Commands

### 🔍 `/discover [focus]`
**Purpose:** Switch to analysis mode for careful planning
- **Tools:** Read, Grep, Glob, safe Bash commands only
- **Use when:** Understanding problems, exploring code, planning solutions

### ✨ `/optimize [goal]` 
**Purpose:** Collaborative development with file approvals
- **Tools:** All DISCOVER tools + Write/Edit (with approval)
- **Use when:** Working on sensitive code, want oversight

### ⚡ `/unleash [task]`
**Purpose:** Full autonomous development mode
- **Tools:** Everything available, no restrictions  
- **Use when:** Plan is clear, need maximum velocity

## Status & Control

### 📊 `/status`
Show current mode, session info, approved files, and recent activity

### 🔄 `/reset [reason]`
Return to DISCOVER mode with fresh perspective, preserving progress

## File Management (OPTIMIZE Mode)

### 📁 `/approve <file|pattern|all>`
- `/approve filename.js` - Approve specific file
- `/approve src/**/*.js` - Approve pattern
- `/approve all` - Approve all files
- `/approve` - Show approved files

## The DUO Protocol

**D**ISCOVER → **U**NLEASH → **O**PTIMIZE (repeat)

1. **DISCOVER** - Analyze and plan thoroughly
2. **UNLEASH** - Execute at maximum velocity  
3. **OPTIMIZE** - Refine with careful oversight

## Canon Principles

1. **Think-First** - Analysis prevents debugging marathons
2. **Always-Works** - Test assumptions before building
3. **Reality-Check** - When expected ≠ actual, investigate
4. **Approval-Criteria** - Know when to seek permission
5. **Naming-Conventions** - Clear names prevent confusion

---

*For specific command help: `/help <command>` • Current mode persists across sessions*