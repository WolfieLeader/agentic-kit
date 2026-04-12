---
name: propose
description: >
  Aggregate retros into change proposals. Use after multiple retros accumulate,
  when patterns emerge across cycles, or before an evolve round. Detects
  repeated root causes, recurring themes, and stale extensions.
type: user-invokable
---

# Propose

Analyze retros, detect patterns, draft actionable change proposals.

## Context

- Reads: `.docs/work/*/retro.md` (retro files since last evolve, or filtered set)
- Reads: `.docs/evolve/` (prior proposals to check for duplicates)
- Reads: `.docs/extend/` (extension registry for absence-based tracking)
- Produces: `.docs/evolve/NNN-proposals.md`

## Procedure

1. **Scope retros.** Determine which retros to analyze:
   - Default: all retros since last evolve round
   - User may filter by: module, tag, date range, or specific slugs
   - List selected retros, confirm with user before proceeding.

2. **Extract patterns.** For each retro, pull:
   - Root cause category
   - "What went wrong" themes
   - "What went well" signals (for reinforcement)
   - Module/area affected
   - Tags and labels

3. **Detect clusters.** Flag:
   - 3+ occurrences of same root cause category across retros
   - Same module appearing in 2+ retros (fragile area)
   - Recurring "what went wrong" themes (even with different root causes)
   - "What went well" patterns worth codifying as conventions

4. **Check for duplicates.** Grep `.docs/evolve/*-proposals.md` for:
   - Same target + similar description in prior proposals
   - If duplicate found with status `proposed` or `deferred`: reference it, don't re-propose
   - If duplicate was `rejected`: note prior rejection, re-propose only if new evidence warrants it

5. **Track extension absence.** Cross-reference `.docs/extend/` against retro findings:
   - Extensions that produced zero findings across 3+ retros: surface for removal
   - Include as a proposal with target `process-change`

6. **Draft proposals.** For each pattern/cluster, create a proposal. Categorize by target:
   - `skill-change` -- modify a framework skill's procedure or output
   - `claude-md-change` -- add/update convention in CLAUDE.md
   - `code-pattern` -- extract, refactor, or standardize code
   - `test-gap` -- add missing test coverage
   - `docs-gap` -- document undocumented behavior or pipeline
   - `research-update` -- refresh stale research/reference docs
   - `process-change` -- adjust workflow, routing, or extension config

7. **Number and write.** Determine next `NNN` from existing files in `.docs/evolve/`. Write proposals file:

```yaml
---
title: Evolve Proposals Round N
date: YYYY-MM-DD
retros_analyzed: [slug1, slug2, slug3]
status: draft
---
```

Each proposal in the body:

```markdown
### Proposal 1: [title]
- **Target:** skill-change | claude-md-change | code-pattern | test-gap | docs-gap | research-update | process-change
- **Evidence:** [which retros, what pattern, occurrence count]
- **Description:** [what to change and why]
- **Acceptance criteria:** [how to know it's done]
- **Status:** proposed
```

8. **Summarize.** Print: number of retros analyzed, patterns found, proposals drafted, any duplicates skipped.

## Output

- Creates `.docs/evolve/NNN-proposals.md` with frontmatter + proposals
- Prints summary to user

## Gotchas

- Never auto-accept proposals. All start as `proposed`. Team reviews and sets `accepted` | `rejected` | `deferred` before `/evolve` runs.
- Absence-based tracking requires at least 3 retros with the extension's phase active. Do not flag extensions for removal on insufficient data.
- Lightweight FIX tasks still generate retros. Include them in analysis -- they often reveal process gaps (e.g., "FIX still needed sketch for auth-related changes").
- If no patterns emerge (all retros have unique, non-recurring issues), say so explicitly. Do not force proposals where none are warranted.
- Prior `deferred` proposals should be re-evaluated each round. If evidence strengthened, upgrade to `proposed` with new evidence.
