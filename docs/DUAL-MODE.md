# Cohesion Dual-Mode Installation

Cohesion v2.0 introduces flexible installation modes that let you start small and scale up as you gain confidence.

## Installation Modes

### 🏠 Local Mode (Project-Only)
Perfect for trying Cohesion in a single project without affecting your system.

```bash
# Install for current project only
./install.sh
# Choose option 1: "Just this project"
```

- **Installs to**: `./.claude/` in your project
- **Affects**: Only the current project
- **Commands**: `./cohesion status`, `./cohesion unleash`, `./cohesion discover`, etc.
- **Best for**: First-time users, testing, isolated projects

### 🌍 Global Mode (System-Wide)
Once you love Cohesion, upgrade to use it everywhere automatically.

```bash
# Install globally for all projects
./install.sh
# Choose option 2: "Globally for all projects"

# Or upgrade from local:
./cohesion upgrade
```

- **Installs to**: `~/.cohesion/` and `~/.claude/`
- **Affects**: All projects automatically
- **Commands**: `cohesion status`, `cohesion unleash` (from anywhere)
- **Best for**: Regular users, multiple projects, teams

## Progressive Trust Journey

### 1️⃣ Try It Out (Project-Local)
```bash
cd my-project
git clone https://github.com/khenbest/Cohesion
cd Cohesion && ./install.sh
# Choose: "1) Just this project"
```
Low commitment, easy to remove, full functionality.

### 2️⃣ Love It? Install Globally!
```bash
cd ~/Cohesion  # Or wherever you cloned it
./install.sh --global
```
- Installs to ~/.cohesion and ~/.claude
- Available in all projects immediately
- Use `cohesion init` in any project to activate

### 3️⃣ Use Everywhere
```bash
cd any-project
cohesion init    # Activate Cohesion for this project
cohesion status  # Manage states
```
No setup needed in new projects.

## How It Works

### State Isolation
Each project maintains its own state, regardless of installation mode:

- **Local**: State in `./project/.claude/state/`
- **Global**: State in `~/.cohesion/states/[project-hash]/`

### Automatic Detection
Cohesion automatically detects which mode to use:

1. If local installation exists → Use local
2. If only global exists → Use global
3. If both exist → Use local (override with `cohesion use global`)

### Smart Migration
When upgrading from local to global:

```bash
./cohesion upgrade

# Options:
# 1. Migrate state to global (recommended)
# 2. Keep local state for this project
# 3. Remove local installation completely
```

## Commands

### Installation Management
```bash
cohesion which          # Show current mode (local/global)
cohesion upgrade        # Upgrade local → global
cohesion downgrade      # Downgrade global → local  
cohesion use [mode]     # Switch between modes
cohesion uninstall      # Remove Cohesion
```

### Global-Only Features
```bash
cohesion list           # List all projects with states
cohesion clean          # Remove old project states
```

### State Management (Works in Both Modes)
```bash
cohesion status         # Current state
cohesion unleash        # Enter UNLEASH state
cohesion discover       # Enter DISCOVER state
cohesion optimize       # Enter OPTIMIZE state
cohesion reset          # Fresh start
```

## FAQ

**Q: Can I have both local and global installations?**
A: Yes! Local takes precedence. Use `cohesion use global` to switch.

**Q: What happens to my state when I upgrade?**
A: You choose: migrate it, keep it local, or start fresh.

**Q: How do I uninstall?**
A: Run `cohesion uninstall` and choose what to remove.

**Q: Is global mode safe?**
A: Yes! Each project's state is isolated. Global only means the tool is available everywhere.

**Q: Can I downgrade from global to local?**
A: Yes! Use `cohesion downgrade --to-local` in any project.

## Benefits Summary

| Feature | Local | Global |
|---------|-------|--------|
| Try without commitment | ✅✅✅ | ✅ |
| No system changes | ✅✅✅ | ❌ |
| Works in all projects | ❌ | ✅✅✅ |
| No per-project setup | ❌ | ✅✅✅ |
| Easy upgrade path | ✅✅✅ | N/A |
| Team sharing | ✅ | ✅✅✅ |

## Getting Started

1. **New users**: Start with local mode
2. **Happy users**: Upgrade to global
3. **Power users**: Mix both as needed

The key principle: **Start small, grow when ready!**