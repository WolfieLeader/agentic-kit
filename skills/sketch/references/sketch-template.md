# Sketch Template

## YAML Frontmatter Schema

```yaml
---
title: Add notification system           # descriptive title
date: 2026-04-11                         # creation date
type: build                              # build | fix
tier: standard                           # standard | deep
status: draft                            # draft | complete
module: notifications                    # primary module affected
tags: [email, queue, workers]            # searchable tags
affected_systems: [api, worker, database]
---
```

Fields used by grep-first retrieval: `title`, `module`, `tags`, `type`, `tier`.

## BUILD Mode Template

### Problem / Opportunity
What problem or opportunity? State in user/business terms, not implementation.

### Why Now
Trigger event, dependency, deadline, or pain threshold making this timely.

### What Exists Today
Current state: existing behavior, workarounds, partial implementations.
File references: `path/to/relevant/file.ext`

### Affected Systems

| System | Impact | Confidence |
|---|---|---|
| system-name | what changes | HIGH/MED/LOW |

### Approaches Considered
> **Anti-anchoring**: User's instinct was captured before presenting these.

#### Approach A: [Name]
Summary, pros, cons, effort (S/M/L), risk (LOW/MED/HIGH).

#### Approach B: [Name]
(same structure)

**Selected**: Approach [X] -- [rationale linking to user's instinct and tradeoff analysis]

### Constraints and Non-Goals
**Constraints** (must respect):
- constraint 1

**Non-goals** (explicitly out of scope):
- non-goal 1

### Success Criteria
Testable, observable. Each verifiable in verify phase.
1. [ ] criterion -- how to verify
2. [ ] criterion -- how to verify

### Research Context
From `.docs/research/` if relevant. Note staleness if older than 30 days.
- `research-file.md` -- finding (dated YYYY-MM-DD)

### Open Questions
**Blocking** (must resolve before blueprint):
1. Question -- recommended answer -- rationale

**Deferred** (logged, does not block):
1. Question -- when to revisit

## FIX Mode Template

### Symptoms Observed
What the user/system reported. Direct quotes or exact error messages.
```
exact error output or symptom description
```

### Reproduction Steps
From trace: steps, expected vs actual, environment details.
**Reproduction status**: Reproduced / Partial / Not reproduced

### Root Cause Hypothesis
Hypothesis, confidence (HIGH/MED/LOW), supporting evidence, what would refute.

### Blast Radius
| Area | Risk | Notes |
|---|---|---|
| area | HIGH/MED/LOW | specifics |

### Affected Systems
| System | Impact | Confidence |
|---|---|---|
| system-name | what's broken / what fix touches | HIGH/MED/LOW |

### Constraints
- constraint (e.g., cannot change public API, must maintain backward compat)

### Research Context
Prior research, related bugs, similar fixes.
- `research-file.md` -- finding (dated YYYY-MM-DD)

### Open Questions
**Blocking** (must resolve before blueprint):
1. Question -- recommended answer -- rationale

**Deferred** (logged, does not block):
1. Question -- when to revisit
