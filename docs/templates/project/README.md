# 📋 Project Template Files

These are template files that users should copy to their project's `docs/` directory to maintain project state and documentation.

## What These Files Do

### CONTEXT.md
- **Purpose**: Track current project state, progress, and decisions
- **Usage**: Update regularly as work progresses
- **Key Sections**: Current state, sprint info, completed/in-progress/upcoming tasks, metrics

### COMMANDS.md  
- **Purpose**: Document project-specific commands
- **Usage**: Reference for common operations
- **Key Sections**: Build commands, test commands, deployment, utilities

### WORKFLOW.md
- **Purpose**: Define project development workflow
- **Usage**: Guide for consistent development practices
- **Key Sections**: Daily cycle, sprint management, testing workflow, best practices

## How to Use

1. **Copy to your project:**
```bash
# From your project root
mkdir -p docs
cp cohesion/docs/templates/project/*.md docs/
```

2. **Customize for your project:**
- Replace placeholder text with your project details
- Add project-specific commands
- Define your workflow preferences

3. **Maintain regularly:**
- Update CONTEXT.md at start/end of sessions
- Add new commands to COMMANDS.md as discovered
- Refine WORKFLOW.md based on what works

These templates help maintain continuity across Claude Code sessions by providing persistent project documentation.