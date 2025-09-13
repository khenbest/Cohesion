---
description: "Switch to OPTIMIZE mode for collaborative editing with file approvals"
allowed-tools: Bash(*:*)
---

## Mode Transition

!`.claude/commands/optimize`

# ✨ OPTIMIZE Mode Activated

Entering collaborative development with careful file-by-file approvals.

**Collaboration Goal:** $ARGUMENTS

## What OPTIMIZE Mode Does

- **Enables:** All DISCOVER tools + Write/Edit operations
- **Requires:** `/approve <file>` before editing each file
- **Purpose:** Collaborative development with guardrails and oversight

## File Approval Required

Before editing any file, you must first approve it:
- `/approve <filename>` - Approve specific file
- `/approve <pattern>` - Approve files matching pattern  
- `/approve all` - Approve all project files
- `/approve` - Show currently approved files

## Next Steps

1. **Identify** files you need to modify
2. **Approve** each file before editing: `/approve <filename>`
3. **Make changes** carefully with full context
4. **Use** `/unleash` for full autonomy, or `/discover` to rethink

---

*Canon Principle: Approval-Criteria - Autonomy without boundaries is chaos.*