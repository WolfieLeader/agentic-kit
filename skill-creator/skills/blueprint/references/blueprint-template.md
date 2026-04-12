# Blueprint Template

## YAML Frontmatter Schema

```yaml
---
title: Add notification system           # matches sketch title
date: 2026-04-11                         # creation date
source_sketch: 260411-notifications      # slug reference to sketch
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

Cross-unit decisions that all craft subagents must follow. Authoritative — subagents do not re-decide.

#### API Routes / Endpoints

```
METHOD /path — purpose
METHOD /path — purpose
```

#### DB Schema Changes

```sql
-- migration description
ALTER TABLE ...
CREATE TABLE ...
```

#### Shared Types / Interfaces

```
TypeName { field: type, field: type }
```

#### Auth Boundaries

- What requires authentication
- What is public
- Permission model changes

#### Service Boundaries

- Which service owns what
- Cross-service communication pattern

#### Error Handling Strategy

- Error format, error codes, retry policy

#### Naming Conventions

- New entity naming pattern
- File naming pattern

---

### Implementation Units

Units listed in execution order (topological sort of dependency DAG).

---

## Unit Template

### Unit N: [Descriptive Name]

**Goal**: Behavioral description of what changes for user/system. Not code — behavior.

**Dependencies**: Unit X, Unit Y (or "none" for first unit)

**Confidence**: GREEN | YELLOW | RED

- GREEN: Clear path, no unknowns
- YELLOW: Some unknowns, mitigation identified
- RED: Significant unknowns, spike may be needed

**Affected Systems**:
- `path/to/module` — what changes
- `path/to/other` — what changes

**Approach**:

Behavioral description of how this unit achieves its goal. Describe strategy and sequence, not code.

1. First behavioral step
2. Second behavioral step
3. Third behavioral step

> For YELLOW/RED confidence: state the unknown and its mitigation strategy.

**Test Scenarios**:

| Scenario | Given | When | Then |
|---|---|---|---|
| Happy path | precondition | action | expected result |
| Edge case | precondition | action | expected result |
| Error case | precondition | action | expected error handling |

**Verification Criteria**:

- [ ] Criterion 1 — observable/measurable
- [ ] Criterion 2 — observable/measurable

---

## Dependency DAG

Visual representation of unit dependencies. Use for quick reference.

```
Unit 1 (no deps)
  └── Unit 2 (depends on 1)
  └── Unit 3 (depends on 1)
        └── Unit 4 (depends on 2, 3)
```

**Parallelizable**: Units [2, 3] can run concurrently.

---

## Review Checklist

Filled by review gate. All must pass.

- [ ] **Dependency coherence**: No circular deps, no missing deps, order respects DAG
- [ ] **Completeness**: Blueprint covers all sketch success criteria
- [ ] **No placeholders**: Zero instances of TBD, TODO, FIXME, "to be determined", "placeholder"
- [ ] **Testability**: Every unit has test scenarios; scenarios are specific and measurable

**Review attempts**: 0/3
**Review notes**: (findings from each attempt)
