# ADR-[NUMBER]: [Title]

**Status**: Proposed | Accepted | Rejected | Deprecated | Superseded  
**Date**: YYYY-MM-DD  
**Deciders**: [List of people involved in decision]  
**Categories**: [Architecture, Security, Performance, etc.]

## Context and Problem Statement

[Describe the context and problem statement, e.g., in free form using 2-3 sentences. You may want to articulate the problem in the form of a question.]

### Background
[Provide relevant background information that helps understand the context]

### Requirements
- Requirement 1
- Requirement 2
- Requirement 3

### Constraints
- Constraint 1
- Constraint 2
- Constraint 3

## Decision Drivers

- **Driver 1**: [e.g., improve performance]
- **Driver 2**: [e.g., reduce complexity]
- **Driver 3**: [e.g., ensure scalability]
- **Driver 4**: [e.g., minimize cost]

## Considered Options

1. **Option 1**: [Title]
2. **Option 2**: [Title]
3. **Option 3**: [Title]
4. **Option 4**: [Do nothing]

## Decision Outcome

**Chosen option**: "[Option X]", because [justification. e.g., only option that meets requirement X | best balance between X and Y | easiest to implement and we can change later if needed].

### Positive Consequences
- Good thing 1
- Good thing 2
- Good thing 3

### Negative Consequences
- Bad thing 1 (and how we'll mitigate)
- Bad thing 2 (and how we'll mitigate)

### Risks
| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Risk 1 | Low/Medium/High | Low/Medium/High | How to handle |
| Risk 2 | Low/Medium/High | Low/Medium/High | How to handle |

## Pros and Cons of the Options

### Option 1: [Title]

**Description**: [Brief description of the option]

**Pros**:
- ✅ Good, because [argument]
- ✅ Good, because [argument]
- ✅ Good, because [argument]

**Cons**:
- ❌ Bad, because [argument]
- ❌ Bad, because [argument]

**Estimated Effort**: [Low/Medium/High]  
**Estimated Cost**: $[Amount or range]

### Option 2: [Title]

**Description**: [Brief description of the option]

**Pros**:
- ✅ Good, because [argument]
- ✅ Good, because [argument]

**Cons**:
- ❌ Bad, because [argument]
- ❌ Bad, because [argument]
- ❌ Bad, because [argument]

**Estimated Effort**: [Low/Medium/High]  
**Estimated Cost**: $[Amount or range]

### Option 3: [Title]

**Description**: [Brief description of the option]

**Pros**:
- ✅ Good, because [argument]

**Cons**:
- ❌ Bad, because [argument]

**Estimated Effort**: [Low/Medium/High]  
**Estimated Cost**: $[Amount or range]

### Option 4: Do Nothing

**Description**: Keep the current state/solution

**Pros**:
- ✅ No implementation effort required
- ✅ No risk of breaking changes

**Cons**:
- ❌ Problem remains unsolved
- ❌ Technical debt continues to accumulate

## Implementation Plan

### Phase 1: [Title] (Timeline)
- [ ] Task 1
- [ ] Task 2
- [ ] Task 3

### Phase 2: [Title] (Timeline)
- [ ] Task 1
- [ ] Task 2

### Phase 3: [Title] (Timeline)
- [ ] Task 1

### Success Criteria
- Criterion 1: [Measurable outcome]
- Criterion 2: [Measurable outcome]
- Criterion 3: [Measurable outcome]

## Technical Details

### Architecture Diagram
```
[ASCII art or link to diagram]
```

### Interface Changes
```typescript
// Example interface changes
interface OldInterface {
  method(): void;
}

interface NewInterface {
  improvedMethod(): Promise<void>;
}
```

### Data Model Changes
```sql
-- Example schema changes
ALTER TABLE users ADD COLUMN new_field VARCHAR(255);
```

### API Changes
```yaml
# Example API changes
/api/v2/resource:
  post:
    parameters:
      - name: newParam
        type: string
```

## Validation

### How will we validate this decision?
1. Validation approach 1
2. Validation approach 2
3. Validation approach 3

### Rollback Plan
If this decision proves incorrect, we will:
1. Step 1 for rollback
2. Step 2 for rollback
3. Step 3 for rollback

## References

### Links
- [Link to relevant documentation]
- [Link to similar decisions in other projects]
- [Link to technology documentation]

### Related ADRs
- ADR-XXX: [Title] - [How it relates]
- ADR-YYY: [Title] - [How it relates]

### Supersedes
- ADR-ZZZ: [Title] (if applicable)

### Superseded By
- ADR-AAA: [Title] (if applicable)

## Notes

[Any additional notes, questions for discussion, or items that need further investigation]

---

## Approval

| Role | Name | Approval | Date | Comments |
|------|------|----------|------|----------|
| Technical Lead | | ⬜ Pending | | |
| Architect | | ⬜ Pending | | |
| Product Owner | | ⬜ Pending | | |
| Security | | ⬜ Pending | | |

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 0.1 | YYYY-MM-DD | Name | Initial draft |
| 0.2 | YYYY-MM-DD | Name | Added options 2 and 3 |
| 1.0 | YYYY-MM-DD | Name | Accepted |

---

**Template Version**: 1.0  
**Based on**: [ADR template by Michael Nygard](http://thinkrelevance.com/blog/2011/11/15/documenting-architecture-decisions)