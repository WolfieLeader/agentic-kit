# Blueprint Template

## YAML Frontmatter Schema

```yaml
---
title: Add notification system           # matches sketch title
date: 2026-04-11                         # creation date
source_sketch: 260411-001-notifications  # slug reference to sketch
tier: standard                           # standard | deep
status: draft                            # draft | complete | blocked
overall_confidence: GREEN                # GREEN | YELLOW | RED
module: notifications                    # primary module affected
tags: [email, queue, workers]            # searchable tags
unit_count: 4                            # number of implementation units
---
```

Fields used by grep-first retrieval: `title`, `module`, `tags`, `source_sketch`.

---

## Blueprint Structure

### Durable Decisions

Cross-unit decisions that all craft subagents must follow. Authoritative -- subagents do not re-decide.

Include sections as applicable: API Routes/Endpoints, DB Schema Changes, Shared Types/Interfaces, Auth Boundaries, Service Boundaries, Error Handling Strategy, Naming Conventions.

---

### Implementation Units

Units listed in execution order (topological sort of dependency DAG).

---

## Unit Template

### Unit N: [Descriptive Name]

**Goal**: Behavioral description of what changes for user/system. Not code -- behavior.

**Dependencies**: Unit X, Unit Y (or "none" for first unit)

**Confidence**: GREEN | YELLOW | RED
- GREEN: Clear path. YELLOW: Some unknowns, mitigation identified. RED: Significant unknowns, spike may be needed.

**Affected Systems**:
- `path/to/module` -- what changes

**Approach**:
Behavioral description of strategy and sequence, not code.
1. First behavioral step
2. Second behavioral step

> For YELLOW/RED confidence: state the unknown and its mitigation strategy.

**Test Scenarios (in priority order -- craft processes one-at-a-time)**:

| Scenario | Given | When | Then |
|---|---|---|---|
| Happy path | precondition | action | expected result |
| Edge case | precondition | action | expected result |
| Error case | precondition | action | expected error handling |

**Verification Criteria**:
- [ ] Criterion 1 -- observable/measurable
- [ ] Criterion 2 -- observable/measurable

---

## Dependency DAG

```
Unit 1 (no deps)
  --> Unit 2 (depends on 1)
  --> Unit 3 (depends on 1)
        --> Unit 4 (depends on 2, 3)
```

**Parallelizable**: Units [2, 3] can run concurrently.

---

## Review Checklist

All must pass. Filled by review gate.

- [ ] **Dependency coherence**: No circular deps, no missing deps, order respects DAG
- [ ] **Completeness**: Blueprint covers all sketch success criteria
- [ ] **No placeholders**: Zero hard-ban terms (TBD, TODO, FIXME, "to be determined", "placeholder", "will decide later")
- [ ] **Testability**: Every unit has specific, measurable test scenarios

**Review attempts**: 0/3
**Review notes**: (findings from each attempt)

---

## Placeholder Rules

### Hard Ban (auto-reject)
"TBD", "TODO", "FIXME", "to be determined", "placeholder", "will decide later"

### Soft Ban (flag, then replace with specifics)
"appropriate", "relevant", "necessary", "proper", "handle accordingly", "standard", "as described above" -- replace each with the specific thing meant.
