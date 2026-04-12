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

---

## BUILD Mode Template

### Problem / Opportunity

What problem are we solving or what opportunity are we capturing?
State in user/business terms, not implementation terms.

### Why Now

What makes this timely? Why not last sprint or next quarter?
- Trigger event, dependency, deadline, or user pain threshold

### What Exists Today

Current state of the system relevant to this change.
- Existing behavior, workarounds, partial implementations
- File references: `path/to/relevant/file.ext`

### Affected Systems

| System | Impact | Confidence |
|---|---|---|
| system-name | what changes | HIGH/MED/LOW |

### Approaches Considered

> **Anti-anchoring**: User's instinct was captured before presenting these.

#### Approach A: [Name]

**Summary**: One-sentence description.

| Dimension | Assessment |
|---|---|
| Pros | bullet list |
| Cons | bullet list |
| Effort | S/M/L with rationale |
| Risk | LOW/MED/HIGH with specifics |

#### Approach B: [Name]

(same structure)

#### Approach C: [Name] (if applicable)

(same structure)

**Selected**: Approach [X] — [rationale linking to user's stated instinct and tradeoff analysis]

### Constraints and Non-Goals

**Constraints** (must respect):
- constraint 1
- constraint 2

**Non-goals** (explicitly out of scope):
- non-goal 1
- non-goal 2

### Success Criteria

Testable, observable criteria. Each must be verifiable in verify phase.

1. [ ] criterion — how to verify
2. [ ] criterion — how to verify
3. [ ] criterion — how to verify

### Research Context

Prior research from `.docs/research/` relevant to this sketch.
Note staleness if research is older than 30 days.

- `research-file.md` — relevant finding (dated YYYY-MM-DD)

### Open Questions

**Blocking** (must resolve before blueprint):
1. Question — recommended answer — rationale

**Deferred** (logged, does not block):
1. Question — when to revisit

---

## FIX Mode Template

### Symptoms Observed

What the user/system reported. Direct quotes or exact error messages.

```
exact error output or symptom description
```

### Reproduction Steps

From trace phase. Include:
1. Step to reproduce
2. Expected result
3. Actual result
4. Environment details if relevant

**Reproduction status**: Reproduced / Partial / Not reproduced

### Root Cause Hypothesis

From trace phase. State:
- Hypothesis
- Confidence: HIGH / MED / LOW
- Evidence supporting
- What would refute

### Blast Radius

What else could be affected by this bug or its fix?

| Area | Risk | Notes |
|---|---|---|
| area | HIGH/MED/LOW | specifics |

### Affected Systems

| System | Impact | Confidence |
|---|---|---|
| system-name | what's broken / what fix touches | HIGH/MED/LOW |

### Constraints

- constraint 1 (e.g., cannot change public API)
- constraint 2 (e.g., must maintain backward compat)

### Research Context

Prior research, related bugs, similar fixes.

- `research-file.md` — relevant finding (dated YYYY-MM-DD)

### Open Questions

**Blocking** (must resolve before blueprint):
1. Question — recommended answer — rationale

**Deferred** (logged, does not block):
1. Question — when to revisit
