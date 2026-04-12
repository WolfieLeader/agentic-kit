# Blueprint Template

## YAML Frontmatter Schema

```yaml
---
title: [from sketch]
date: [YYYY-MM-DD]
source_sketch: [slug]
tier: standard | deep
status: draft | complete | blocked
overall_confidence: GREEN | YELLOW | RED
module: [primary module]
tags: [relevant tags]
unit_count: [number]
---
```

## Document Structure

```markdown
## Overview

[1-2 sentences summarizing the implementation approach. What the blueprint
delivers and how it maps to the sketch goals.]

## Durable Decisions

Decisions that bind all implementation units. Changing these means revisiting
the blueprint.

### [Decision Area]
- **Decision:** [what was decided]
- **Rationale:** [why this choice over alternatives]
- **Affects:** [which units this constrains]

[Repeat for each cross-cutting decision: API contracts, schema changes, shared
types, auth boundaries, service boundaries, error strategy.]

## Implementation Units

### Unit 1: [descriptive name]

**Goal:** [behavioral description — what the system does after this unit is
complete, not what code to write]

**Dependencies:** [list unit numbers/names, or "none" for starting units]

**Confidence:** GREEN | YELLOW | RED
[If YELLOW/RED: state the specific unknown]

**Affected Systems:** [modules, services, files]

**Approach:**
[Behavioral description of how this unit achieves its goal. Describe system
behavior, not developer actions. "The service validates input against the
schema and returns structured errors for invalid fields" not "create a
validation function that checks each field".]

**Test Scenarios:**
- **Happy path:** [specific scenario and expected outcome]
- **Edge case:** [boundary condition and expected behavior]
- **Error path:** [failure mode and expected handling]
[Add more scenarios as needed. Each must be specific enough that a crafting
agent can write the test without inventing the scenario.]

**Verification:** [how to confirm this unit works — which tests pass, what
behavior is observable]

---

### Unit 2: [descriptive name]

[Same structure as Unit 1. Repeat for all units.]

## Dependency Graph

[Text representation of the unit dependency DAG. Simple format:]

```
Unit 1 (no deps)
  → Unit 2
  → Unit 3
Unit 2 + Unit 3
  → Unit 4
```

## Confidence Summary

| Unit | Confidence | Risk |
|------|------------|------|
| [name] | GREEN/YELLOW/RED | [specific risk if not GREEN] |

## Open Questions (from sketch)

### Resolved During Blueprint
- [question] → [resolution]

### Deferred to Craft
- [question] → [context for when it comes up]
```

## Placeholder Rules

Enforced by the review gate. No exceptions.

### Hard Ban (auto-reject on sight)

These terms always indicate unfinished thinking:

- "TBD"
- "TODO"
- "etc."
- "similar"
- "and so on"
- "as needed"

### Soft Ban (flag, then replace with specifics)

These terms usually indicate vagueness. Flag each occurrence and replace with
the specific thing meant:

- "appropriate" → appropriate *for what*? State the criteria.
- "relevant" → relevant *to what*? Name the specific items.
- "necessary" → necessary *for what*? State the condition.
- "proper" → proper *by what standard*? State the standard.
- "handle accordingly" → handle *how*? Describe the behavior.
- "standard" → which standard? Name it.
- "as described above" → re-state or link to the specific section.
