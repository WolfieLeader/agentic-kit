# Sketch Template

## YAML Frontmatter Schema

```yaml
---
title: [descriptive title]
date: [YYYY-MM-DD]
type: build | fix
tier: standard | deep
status: draft | complete
module: [primary module]
tags: [relevant tags]
affected_systems: [systems involved]
---
```

## BUILD Mode Sections

```markdown
## Problem / Opportunity

[What problem does this solve? What opportunity does it create?]

## Motivation

[Why now? What triggered this work? Business context, user feedback, tech debt.]

## Current State

[What exists today. How the affected area works right now. Reference specific
files/modules from explorer findings.]

## Affected Systems

[List systems, modules, services that this work touches or depends on.]

## Approaches Considered

### Option A: [name]
- **Description:** [brief description]
- **Pros:** [advantages]
- **Cons:** [disadvantages]
- **Effort:** [relative estimate]

### Option B: [name]
- **Description:** [brief description]
- **Pros:** [advantages]
- **Cons:** [disadvantages]
- **Effort:** [relative estimate]

### Recommended: [Option X]
[Reasoning for recommendation. Reference user's stated preference if captured
during checkpoint discussion.]

## Constraints

[Hard constraints: backward compatibility, performance budgets, API contracts,
deployment requirements.]

## Non-Goals

[What this work explicitly does NOT cover. Prevents scope creep during blueprint
and craft.]

## Success Criteria

[Observable outcomes that mean this work is done. Prefer measurable over
subjective.]

## Research Context

[Relevant findings from .docs/research/ if any. External references, prior art,
team decisions.]

## Open Questions

### Blocking (must resolve before blueprint)
- [question — recommended answer if available]

### Deferred (can resolve during implementation)
- [question — context for when it comes up]
```

## FIX Mode Sections

```markdown
## Symptoms

[What the user/system observes. Error messages, wrong behavior, visual glitches.
Quoted exact where possible.]

## Reproduction Steps

[From trace phase. Exact steps to trigger the bug. Include environment details
if relevant.]

## Root Cause Hypothesis

[From trace, refined through sketch discussion. Stay directional — "likely X
because Y" not "the cause is X".]

## Blast Radius

[What else could be affected by this bug or its fix. Other features, services,
data integrity.]

## Affected Systems

[Systems, modules, services involved in both the bug and the fix path.]

## Constraints

[Hard constraints: backward compatibility, data migration, rollback
requirements, deployment windows.]

## Research Context

[Relevant findings from .docs/research/ if any. Similar past bugs, known
fragile areas.]

## Open Questions

### Blocking (must resolve before blueprint)
- [question — recommended answer if available]

### Deferred (can resolve during implementation)
- [question — context for when it comes up]
```
