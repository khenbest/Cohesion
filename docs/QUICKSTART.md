# Quick Start Guide

## 2-Minute Setup

```bash
# Install globally
git clone https://github.com/khenbest/Cohesion && cd Cohesion && ./install.sh

# Initialize in your project
cd ~/your-project
cohesion init

# Check status
cohesion status
```

## How It Works

### The DUO Protocol States

1. **DISCOVER** 🔍 (Default)
   - Read-only access
   - Claude analyzes and plans
   - Cannot modify files

2. **UNLEASH** ⚡ 
   - Full access granted
   - Say "approved" to activate
   - Claude can execute plans

3. **OPTIMIZE** ✨
   - Collaboration mode
   - Say "optimize" to activate
   - Diagnostic tools only

### Basic Workflow

```
You: "Fix the authentication bug"
Claude: [DISCOVER] Let me analyze...
        Found issue in auth.js
        Plan: Update token validation
        
You: "approved"
Claude: [UNLEASH] Executing fix...
        ✓ Updated auth.js
        ✓ Tests passing

You: "optimize" 
Claude: [OPTIMIZE] Let's discuss approaches...
        Option A: JWT tokens
        Option B: Session cookies
        
You: "reset"
Claude: [DISCOVER] Back to analysis mode
```

## Commands

- `cohesion init` - Set up in project
- `cohesion status` - Check current state
- `cohesion reset` - Return to DISCOVER
- `cohesion upgrade` - Update installation
- `cohesion uninstall` - Remove from project

## Keywords

| Say | Result |
|-----|--------|
| approved, lgtm, yes | → UNLEASH |
| optimize, unclear, help | → OPTIMIZE |
| reset, restart, stop | → DISCOVER |