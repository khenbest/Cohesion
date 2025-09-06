# 📋 Command Reference

## 🚀 Quick Start Commands

### Project Setup
```bash
# Initialize Cohesion
.claude/install.sh

# Check status
cohesion status

# Check detailed state
cohesion duo-status
```

## 🔧 Development Commands

### State Management
```bash
cohesion status          # Show current state
cohesion duo-status      # Detailed state information
cohesion reset          # Reset to DISCOVER state
cohesion safety-check    # Verify installation
cohesion protection-status # Check security status

# State transitions via keywords:
# Say "approved" → UNLEASH state
# Say "unclear" → OPTIMIZE state  
# Say "reset" → DISCOVER state
```

### Sprint Management
```bash
# View current sprint
cat docs/sprints/current.md

# Complete sprint
./scripts/complete-sprint.sh

# Start new sprint
./scripts/new-sprint.sh 2
```

## 📱 Project-Specific Commands

### Build & Run
```bash
npm install             # Install dependencies
npm run build          # Build project
npm start              # Start development
npm test               # Run tests
```

### Testing
```bash
npm test               # All tests
npm test -- --watch    # Watch mode
npm test -- --coverage # Coverage report
npm run test:e2e       # End-to-end tests
```

### Code Quality
```bash
npm run lint           # Run linter
npm run lint:fix       # Auto-fix issues
npm run typecheck      # Type checking
npm run format         # Format code
```

## 🧪 Validation Commands

### Performance
```bash
# Measure build time
time npm run build

# Check bundle size
npm run analyze

# Memory usage
/usr/bin/time -l npm start
```

### Security
```bash
npm audit              # Security audit
npm audit fix          # Auto-fix vulnerabilities
```

## 📊 Metrics & Reporting

### Progress Tracking
```bash
# View tool usage
tail -f .claude/state/tool-usage.log

# Session stats
cohesion stats

# Sprint progress
grep "Progress" docs/CONTEXT.md
```

### Git Commands
```bash
# Status
git status

# Commit with message
git add . && git commit -m "feat: description"

# Tag sprint completion
git tag sprint-1-complete

# Push with tags
git push --tags
```

## 🛠️ Utility Commands

### State Utilities
```bash
# Get current state
.claude/utils/state.sh get

# Set state manually
.claude/utils/state.sh set UNLEASH "Manual override"

# Check transition
.claude/utils/state.sh check DISCOVER UNLEASH
```

### Documentation
```bash
# Update context
vim docs/CONTEXT.md

# Generate docs
npm run docs:generate

# Serve docs locally
npm run docs:serve
```

## 🔍 Debugging Commands

### Hook Debugging
```bash
# Test hooks
bash -n .claude/hooks/*.sh

# View hook logs
tail -f .claude/state/*.log

# Manual hook test
echo '{"tool_name":"Write"}' | .claude/hooks/pre-tool-use.sh
```

### State Debugging
```bash
# View raw state
cat .claude/state/session.json | jq '.'

# State backups
ls -la .claude/state/backups/

# Reset state
rm -rf .claude/state/ && cohesion reset
```

## 🔥 Emergency Commands

### Reset Everything
```bash
# Full reset
rm -rf .claude/state/
rm -rf node_modules/
.claude/install.sh
npm install
```

### Fix Permissions
```bash
chmod +x .claude/hooks/*.sh
chmod +x .claude/utils/*.sh
chmod +x cohesion
```

### Recover State
```bash
# From backup
cp .claude/state/backups/session_*.json .claude/state/session.json

# From git
git checkout HEAD -- .claude/state/session.json
```

## 📝 Custom Commands

Add your project-specific commands here:

```bash
# Example: Deploy
./scripts/deploy.sh production

# Example: Database
./scripts/db-migrate.sh

# Example: API test
curl localhost:3000/health
```

## 🎯 Workflow Commands

### Daily Routine
```bash
# Morning
cohesion status        # Check state
cat docs/CONTEXT.md    # Review context
npm test              # Verify tests

# During work  
# Say "approved" after Claude presents plan
npm test -- --watch   # Continuous testing

# End of day
git add . && git commit -m "chore: end of day"
cohesion status       # Final check
```

## 📚 Help & Info

```bash
cohesion help         # Cohesion help
npm run help         # Project help
man [command]        # System help
```

---
*Add project-specific commands as needed*