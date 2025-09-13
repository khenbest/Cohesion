# Cohesion

Cohesion is **intelligent process augmentation for Claude Code**. It transforms Claude from a chaotic code cowboy into a cool, calm, collaborative partner by enforcing the **DUO Protocol** and the **Cohesion Canon** - six core methodologies that ensure quality:

  **DISCOVER** 🔍 – Analyze and plan with you (read-only) \
  **UNLEASH** ⚡ – Execute autonomously (full access) \
  **OPTIMIZE** ✨ – Collaborative writes gated by per-file approvals

*Claude Code, now with impulse control and proven methodologies.*

Without Cohesion, Claude can: \
a) make irrelevant/harmful changes without a plan \
b) start coding when you wanted discussion \
c) drift from the plan mid-task \
d) all of the above (the dreaded _death spiral_)

Cohesion fixes these tendencies by enforcing clear guardrails and consistent state across sessions.

---

## 🚀 Quick Start 

> Requires `jq` (macOS: `brew install jq`, Ubuntu/Debian: `sudo apt-get install -y jq`).

### Option A: Install from repo

```bash
git clone https://github.com/khenbest/Cohesion
cd Cohesion
./install.sh
# restart your shell or:  source ~/.zshrc  (or ~/.bashrc)
```

Initialize any project:

```bash
cd /path/to/your-project
cohesion init
```

### Option B: One-liner 

```bash
# update the branch/tag as needed
curl -fsSL https://raw.githubusercontent.com/khenbest/Cohesion/main/install.sh | bash
```

⚠️ **Security note**: `curl | bash` executes remote code. Prefer cloning the repo and running `./install.sh` if you need stricter review or reproducible installs.

---

## 📦 What’s Included

```
Cohesion/
├─ cohesion                 # CLI (status | init | uninstall --global | protect --wizard | doctor)
├─ install.sh               # manifest-based installer
├─ .claude/
│  ├─ hooks/
│  │  └─ pre-tool-use.sh          # Single hook architecture
│  └─ utils/
│     └─ cohesion-utils.sh
└─ templates/               # optional scaffolds (used if present)
   ├─ .gitignore.cohesion
   └─ docs/ (README.md, STATE.md, DETAILED_EXECUTION_PLAN.md, etc.)
```

## 🪝 Why Single Hook Architecture?

Cohesion uses **one intelligent hook** instead of multiple hooks for superior reliability:

⚡ **Instant Mode Switching**
- `/unleash` → `/optimize` → `/discover` with **zero session disruption**
- No process restarts, no lost conversation context
- All 15 Claude Code tools controlled at the perfect interception point

🔒 **Race Condition Proof**
- Unlike approaches that modify settings files during sessions (causing "processes restarted due to configuration changes" and broken conversations)
- Single hook snapshot captured at startup prevents timing conflicts
- No JSON corruption from concurrent file writes

🎮 **Complete Tool Control**
Controls all Claude Code functionality through one reliable gate:
```
Read-Only: Read, LS, Grep, Glob, WebSearch, NotebookRead, TodoRead
Write Tools: Write, Edit, MultiEdit, NotebookEdit, Bash, TodoWrite, WebFetch, Agent
```

*Git operations handled through Bash tool - no separate git permissions needed.*

* **Manifest** at `~/.cohesion/.manifest.json` tracks files, PATH edits, and project installs.
* **No telemetry.** macOS & Linux supported; Windows via WSL.

---

## 💡 How to Use It

### Real Workflows That Save Hours

#### 🔍 **Bug Hunting** (DISCOVER → UNLEASH)
```
❌ Without Cohesion: Claude immediately starts changing files, breaks more things
✅ With Cohesion:
1. [DISCOVER] "Fix the login bug" → Claude reads code, finds root cause
2. [DISCOVER] "It's a race condition in auth middleware"
3. /unleash → [UNLEASH] Implements fix, adds tests, verifies solution
Result: 10 minutes focused debugging vs hours of trial-and-error
```

