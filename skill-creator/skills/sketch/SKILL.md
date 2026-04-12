---
name: sketch
description: >
  Captures what and why. One skill, two modes (BUILD/FIX). Produces sketch.md.
  Std/deep only. Uses checkpoint summary pattern for collaborative refinement.
phase: sketch
type: internal
---

## Context

Receives:
- Dispatch summary from start
- Explorer findings (codebase analysis)
- User input (requirements or problem description)
- Trace context (FIX mode only: reproduction, hypothesis, severity)

Reads:
- Source code referenced by explorers
- `.docs/research/` for prior research context
- Existing `.docs/work/` sketches for pattern reference

## Procedure

### 1. Determine mode

- User request is BUILD (new feature, enhancement) -> BUILD mode
- User request is FIX (from trace) -> FIX mode

### 2. Explore before drafting

Gate: **EXPLORE-BEFORE-IMPLEMENT** — before writing any sketch content, verify your understanding by reading actual source.

- Read files referenced by explorer findings
- Identify affected systems, entry points, data flow
- Note existing patterns, conventions, test structure
- If question answerable by exploring codebase, explore instead of asking user

### 3. Checkpoint summary loop

Repeat until sketch is complete:

**A. Form assumptions from evidence**
- Read code, tests, configs. Extract facts.
- Form assumptions where evidence is partial.

**B. Present checkpoint**
- Facts discovered (with file:line references)
- Assumptions formed (clearly labeled)
- 0-2 genuine questions (with recommended answers)

**C. Anti-anchoring rule for judgments**
- For approach choices, priorities, tradeoffs: ask user's thinking BEFORE presenting your recommendation
- For factual confirmations: present then confirm
- Example: "Before I share approaches, what's your instinct on build-vs-buy here?"

**D. User responds**
- User corrects assumptions, answers questions
- Incorporate corrections, proceed to next round or finalize

### 4. Draft sketch

Gate: **DESIGN-THEN-CODE** — full sketch before any implementation thinking.

**BUILD mode sections** (see references/sketch-template.md):
1. Problem/opportunity
2. Why now
3. What exists today
4. Affected systems
5. Approaches considered (2-3 minimum)
6. Constraints and non-goals
7. Success criteria
8. Research context
9. Blocking vs deferred open questions

**FIX mode sections** (see references/sketch-template.md):
1. Symptoms observed
2. Reproduction steps (from trace)
3. Root cause hypothesis
4. Blast radius
5. Affected systems
6. Constraints
7. Research context
8. Blocking vs deferred open questions

### 5. Approaches (BUILD mode)

Gate: **OPTIONS-THEN-RECOMMEND**

1. Ask user's instinct first (anti-anchoring)
2. Present ALL viable approaches (minimum 2, typically 3)
3. Per approach: summary, pros, cons, effort estimate, risk
4. THEN recommend with rationale
5. User selects or modifies

### 6. Resolve blocking questions

- Blocking questions must be answered before passing to blueprint
- Deferred questions get logged but don't block
- If user cannot answer a blocking question, note the uncertainty and its implications

### 7. Write sketch.md

Gate: **ARTIFACT-BEFORE-HANDOFF** — persist to disk before next phase.

Write to `.docs/work/<slug>/sketch.md` using the template in references/sketch-template.md.

Slug: kebab-case derived from feature/fix name. Keep under 40 chars.

### 8. Confirm with user

Present sketch summary. User confirms or requests changes. Iterate if needed.

## Output

Produces: `.docs/work/<slug>/sketch.md`
Passes to: blueprint

## Gotchas

- Never present approaches before asking user's instinct. Anti-anchoring is critical.
- Sketch is what/why, not how. No implementation details, no code, no file paths for changes.
- Blocking questions actually block. Do not proceed to blueprint with unresolved blockers.
- FIX mode must reference trace findings. Do not re-investigate from scratch.
- If `.docs/research/` contains stale info, note staleness in Research context section.
