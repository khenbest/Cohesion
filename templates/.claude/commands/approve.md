---
description: "Approve files for editing in OPTIMIZE mode"
allowed-tools: Bash(*:*)
---

## File Approval

!`.claude/commands/approve $ARGUMENTS`

# 📁 File Approval System

Managing file editing permissions in OPTIMIZE mode.

**Target File:** $ARGUMENTS

## Usage

- `/approve <filename>` - Approve specific file for editing
- `/approve` - Show currently approved files

## Examples

```
/approve src/main.js
/approve components/Header.jsx
/approve README.md
```

## How It Works

1. **OPTIMIZE Mode Only** - Approval system only active in collaborative mode
2. **Explicit Permission** - Each file must be individually approved
3. **Persistent** - Approvals stored in .claude/state/.approved_edits

---

*Canon Principle: Approval-Criteria - Clear boundaries enable confident collaboration.*