#### ✨ **Legacy Refactoring** (DISCOVER → OPTIMIZE)
```
❌ Without Cohesion: Claude rewrites everything, breaks production
✅ With Cohesion:
1. [DISCOVER] "Modernize this React class component" → Analysis & plan
2. [DISCOVER] "Use hooks, keep existing props API"
3. /optimize → [OPTIMIZE] Collaborative step-by-step conversion
4. /approve components/UserProfile.jsx → Make surgical changes
Result: Safe refactoring with oversight vs risky rewrites
```

#### ⚡ **Feature Sprint** (DISCOVER → UNLEASH → DISCOVER)
```
❌ Without Cohesion: Claude builds wrong thing, no tests, documentation drift
✅ With Cohesion:
1. [DISCOVER] "Add user preferences" → Understand existing patterns
2. /unleash → [UNLEASH] Build feature rapidly with proper architecture
3. [UNLEASH] Add tests, update docs, handle edge cases
4. /discover → [DISCOVER] Review what was built, plan next iteration
Result: Production-ready features vs half-finished code
```

### 🎯 **The Cohesion Advantage**

**Without Cohesion** (Chaos Mode):
- 🔥 Claude jumps into coding without understanding the problem
- 💥 Changes break existing functionality
- 🔄 Endless debug cycles from rushed implementations
- 📝 No documentation, no tests, technical debt accumulates
- ⏱️ **Hours wasted** on preventable mistakes

**With Cohesion** (Controlled Intelligence):
- 🧠 **Think-First**: Every change starts with understanding
- ✅ **Always-Works**: Code that maintains functionality
- 🎯 **Right Speed**: Fast when ready, careful when needed
- 📊 **Quality Assurance**: Tests, docs, and proper patterns
- ⚡ **10x Productivity**: Minutes of thinking saves hours of debugging

### Slash Commands

Cohesion uses **slash commands** to control modes:

| Command      | Effect               | When to Use |
| ------------ | -------------------- | ------- |
| `/unleash`   | Enter **UNLEASH**    | **Plan is solid** - Build features, fix bugs, add tests rapidly |
| `/optimize`  | Enter **OPTIMIZE**   | **Critical code** - Refactor safely, modify core systems with oversight |
| `/discover`  | Back to **DISCOVER** | **Need clarity** - Debug issues, explore codebases, plan architecture |
| `/status`    | Check current mode   | View session state and context |
| `/approve <file>` | Approve file editing | Used in OPTIMIZE mode |
| `/help`      | Show commands        | List all available commands |
| `/save [context]` | Save session & update docs | Checkpoint progress with optional note |
| `/startup`   | Initialize session   | Ensure system health & show context |

#### 🧠 **Mode-Aware Intelligence**

Same request, different approach based on your current mode:

- **"This authentication is broken"**
  - 🔍 **DISCOVER**: Analyzes auth flow, identifies security issues, proposes fix strategy
  - ✨ **OPTIMIZE**: Walks through fix step-by-step, requires approval for security changes
  - ⚡ **UNLEASH**: Fixes immediately with proper error handling and tests

- **"Add user preferences"**
  - 🔍 **DISCOVER**: Researches existing patterns, designs data model, plans UI/UX
  - ✨ **OPTIMIZE**: Builds incrementally, approves each component before proceeding
  - ⚡ **UNLEASH**: Implements full feature with database, API, and frontend rapidly

- **"Performance is slow"**
  - 🔍 **DISCOVER**: Profiles code, identifies bottlenecks, researches optimization techniques
  - ✨ **OPTIMIZE**: Makes targeted optimizations with measurement and validation
  - ⚡ **UNLEASH**: Implements caching, database optimizations, and monitoring

### CLI Commands

| Command | Description |
|---------|-------------|
| `cohesion status` | Show installation status and current state |
| `cohesion init` | Initialize Cohesion in current project |
| `cohesion learn` | Interactive tutorial on Canon methodologies |
| `cohesion doctor` | Verify installation and suggest fixes |
| `cohesion protect --wizard` | Configure protected paths interactively |
| `cohesion uninstall` | Remove from current project |
| `cohesion uninstall --global` | Complete removal (uses manifest) |

