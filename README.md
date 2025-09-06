# Cohesion 
Cohesion is an **intelligent process augmentation for Claude Code** that transforms Claude Code from a chaotic code cowboy to your cool, calm, collaborative partner through enforcement of the **DUO Protocol**:

1. **DISCOVER** 🔍 - Claude analyzes and plans with you (no write access)
2. **UNLEASH** ⚡ - Claude executes autonomously (full access)  
3. **OPTIMIZE** ✨ - Claude discusses blockers or refinements with you (diagnostic tools only)

_Claude Code, now with impulse control!_

Without Cohesion, Claude Code can be unpredictable. You may have watched with horror as Claude:

a. makes irrelevant or harmful changes without a clear plan
b. immediately begins coding when you want to discuss said plan
c. works according to the perfect plan, but slowly loses context
d. All of the above (aka death spiral)

Cohesion aims to resolve these inconvenient behaviors with clear guardrails and processes - all documented for your approval and (most importantly) consistently maintained between sessions. 

## 🚀 Quick Start (2 minutes)

### Option 1: Global Installation (Recommended)
```bash
# 1. Clone Cohesion
git clone https://github.com/khenbest/Cohesion
cd Cohesion

# 2. Install globally
./install.sh --global

# 3. Initialize any project
cd ~/your-project
cohesion init

# 4. Start Claude Code - Cohesion is active!
```

### Option 2: Project-Local Installation
```bash
# 1. Clone Cohesion
git clone https://github.com/khenbest/Cohesion
cd Cohesion

# 2. Install locally
./install.sh --local

# 3. Start Claude Code from this directory
```

## 📦 What's Included 

```
.claude/
├── settings.json          # Hook configuration (ready to use)
├── hooks/
│   ├── session-start.sh   # SessionStart hook - Initializes state
│   ├── session-end.sh     # SessionEnd hook - Saves state
│   ├── pre-tool-use.sh    # PreToolUse hook - Controls tool access
│   ├── bash-validator.sh  # PreToolUse hook - Validates bash commands
│   ├── post-tool-use.sh   # PostToolUse hook - Tracks usage
│   ├── detect-intent.sh   # UserPromptSubmit hook - Detects keywords
│   ├── save-progress.sh   # Stop hook - Saves work progress
│   └── pre-compact.sh     # PreCompact hook - Preserves state
├── utils/
│   └── state.sh          # State management utilities
├── install.sh            # One-click installation
└── state/               # Session persistence (auto-created)
```

## 💬 How to Use It

### Basics Workflow

1. **Start a task** - Claude begins in DISCOVER state
2. **Claude presents a plan** - Reviews and analyzes first
3. **You approve** - Say "approved", "lgtm", or "proceed"
4. **Claude executes** - Now in UNLEASH state with full access
5. **Task completes or needs input** - Returns to DISCOVER or OPTIMIZE

### Keywords

| Say this | Claude transitions to | What happens |
|----------|----------------------|--------------|
| "approved", "lgtm", "proceed" | UNLEASH | Full tool access granted |
| "unclear", "which approach", "preference?" | OPTIMIZE | Claude collaborates with you |
| "reset", "start over" | DISCOVER | Fresh start |
| "try this", "here's my preference" | DISCOVER | Claude processes your guidance |

### CLI Commands

```bash
# Check current state
./cohesion status

# Manual state control  
./cohesion unleash   # Enter UNLEASH state
./cohesion discover  # Enter DISCOVER state
./cohesion optimize  # Enter OPTIMIZE state
./cohesion reset     # Start fresh

# View statistics
./cohesion stats     # Show tool usage stats
```

## 🛠️ Customization

### Modify State Transitions

Edit `.claude/hooks/detect-intent.sh`:
```bash
# Add your own keywords
detect_approval() {
    case "$MESSAGE" in
        *approved*|*lgtm*|*"ship it"*|*"your keyword"*)
            return 0
            ;;
```

### Change Tool Permissions

