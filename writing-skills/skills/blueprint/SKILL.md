---
name: blueprint
description: >
  Use when sketch is complete for std/deep tasks. Defines how to implement
  via vertical implementation units with behavioral goals.
phase: blueprint
type: internal
---

# Blueprint

Translates sketch (what/why) into implementation units (how). Each unit is a
vertical slice — testable end-to-end, described behaviorally.

## Context

- **Receives:** sketch.md path, explorer findings
- **Reads:** sketch.md, source code as needed for feasibility
- **Produces:** `.docs/work/<slug>/blueprint.md`
- **Gate:** dependency coherence, completeness, no placeholders, testability
- **Passes:** → craft (forwards blueprint.md path, explorer findings)

## Procedure

### 1. Read Sketch

Read `.docs/work/<slug>/sketch.md` end-to-end. Internalize the what and why.
Note constraints, non-goals, and open questions.

### 2. Design Implementation Units

Break the work into vertical slices. Each unit delivers testable end-to-end
behavior — not horizontal layers (e.g., "add DB column" then "add API route"
then "add UI"). A vertical slice might be "user can reset password via email"
which touches DB, API, and UI together.

### 3. Define Each Unit

For every implementation unit, specify:

- **Goal** — behavioral, not code. "Validates email format and rejects
  malformed addresses" not `if (!email.match(/regex/))`.
- **Dependencies** — which units must complete first. Must form a DAG (no
  circular deps).
- **Confidence** — GREEN (clear path), YELLOW (approach known, details
  uncertain), RED (significant unknowns).
- **Affected systems** — modules, services, files touched.
- **Approach** — behavioral description of how this unit achieves its goal.
  Describe what the system does, not what the developer types.
- **Test scenarios** — happy path, edge cases, error paths. Specific enough
  that a crafting agent knows what to test without inventing coverage.
- **Verification criteria** — how to confirm this unit works in isolation.

See `references/blueprint-template.md` for the per-unit template.

### 4. Durable Decisions

Write a dedicated section for decisions that cross implementation units:

- API routes and contracts
- Database schema changes
- Shared types and interfaces
- Auth boundaries
- Service boundaries
- Error handling strategy

These decisions bind all units. Changing them later means revisiting the
blueprint.

### 5. Write Artifact

Write `blueprint.md` with YAML frontmatter to `.docs/work/<slug>/blueprint.md`.
See `references/blueprint-template.md` for the full template.

### 6. Review Gate (fail-closed)

Run 4 checks. All must pass. Blueprint is rejected until they do.

**a. Dependency coherence (inline)**
- No circular dependencies between units
- No references to units that don't exist
- Dependency ordering is achievable

**b. Completeness (dispatched)**
- Dispatch the **blueprint-reviewer** agent with the blueprint path and
  explorer findings
- Orchestrator evaluates each finding against explorer findings and sketch
  context
- False positives rejected with reasoning. Defense decisions logged for retro.

**c. No placeholders (inline)**
- **Hard ban (auto-reject):** "TBD", "TODO", "etc.", "similar", "and so on",
  "as needed"
- **Soft ban (flag + replace):** "appropriate", "relevant", "necessary",
  "proper", "handle accordingly", "standard", "as described above"
- Scan entire blueprint text. Any hard-ban match fails the gate.

**d. Testability (inline)**
- Every unit has at least one test scenario
- Test scenarios are specific (not "test that it works")
- Error paths covered, not just happy path

### 7. Retry and Escalation

Fix gate failures and re-run. Max 3 retries before escalating to user with:
- Which checks failed
- What was attempted
- Specific blocker preventing resolution

### 8. Downgrade Check

If blueprint reveals the work is simpler than the std/deep tier implies
(single unit, trivial scope), propose downgrade to lightweight. User confirms.

## Output

`.docs/work/<slug>/blueprint.md` — durable artifact with YAML frontmatter.

## Gotchas

- **Behavior, not implementation.** "Validates email format" not
  `if (!email.match(/regex/))`. Trust the crafting agent to write code.
- **Blueprints do NOT contain:** implementation code, exact shell commands,
  file-level diffs, line-by-line instructions.
- **Vertical, not horizontal.** Each unit should be testable end-to-end. "Add
  migration" then "add model" then "add controller" is horizontal layering.
  "User can create account" is a vertical slice.
- **Placeholders are bugs.** "TBD" in a blueprint means the thinking isn't
  done. Finish the thinking or mark the unit RED with a specific unknown.
- **Circular deps = redesign.** If units form a cycle, the decomposition is
  wrong. Redesign the unit boundaries.
