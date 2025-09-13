# Canon Construct 6: Close-the-Loop

**Internal Behavioral Directive:** When system paradigms change, ensure all ripple effects are systematically addressed before considering the change complete.

## Behavioral Triggers

### Pattern Detection
```
significant_change patterns:
- *implement*auth* → Authentication system changes
- *implement*service* → New service architectures  
- *refactor*database* → Data layer modifications
- *major*refactor* → Architectural changes
- *breaking*change* → API/interface breaks
- *deploy*|*infrastructure* → System deployment changes
- *integrate*external* → Third-party integrations
- *migration*|*schema* → Data migrations

refactor_wildcard pattern:
- *refactor* → General refactoring (scope analysis needed)
```

### Enforcement Logic
```
Phase: significant_change detected
Required: progress = "analyzed" 
Blocking: Write, Edit, MultiEdit tools
Progress tracking: Read/Grep/Glob → "analyzed"

Mode-specific enforcement:
DISCOVER: 30% probabilistic blocking (light guidance)
OPTIMIZE: 90% enforcement (mandatory analysis) 
UNLEASH: Internalized (no blocking, trusted execution)
```

### Refactor Wildcard Logic  
```
Phase: refactor_wildcard detected
DISCOVER: 30% chance guidance on scope consideration
OPTIMIZE: 70% chance blocking for scope analysis
UNLEASH: No intervention (internalized refactor awareness)
```

## Behavioral Implementation

### Impact Analysis Requirements
Before allowing implementation of significant_change:

**Documentation Impact:**
- What README files reference this component?
- Which architecture docs need updates?
- Are there API documentation changes?

**Test Impact:**
- Which test suites validate current behavior? 
- Do integration tests assume old interfaces?
- Are there mocked dependencies affected?

**Configuration Impact:**
- What environment variables are involved?
- Do deployment scripts need updates?
- Are there database connection changes?

**Dependency Impact:**
- Which services call this component?
- What other systems expect current behavior?
- Are there breaking interface changes?

### Progress Tracking

**Automatic Progress Detection:**
```
Tool usage pattern recognition:
Read → analyzing existing code
Grep → searching for dependencies  
Glob → finding related files
→ Set progress = "analyzed"
```

**Behavioral Internalization:**
- Track tool usage patterns to understand analysis depth
- Recognize when sufficient exploration has occurred
- Allow progression to implementation phase

## Enforcement Responses

### OPTIMIZE Mode (90% enforcement)
```json
{
  "decision": "block",
  "reason": "🔗 CLOSE-THE-LOOP: Major system change requires impact analysis.\n\nBefore implementing:\n1. Analyze effect on documentation\n2. Identify test updates needed\n3. Check configuration dependencies\n4. Review component interactions\n\nUse Read/Grep to analyze impacts first."
}
```

### DISCOVER Mode (30% enforcement)  
```json
{
  "decision": "block", 
  "reason": "🔗 CLOSE-THE-LOOP: This appears to be a major system change.\n\nConsider analyzing impact on:\n• Documentation that may need updates\n• Tests that may need modification\n• Configuration dependencies\n\nUse Read/Grep to explore, or /unleash to proceed."
}
```

### Refactor Wildcard Responses

**OPTIMIZE Mode (70% enforcement):**
```json
{
  "decision": "block",
  "reason": "🔄 REFACTOR-AWARENESS: Refactoring scope unclear.\n\nBefore proceeding:\n• Will this affect multiple components?\n• Are there interface changes involved?\n• Should other parts of the system be updated?\n\nUse Read/Grep to understand scope first."
}
```

**DISCOVER Mode (30% enforcement):**
```json
{
  "decision": "block",
  "reason": "🔄 REFACTOR-AWARENESS: Consider the refactor scope.\n\nQuestions to consider:\n• Is this a simple cleanup or broader change?\n• Will it affect how other code interacts with this?\n\nExplore with Read/Grep, or /unleash to proceed."
}
```

## Behavioral Internalization

### Core Principle Integration
Close-the-Loop is the **system coherence** principle that ensures:

1. **Completeness:** Changes aren't finished until all affects are addressed
2. **Consistency:** System remains coherent across all components  
3. **Reliability:** No cascade failures from incomplete impact analysis

### Interaction with Other Constructs

**Reinforces Think-First:** Impact analysis IS thinking before building
**Extends Always-Works:** "Works" includes "everything still works"  
**Enhances Reality-Check:** Reality includes system-wide effects
**Complements Approval-Criteria:** Some changes need broader approval
**Supports Naming-Conventions:** Interface changes affect naming consistency

### Successful Internalization Indicators

**In DISCOVER Mode:**
- Naturally consider broader impacts before suggesting implementation
- Proactively mention potential ripple effects
- Suggest exploration of related components

**In OPTIMIZE Mode:**  
- Consistently block major changes until impact analysis complete
- Guide user through systematic impact evaluation
- Track analysis completeness through tool usage

**In UNLEASH Mode:**
- Automatically perform impact analysis without blocking
- Address documentation, tests, configs as part of implementation
- Maintain system coherence without explicit enforcement

## System Impact Examples

### Authentication System Implementation
**Cascade Analysis:**
- Frontend auth flows → UI component updates needed
- API endpoints → Documentation updates required
- Database schema → Migration scripts needed  
- Service integrations → Interface contract changes
- Monitoring → New auth metrics required
- Testing → Auth test suites need updates

### Service Layer Refactoring
**Scope Evaluation:**
- Interface changes → Breaking vs non-breaking
- Data models → Database impact assessment
- Dependencies → Consumer service effects  
- Configuration → Environment variable changes
- Deployment → Pipeline modification needs

This construct ensures that **major changes maintain system coherence** by requiring **comprehensive impact analysis** before implementation.