---

## 🎓 The Cohesion Canon

Cohesion enforces six core methodologies that multiply developer effectiveness:

1. **Think-First** - Every minute spent thinking saves 10 minutes debugging
2. **Always-Works** - Never claim success without verification
3. **Reality-Check** - When expected ≠ actual, reality is teaching you something
4. **Approval-Criteria** - Know what requires human judgment
5. **Naming-Conventions** - Clear names prevent confusion

Run `cohesion learn` for an interactive tutorial on these methodologies.

---

## 📚 Project Documentation

When you run `cohesion init`, Cohesion **always** sets up project docs:

* Default location: `<project>/docs/` (customize with flags below).
* If `~/.cohesion/templates/docs/` exists, those are used as a scaffold.
  Otherwise, a **minimal fallback** is created with:
  * `README.md` – intro
  * `STATE.md` – current state snapshot
  * `DETAILED_EXECUTION_PLAN.md` – execution plan shell
  * `04-progress/`, `05-decisions/` – running logs & decisions

Cohesion also writes `<project>/.claude/docs.env`:

```bash
DOCS_DIR="<absolute path to docs dir>"
ALLOW_DISCOVER_DOC_WRITES=1   # toggled by CLI flags if needed
```

**Flags for `cohesion init`:**

```bash
cohesion init
  [--docs-dir <path>]            # default: <project>/docs
  [--docs-source template|create-this]
    # template    = seed from templates (or fallback)
    # create-this = treat existing dir as docs (and optionally add missing skeleton pages)
```

> Non-interactive installs: set `COHESION_ASSUME_DEFAULTS=1` to accept defaults.

---

## 🛡️ Protected Paths Wizard

```bash
cohesion protect --wizard
```

Guides you through building a safe `protected.conf` (e.g., `.git/`, `node_modules/`, `build|dist|out`, `.env`, secrets).
Writes `~/.cohesion/protected.conf` and offers to sync to each project’s `.claude/protected.conf` in order to ensure you as a developer can define where Claude should not help. 

---

## 🧪 Cohesion Doctor

```bash
cohesion doctor
```

Checks: `jq` presence, manifest, PATH entries, global hooks/utils, project `.claude` install, hook executables, utils readable, docs/env presence. Suggests one-liners to fix issues.

## ✅ Verification Checklist

After installation, verify each component:

**System checks:**
- [ ] `cohesion doctor` → All checks pass
- [ ] `cohesion status` → Shows current mode and state
- [ ] Check hook logs: `tail .claude/state/.hook_debug`

**Test each state:**
- [ ] **DISCOVER**: Try editing a file → Should be blocked with DISCOVER message
- [ ] **OPTIMIZE**: Try editing → Blocked until you say "approve edits to [file]"
- [ ] **UNLEASH**: Try editing → Works immediately
- [ ] **Safety**: Try `rm -rf /` → Always blocked
- [ ] **Protected**: Try editing `.env` → Always blocked

---

## 🔧 Troubleshooting

### Common Issues

**"command not found: cohesion"**
Restart your shell or `source ~/.zshrc` (or `~/.bashrc`), then `hash -r`.

**Hook errors / 127s**
Ensure hooks are present & executable:
```bash
ls -la .claude/hooks/*.sh
chmod +x .claude/hooks/*.sh
```

**Missing `jq`**
Install it (`brew install jq` or `sudo apt-get install -y jq`) and rerun.

**Global uninstall**
Uses the manifest to remove files and PATH edits:
```bash
cohesion uninstall --global
```

### 🔍 Quick Diagnosis

If something isn't working:
1. Check state: `cat .claude/state/.current 2>/dev/null || echo DISCOVER`
2. Check current mode: `cohesion status`
3. Check hook: `ls -la .claude/hooks/pre-tool-use.sh` (single hook architecture)
4. Run doctor: `cohesion doctor`

## 📋 Configuration Hierarchy

Settings are resolved in this order (highest priority first):

