# 🔄 {{PROJECT_NAME}} DAILY WORKFLOW

## 🔄 Core Development Loop

**The foundation of productive development: consistent daily habits that ensure quality and progress.**

---

## 📅 Daily Execution Pattern

### **🌅 Morning Startup** ({{DAILY_START_TIME}} - {{STARTUP_DURATION}})

**Context Loading**:
- Read `docs/STATE.md` for current status
- Check recent commits and changes
- Review today's priorities

**System Check**:
```bash
# Pull latest changes
git pull origin main

# Check project status
{{STATUS_CHECK_COMMAND}}

# Verify development environment
{{ENV_CHECK_COMMAND}}
```

**Planning** (5-10 minutes):
- [ ] Identify 1-3 primary tasks for today
- [ ] Check for blockers or dependencies
- [ ] Estimate time requirements
- [ ] Set realistic expectations

---

### **🔧 Development Sessions** ({{WORK_BLOCK_DURATION}} blocks)

**Focus Block Pattern**:
1. **Single Task Focus**: Work on one task without interruption
2. **Continuous Testing**: Validate changes as you build
3. **Progressive Documentation**: Update docs alongside code
4. **Incremental Commits**: Save progress with clear messages

**Quality Gates** (every block):
- [ ] Code runs without errors
- [ ] Tests pass (unit and integration)
- [ ] Documentation reflects changes
- [ ] Commit message is clear and descriptive

**Between Blocks**:
- Brief progress check (2-3 minutes)
- Address urgent communications
- Stretch and reset focus

---

### **🌅 End of Day Wrap-up** ({{DAILY_END_TIME}} - {{WRAPUP_DURATION}})

**Final Validation**:
```bash
# Run complete test suite
{{TEST_COMMAND}}

# Check code quality
{{LINT_COMMAND}}

# Verify all changes committed
git status
```

**Documentation Update**:
- Update progress in `docs/STATE.md`
- Log any decisions made in `docs/05-decisions/`
- Note blockers or insights discovered

**Daily Review**:
- [ ] Primary tasks completed or progress documented
- [ ] All work committed and pushed
- [ ] Documentation current
- [ ] Tomorrow's priorities identified

---

## 📊 Progress Tracking

### **Daily Metrics**
- **Completed Tasks**: Track what gets done
- **Quality Indicators**: Test pass rate, review feedback
- **Blockers**: Document and resolve quickly

### **Weekly Reflection**
Every {{WEEKLY_REVIEW_DAY}}:
- **Velocity**: How much work completed
- **Quality**: Issues found and resolution time
- **Process**: What's working, what needs improvement

---

## 🚨 Exception Handling

### **When Blocked**
1. **Document**: Record blocker in `docs/STATE.md`
2. **Seek Help**: Reach out to team/resources
3. **Alternative Work**: Switch to unblocked tasks
4. **Follow-up**: Track resolution progress

### **When Tests Fail**
1. **Stop New Work**: Fix tests before proceeding
2. **Isolate Issue**: Identify root cause
3. **Fix Thoroughly**: Ensure fix is complete
4. **Verify**: Run full test suite before continuing

### **When Requirements Change**
1. **Assess Impact**: How does this affect current work?
2. **Communicate**: Discuss with stakeholders
3. **Re-plan**: Update priorities and timeline
4. **Document**: Record decision rationale

---

## 🎯 Quality Standards

### **Code Quality**
- All code reviewed (self-review minimum)
- Tests written for new functionality
- Documentation updated with changes
- Consistent style and formatting

### **Commit Standards**
- Clear, descriptive commit messages
- Logical, atomic commits
- No broken builds in version control
- Regular pushes to backup work

---

## 🔄 Continuous Improvement

### **Daily Learning**
- Note insights and patterns discovered
- Document solutions to problems encountered
- Share knowledge with team

### **Process Refinement**
- Track what slows you down
- Experiment with improvements
- Adjust workflow based on results

---

**Workflow Principle**: *Consistency breeds excellence. Small daily improvements compound into significant results.*

**Last Updated**: {{LAST_UPDATED}}  
**Review Frequency**: {{REVIEW_FREQUENCY}}