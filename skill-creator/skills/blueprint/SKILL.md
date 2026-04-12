---
name: blueprint
description: >
  Defines how. Produces blueprint.md with implementation units (vertical slices).
  Std/deep only. Includes review gate with 4 fail-closed checks.
phase: blueprint
type: internal
---

## Context

Receives:
- Path to sketch.md
- Explorer findings from start phase

Reads:
- `.docs/work/<slug>/sketch.md`
- Source code as needed for implementation planning
- Existing patterns, test infrastructure, project conventions

## Procedure

### 1. Read sketch and verify understanding

Read sketch.md completely. Verify:
- Selected approach is clear
- Success criteria are testable
- Constraints and non-goals are understood
- Blocking questions are resolved (if any remain, STOP and escalate to user)

### 2. Identify implementation units

Gate: **DESIGN-THEN-CODE** — full blueprint before any implementation.

Decompose selected approach into vertical slices. Each unit must be:
- Independently testable end-to-end
- Deliverable in a single craft subagent session
- Small enough to reason about completely

### 3. Define each implementation unit

Per unit, specify:

| Field | Content |
|---|---|
| Goal | Behavioral description (what changes for the user/system) |
| Dependencies | Other units this depends on (DAG — no circular deps) |
| Confidence | GREEN (clear path) / YELLOW (some unknowns) / RED (significant unknowns) |
| Affected systems | Files, modules, services touched |
| Approach | Behavioral description of HOW, not code |
| Test scenarios | Specific scenarios that prove this unit works |
| Verification criteria | What "done" looks like for this unit |

Hard constraints:
- Dependencies must form a DAG. No circular dependencies.
- Every unit must have at least one test scenario.
- No code in approach. Describe behavior and strategy, not implementation.

### 4. Extract durable decisions

Top-level section for cross-unit decisions that craft subagents need:
- API routes / endpoints
- DB schema changes
- Shared types / interfaces
- Auth boundaries
- Service boundaries
- Error handling strategy
- Naming conventions for new entities

These decisions are authoritative. Craft subagents follow them; they do not re-decide.

### 5. Order units

Topological sort by dependency DAG. Label execution order.
Flag any units that can be parallelized (no mutual dependencies).

### 6. Downgrade check

If total scope is simpler than expected (1-2 units, no durable decisions needed), propose downgrade to lightweight. User confirms.

### 7. Write blueprint.md

Gate: **ARTIFACT-BEFORE-HANDOFF** — persist to disk before review.

Write to `.docs/work/<slug>/blueprint.md` using template in references/blueprint-template.md.

### 8. Blueprint review gate (fail-closed)

Four checks. ALL must pass. Max 3 retry cycles before escalating to user.

**Check 1 — Dependency coherence (inline)**
- No circular dependencies
- No missing dependencies (unit references something not defined)
- Execution order respects DAG

**Check 2 — Completeness (blueprint-reviewer agent)**
- Dispatch blueprint-reviewer subagent with sketch.md + blueprint.md
- Reviewer checks: coherence, feasibility, scope coverage
- Agent returns: PASS / FAIL with specific findings

**Check 3 — No placeholders (inline)**
- Hard ban on: TBD, TODO, FIXME, "to be determined", "placeholder", "will decide later"
- Scan entire blueprint text. Any match = FAIL.

**Check 4 — Testability (inline)**
- Every unit has at least one test scenario
- Test scenarios are specific (not "test that it works")
- Verification criteria are observable/measurable

**On failure:**
- Fix identified issues
- Re-run all 4 checks
- After 3 failures, present issues to user for guidance

## Output

Produces: `.docs/work/<slug>/blueprint.md`
Gate: blueprint review (4 checks, fail-closed)
Passes to: craft

## What blueprints do NOT contain

- Implementation code
- Exact shell commands
- File-level diffs
- Line numbers for changes
- Specific library version choices (unless durable decision)

## Gotchas

- Circular dependencies are the most common failure. Draw the DAG mentally before writing.
- Blueprint-reviewer agent gets both sketch AND blueprint. It checks alignment between them.
- Durable decisions must be complete. Craft subagents cannot make cross-unit decisions.
- YELLOW/RED confidence units need explicit risk mitigation in their approach section.
- Downgrade to lightweight is a valid outcome. Not everything needs a full blueprint.