1. **Runtime**: `/config set ...` (session-only)
2. **Local Override**: `./.claude/settings.local.json` (gitignored)
3. **Project**: `./.claude/settings.json` (committed)
4. **Global**: `~/.claude/settings.json` (fallback)

💡 **Tip**: Permissions are controlled by hooks at runtime, not static configuration files.

⚠️ **Note**: The PreToolUse hook returns approval/denial decisions that bypass Claude Code's permission system.

## 💡 **Pro Tips for Power Users**

### 🎛️ **Mode Switching Mastery**
```bash
# Quick status check
/status

# Smart transitions
/discover "investigate the auth bug"    # Focus your analysis
/optimize "refactor safely"             # Collaborative approach
/unleash "ship the feature"             # Full speed ahead

# Emergency reset
/discover  # Always gets you back to safety
```

### 🔧 **Advanced Workflows**
```bash
# Complex debugging
/discover → analyze → plan → /unleash → implement → /discover → verify

# Team collaboration
/optimize → /approve src/critical/     # Approve directory
# Now team members can safely modify critical files

# Performance optimization
/discover → profile → /unleash → optimize → benchmark → /discover → review
```

---

## 🧠 **The Science Behind the Magic**

### ⚡ **Lightning-Fast Intelligence**
Cohesion intercepts **every single tool call** Claude makes in <10ms:
```
Claude wants to write a file → Cohesion hook → Check mode → Allow/Block/Approve
```
**Zero lag.** **Zero interference.** **Perfect control.**

### 🎯 **Mode-Based Precision**
Each mode unlocks exactly the right tools for the job:

| Mode | Tools Available | Perfect For |
|------|----------------|-------------|
| 🔍 **DISCOVER** | Read, Search, Analyze | Understanding problems without changing anything |
| ✨ **OPTIMIZE** | DISCOVER + Write (with approval) | Safe modifications to critical systems |
| ⚡ **UNLEASH** | Everything | Rapid development with full autonomy |

### 🛡️ **Built-In Safety**
- **Protected paths** (`.env`, `.git`, `node_modules`) always blocked
- **Dangerous commands** (`rm -rf /`) never allowed
- **State persistence** survives Claude Code restarts
- **Session recovery** maintains context across interruptions

*Why this matters:* Other AI coding tools are "all or nothing." Cohesion gives you **surgical precision** - the right level of AI assistance for each situation.*

## 🔒 Operational Guarantees

### State → Tools Matrix

| State | Available Tools | Restrictions |
|-------|----------------|---------------|
| 🔍 **DISCOVER** | Read, Glob, Grep, safe Bash | All writes blocked |
| ✨ **OPTIMIZE** | All DISCOVER + Write/Edit (with approval) | Per-file approval required |
| ⚡ **UNLEASH** | All tools | Only dangerous commands + protected paths blocked |

### How Permissions Work

Cohesion uses a **hook-driven permission model** where the PreToolUse hook dynamically controls access based on your current mode:

- **DISCOVER**: Hook approves read-only tools, blocks writes
- **OPTIMIZE**: Hook requires approval for modifications  
- **UNLEASH**: Hook approves everything except protected paths

The hook's decisions bypass Claude Code's permission system entirely, providing dynamic control without maintaining tool lists.

### 🎯 **OPTIMIZE Mode: Surgical Precision**

Control exactly what Claude can modify:

```bash
# Approve specific files
/approve src/components/Header.jsx

# Approve entire directories (be careful!)
/approve src/utils/

# Check what's approved
/status

# Clear all approvals (fresh start)
/discover  # Resets to read-only mode
```

### Safety Rails (Always Active)

- **Protected paths** from `.claude/protected.conf` are immutable in all states
- **Dangerous patterns** (`rm -rf`, `curl | sh`, etc.) blocked even in UNLEASH

---

## 📖 Contributing

* PRs welcome—please run `shellcheck` and add/update any minimal BATS tests if you touch hooks/CLI.
* No telemetry, no lock-in. Keep it fast and predictable.

---

## 📄 License

MIT — use freely in your projects.

---