Edit `.claude/hooks/pre-tool-use.sh`:
```bash
DISCOVER)
    # Customize what's allowed in DISCOVER state
    case "$TOOL" in
        Write|Edit|YourTool)
            # Deny these tools
            ;;
        Read|Grep|YourSafeTool)
            # Allow these tools
            ;;
```


## 🔍 How It Works

### The DUO Protocol
Cohesion enforces three working states through [hooks](https://docs.anthropic.com/en/docs/claude-code/hooks-guide) that intercept Claude's actions:
- **DISCOVER** - Read-only tools, planning phase
- **UNLEASH** - Full access after approval
- **OPTIMIZE** - Diagnostic tools for collaboration

### The Hooks in Action
Each hook maps to a Claude Code event:

**Session Lifecycle**
- `session-start.sh` (SessionStart) - Initializes DISCOVER state, restores context
- `session-end.sh` (SessionEnd) - Saves state for next session
- `pre-compact.sh` (PreCompact) - Preserves state before token cleanup

**Tool Control**  
- `pre-tool-use.sh` (PreToolUse) - Enforces tool access based on state
- `bash-validator.sh` (PreToolUse for Bash) - Additional validation for bash commands
- `post-tool-use.sh` (PostToolUse) - Tracks tool usage statistics

**User Interaction**
- `detect-intent.sh` (UserPromptSubmit) - Listens for state-change keywords
- `save-progress.sh` (Stop) - Saves work when interrupted

**Utilities**
- `state.sh` - Core state management functions (not a hook)

### Technical Implementation
- **Pure bash + jq** - No Python/Node overhead
- **<20ms overhead** - Negligible performance impact
- **Session persistence** - State survives restarts
- **Append-only logs** - Fast, reliable tracking

### 🔥 Hook Performance

**Real-world metrics:**
- Session start: **4ms** average
- Tool validation: **8ms** average  
- State transition: **6ms** average
- Total overhead per operation: **<20ms**

**Optimization techniques:**
- **Pure bash + jq** - No Python/Node overhead
- **Targeted JSON queries** - Minimal parsing with jq
- **Append-only logs** - No file rewrites
- **Early returns** - Fail fast pattern
- **Process substitution** - Avoid subshells

## 🚨 Troubleshooting

### Hooks not firing?
```bash
# Check if hooks are executable
ls -la .claude/hooks/*.sh

# Make them executable
chmod +x .claude/hooks/*.sh

# Restart Claude Code
```

### State not persisting?
```bash
# Check state file
cat .claude/state/session.json

# Check permissions
ls -la .claude/state/

# Manual reset
rm -rf .claude/state/
./.claude/install.sh
```

### Need jq?
```bash
# Mac
brew install jq

# Ubuntu/Debian  
apt-get install jq

# Without jq, basic features work but slower
```

### Multi-Project Setup
```bash
# Share config across projects
ln -s ~/cohesion-global/.claude ~/.claude

# Or source from global
source ~/cohesion-global/state.sh
```

## 📖 Documentation

### Getting Started
- [🚀 Quick Start Guide](docs/QUICKSTART.md) - Up and running in 2 minutes
- [📦 Installation Guide](docs/INSTALLATION.md) - Detailed setup instructions
- [🎓 Tutorial](docs/TUTORIAL.md) - Step-by-step walkthrough
- [📚 Full Documentation Index](docs/INDEX.md) - Complete documentation

### Core Concepts
- [🧠 States Explained](docs/concepts/STATES.md) - DISCOVER, UNLEASH, and OPTIMIZE
- [🪝 Hooks System](docs/concepts/HOOKS.md) - How Cohesion conditions Claude
- [⚙️ Configuration](docs/reference/CONFIGURATION.md) - Customization options

### Templates
- [📋 Project Context](docs/templates/project/CONTEXT.md) - Track project state
- [📝 Commands Reference](docs/templates/project/COMMANDS.md) - Document commands
- [🔄 Workflow Guide](docs/templates/project/WORKFLOW.md) - Define workflows

## 📄 License

MIT - Use freely in your projects

## 🔗 Based On

Inspired by one too many nights without sleep, internal screaming, and a desire to save just one developer's sanity. 
---

**Ready to use immediately. No build required. Just copy, install, and go.**