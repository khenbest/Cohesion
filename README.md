# Cohesion

Cohesion is **intelligent process augmentation for Claude Code**. It transforms Claude from a chaotic code cowboy into a cool, calm, collaborative partner by enforcing the **DUO Protocol**:

  **DISCOVER** 🔍 – Analyze and plan with you (read-only) \
  **UNLEASH** ⚡ – Execute autonomously (full access) \
  **OPTIMIZE** ✨ – Collaborative writes gated by per-file approvals

*Claude Code, now with impulse control.*

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
│  │  ├─ session-start.sh
│  │  ├─ pre-tool-use.sh
│  │  ├─ user-prompt.sh
│  │  └─ session-end.sh
│  └─ utils/
│     └─ hook-utils.sh
├─ tools/
│  └─ cohesion-protect      # used by `cohesion protect --wizard`
└─ templates/               # optional scaffolds (used if present)
   ├─ .gitignore.cohesion
   └─ docs/ (README.md, STATE.md, DETAILED_EXECUTION_PLAN.md, etc.)
```

* **Manifest** at `~/.cohesion/.manifest.json` tracks files, PATH edits, and project installs.
* **No telemetry.** macOS & Linux supported; Windows via WSL.

---

## 💡 How to Use It

### Default Workflow

1. Start a task – Claude begins in **DISCOVER** (read-only).
2. Claude proposes a plan based on last session, documentation, and overall objectives.
3. You approve:
   * type **“approved”** → **UNLEASH** (full tools) or
   * type **“optimize”** → **OPTIMIZE** (diagnostic tools only).
4. Claude executes or collaborates accordingly.
5. Say **“reset”** to cancel the current plan and return to **DISCOVER**.

### Common Keywords

| Say…                                | Effect               |
| ----------------------------------- | -------------------- |
| `approved`, `lgtm`, `go`, `proceed` | Enter **UNLEASH**    |
| `optimize`, `discuss`, `help`       | Enter **OPTIMIZE**   |
| `reset`, `discover`, `restart`      | Back to **DISCOVER** |

### CLI Commands

| Command | Description |
|---------|-------------|
| `cohesion status` | Show installation status and current state |
| `cohesion init` | Initialize Cohesion in current project |
| `cohesion doctor` | Verify installation and suggest fixes |
| `cohesion protect --wizard` | Configure protected paths interactively |
| `cohesion uninstall` | Remove from current project |
| `cohesion uninstall --global` | Complete removal (uses manifest) |

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
- [ ] `/permissions` → Shows rules from your settings files  
- [ ] `/config get permissions.defaultMode` → Returns current mode

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
2. Check settings: `/config get permissions.defaultMode`
3. Check hooks: `ls -la .claude/hooks/*.sh | wc -l` (should be 4+)
4. Run doctor: `cohesion doctor`

## 📋 Configuration Hierarchy

Settings are resolved in this order (highest priority first):

1. **Runtime**: `/config set ...` (session-only)
2. **Local Override**: `./.claude/settings.local.json` (gitignored)
3. **Project**: `./.claude/settings.json` (committed)
4. **Global**: `~/.claude/settings.json` (fallback)

💡 **Tip**: Use `/permissions` to see which file is providing each rule.

⚠️ **Schema Note**: Cohesion handles both legacy (`defaultMode` at top) and current (`permissions.defaultMode`) schemas automatically.

## ⚠️ Known Limitations

### Schema Variations
Some Claude Code versions read `defaultMode` differently. Cohesion handles both locations automatically, but if you see permission issues, check with `/permissions`.

### Hook Precedence  
Project hooks (`.claude/hooks/`) always override global hooks. Global installation is just a convenience fallback.

### State File Names
The actual state files are `UNLEASHED` and `OPTIMIZE` (not `UNLEASH`). This is intentional to avoid confusion with the mode names.

---

## 🔍 How It Works (DUO Protocol)

Cohesion uses Claude Code hooks to gate tools per state:

* **DISCOVER** – read-only tools, planning phase
* **UNLEASH** – all tools after explicit approval
* **OPTIMIZE** – diagnostic tools only

Hooks:

* `session-start.sh` / `session-end.sh` – initialize & persist state
* `pre-tool-use.sh` – enforce tool access & protect paths
* `user-prompt.sh` – handle expected functionality loops from keywords

Bash + `jq`, optimized for <10ms per hook.

## 🔒 Operational Guarantees

### State → Tools Matrix

| State | Available Tools | Restrictions |
|-------|----------------|---------------|
| 🔍 **DISCOVER** | Read, Glob, Grep, safe Bash | All writes blocked |
| ✨ **OPTIMIZE** | All DISCOVER + Write/Edit (with approval) | Per-file approval required |
| ⚡ **UNLEASH** | All tools | Only dangerous commands + protected paths blocked |

### Permissions Mode in UNLEASH

Cohesion automatically sets `permissions.defaultMode = acceptEdits` when entering UNLEASH.

**Verify in Claude Code:**
- `/permissions` → Should show Edit(./**), Bash(*) as Allowed
- `/config get permissions.defaultMode` → Should return `acceptEdits`

**If permissions don't update automatically:**
1. Run `/config reload` (recommended)
2. Or manually set: `/config set permissions.defaultMode acceptEdits`

### Approvals (OPTIMIZE Mode)

- **Storage**: `.claude/state/approvals.txt` (canonical absolute paths)
- **Approve**: Say "approve edits to ./path/file" (directories approved recursively)
- **List**: Say "list approvals"
- **Clear**: Say "clear approvals"

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