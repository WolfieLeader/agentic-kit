---
name: sketch
description: >
  Use when the router dispatches to sketch phase for std/deep BUILD or FIX tasks.
  Captures what and why before implementation planning begins.
phase: sketch
type: internal
---

# Sketch

Captures what needs to happen and why before blueprint defines how. Produces a
durable artifact at `.docs/work/<slug>/sketch.md`.

## Context

- **Receives:** dispatch summary, explorer findings, user input, trace context (FIX only)
- **Reads:** source referenced by explorers, `.docs/research/` if relevant
- **Produces:** `.docs/work/<slug>/sketch.md`
- **Passes:** → blueprint (forwards sketch.md path, explorer findings)

## Procedure

### 1. Setup

Create `.docs/work/<slug>/` directory if it doesn't exist. Slug comes from
the router's dispatch summary.

### 2. Review Inputs

Read explorer findings and dispatch summary end-to-end. For FIX mode, also
read trace context (reproduction result, hypothesis, severity).

### 3. Checkpoint Summary Pattern

Use this iterative pattern to build mutual understanding with the user:

**Per round:**
1. If a question can be answered by exploring the codebase, explore instead
   of asking. Questions are expensive; assumptions are cheap to confirm.
2. Form assumptions and recommendations from codebase evidence.
3. Present checkpoint: facts + assumptions + 0-2 genuine questions (each with
   a recommended answer).
4. User scans, corrects wrong assumptions, answers questions.
5. Next round if needed, or proceed when mutual understanding reached.

**Anti-anchoring rule for judgments vs facts:**
- **Judgments** (approach choices, priorities, tradeoffs): ask the user's
  thinking BEFORE presenting your recommendation. Anchoring on the first
  option skips better alternatives.
- **Facts** (codebase state, test results, existing behavior): present your
  finding, then confirm.

### 4. Cover Sections

Use `references/sketch-template.md` for the full template.

**BUILD mode sections:**
- Problem/opportunity and motivation
- What exists today (current state)
- Affected systems
- Approaches considered (2-3): ask user's instinct first → show all options → recommend
- Constraints and non-goals
- Success criteria
- Research context (from `.docs/research/` if available)
- Open questions: blocking vs deferred

**FIX mode sections:**
- Symptoms and reproduction steps (from trace)
- Root cause hypothesis (from trace, refined through discussion)
- Blast radius and affected systems
- Constraints
- Research context
- Open questions: blocking vs deferred

### 5. Write Artifact

Write `sketch.md` with YAML frontmatter to `.docs/work/<slug>/sketch.md`.
See `references/sketch-template.md` for the frontmatter schema and section
structure.

### 6. Mark Complete

Set `status: complete` in frontmatter when mutual understanding is achieved.
"Complete" means the user and orchestrator agree on what and why — not that
every field is populated.

## Output

`.docs/work/<slug>/sketch.md` — durable artifact with YAML frontmatter.

## Gotchas

- **Ask instinct before options.** For approach choices, ask what the user is
  leaning toward BEFORE presenting alternatives. First option anchors thinking.
- **Blocking vs deferred.** Blocking questions must resolve before blueprint
  can start. Deferred questions can be answered during implementation. Mixing
  these stalls the pipeline.
- **Questions are expensive.** Most rounds should be confirmations of
  assumptions you formed from codebase evidence. Reserve questions for things
  you genuinely cannot determine.
- **"Complete" ≠ "exhaustive."** Status complete means mutual understanding
  achieved. Empty fields are fine if they're intentionally empty.
- **Don't design solutions.** Sketch captures what and why. How belongs in
  blueprint. Resist the urge to specify implementation.
