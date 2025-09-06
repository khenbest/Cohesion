# 🚀 Quick Start Guide

> Get Cohesion running in your project in under 2 minutes!

## Prerequisites

- **Claude Code** (Desktop or VS Code extension)
- **Bash shell** (Mac, Linux, or WSL on Windows)
- **jq** (optional but recommended for better performance)

## 2-Minute Setup

### Step 1: Get Cohesion

```bash
# Option A: Clone from GitHub
git clone https://github.com/yourusername/cohesion
cd cohesion

# Option B: Download and extract
wget https://github.com/yourusername/cohesion/archive/main.zip
unzip main.zip
cd cohesion-main
```

### Step 2: Install in Your Project

```bash
# Copy framework to your project (from the cohesion directory)
cp -r .claude ~/your-project/.claude

# Optional: Also copy the CLI tool
cp cohesion ~/your-project/cohesion

# Navigate to your project
cd ~/your-project

# Run installation script
chmod +x .claude/install.sh
./.claude/install.sh
```

### Step 3: Restart Claude Code

**Important**: Restart Claude Code to activate the hooks.

- **VS Code**: Reload window (`Cmd+R` / `Ctrl+R`)
- **Desktop**: Quit and reopen application

### Step 4: Verify Installation

```bash
# Check if Cohesion is active
cohesion status

# Expected output:
# 🎯 Cohesion Status
# State: DISCOVER
# Session: active
# Duration: 0m
```

## 🎉 You're Ready!

Cohesion is now controlling Claude's access. Try this test conversation:

```
You: "Create a simple hello world function"

Claude: [Analyzes request in DISCOVER state]
        "I'll create a hello world function. Here's my plan:
         1. Create a new file called hello.js
         2. Add a simple function that prints 'Hello, World!'
         3. Export the function
         
         Does this look good?"

You: "approved"

Claude: [Transitions to UNLEASH state, creates the file]

You: "cohesion status"  # Check state is back to DISCOVER
```

## 🎮 Basic Commands

```bash
# Check current state
cohesion status

# Manual state control
cohesion unleash   # Enter UNLEASH (full access)
cohesion discover  # Enter DISCOVER (planning only)
cohesion optimize  # Enter OPTIMIZE (collaborative mode)
cohesion reset     # Start fresh

# View statistics
cohesion stats     # Show session stats
```

## 💬 Magic Keywords

These keywords in your messages trigger state transitions:

| Keyword | Effect | Example |
|---------|--------|---------|
| **approved**, **lgtm** | DISCOVER → UNLEASH | "Looks good, approved!" |
| **unclear**, **stuck** | Any → OPTIMIZE | "I'm unclear about this" |
| **reset** | Any → DISCOVER | "Let's reset and start over" |
| **try this** | OPTIMIZE → DISCOVER | "Try this approach..." |

## 📁 What Was Installed

```
your-project/
├── .claude/
│   ├── settings.json      # Hook configuration
│   ├── hooks/            # State control scripts
│   ├── utils/            # Helper utilities
│   ├── install.sh        # Installation script
│   └── state/           # Session persistence
└── cohesion             # CLI executable (optional)
```

## 🔍 Test the Workflow

### 1. Planning Phase (DISCOVER)
```bash
# Claude can:
✅ Read files
✅ Search code  
✅ Analyze problems
✅ Present plans

# Claude cannot:
❌ Write files
❌ Edit code
❌ Execute commands that modify
```

### 2. Execution Phase (UNLEASH)
```bash
# After you approve, Claude can:
✅ Write files
✅ Edit code
✅ Run commands
✅ Complete implementation
```

### 3. Collaboration Phase (OPTIMIZE)
```bash
# When stuck, Claude:
❌ Cannot use any tools
⏸️ Waits for your help
📝 Processes your solution when provided
```

## ⚡ Performance Check

Verify hooks are fast:

```bash
# Time a state check
time cohesion status

# Should be < 20ms total
```

## 🚨 Troubleshooting

### Hooks Not Working?

```bash
# Check permissions
ls -la .claude/hooks/*.sh

# Make executable if needed
chmod +x .claude/hooks/*.sh

# Restart Claude Code
```

### State Not Persisting?

```bash
# Check state file exists
ls -la .claude/state/session.json

# Reset if corrupted
rm -rf .claude/state/
./.claude/install.sh
```

### Missing jq?

```bash
# Mac
brew install jq

# Ubuntu/Debian
sudo apt-get install jq

# Works without jq but slower
```

## 📚 Next Steps

Now that Cohesion is running:

1. **Read the [Tutorial](TUTORIAL.md)** - Interactive walkthrough
2. **Learn [Workflow Patterns](WORKFLOW.md)** - Best practices
3. **Explore [Commands](COMMANDS.md)** - Full reference
4. **Customize [Settings](reference/CONFIGURATION.md)** - Make it yours

## 💡 Pro Tips

1. **Start Small** - Let Claude plan before approving
2. **Be Explicit** - Use clear keywords like "approved"
3. **Check State** - Run `cohesion status` anytime
4. **Reset When Needed** - `cohesion reset` for fresh start
5. **Review Plans** - Always review before approving UNLEASH

---

**Need help?** Check the [Troubleshooting Guide](guides/TROUBLESHOOTING.md) or [open an issue](https://github.com/yourusername/cohesion/issues).