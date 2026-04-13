---
name: propose
description: >
  Retrospective pattern synthesis into framework change proposals. Invoke ONLY
  when the user explicitly types /propose, or explicitly requests "draft
  proposals" / "synthesize retros" / "find framework patterns". Do NOT auto-
  invoke after individual retros -- the user decides when enough data has
  accumulated to warrant synthesis. Aggregates retros/diagnoses, detects
  clusters, drafts change proposals for /evolve to apply.
type: user-invocable
---

## Context

Receives:

- User request (optional scope filter: module, tag, date range)

Reads:

- `wiki/retros/*.md` (retros in scope)
- `wiki/reviews/*.md` (code review findings)
- `wiki/diagnoses/*.md` (bug investigation findings)
- `wiki/reports/*-health.md` (health check findings)
- `wiki/research/*.md` (external knowledge)
- `wiki/evolve/*-proposals.md` (prior proposals for overlap check)

Produces:

- `wiki/evolve/<slug>-proposals.md`

## Procedure

### 1. Scope

Determine which data points to analyze:

- **Default**: all since last evolve round
- **User filter**: by module, tag, or date range
- Grep YAML frontmatter for filtering across all data-point directories

### 2. Mine all data points

Read data points in scope. Grep frontmatter first, then read content of matches:

```bash
# Cluster by root cause (retros + diagnoses)
grep -r "root_cause:" wiki/{retros,diagnoses}/

# Cluster by module (all data points)
grep -r "module:" wiki/{retros,reviews,diagnoses,reports}/

# Cross-module work
grep -r "affected_modules:" wiki/retros/

# Token efficiency
grep -r "token_effort:" wiki/retros/

# Outcomes
grep -r "outcome:" wiki/retros/

# Severity patterns (diagnoses + reviews)
grep -r "severity:" wiki/diagnoses/
grep -r "p0_count:\|p1_count:" wiki/reviews/
```

Extract from content:

- Root cause categories and frequency (retros + diagnoses)
- Modules involved (all data points)
- "What went wrong" themes (retros)
- Review finding patterns (reviews)
- Bug classification patterns (diagnoses)
- Health trends across reports (reports)
- Token effort patterns per tier and module (retros)

### 3. Detect patterns

Agent judgment -- look for meaningful clusters, not mechanical counting.

- Group by root cause category -- flag 3+ occurrences
- Same module appearing in multiple retros/reviews/diagnoses
- Recurring "what went wrong" themes across different modules
- Review findings that repeat across reviews (systemic code issues)
- Bug classifications that cluster (e.g., many "environmental" = CI problem)

### 4. Overlap and effectiveness check

Grep `wiki/evolve/*-proposals.md` for prior proposals. For each prior proposal
with `status: completed`:

- **Overlap**: if a new pattern matches a prior proposal's target, don't
  re-propose the same change.
- **Effectiveness**: if the same root cause category or pattern reappears
  AFTER an evolve round addressed it, flag as **regression or insufficient fix**.
  Compare retros before vs after the evolve date. This catches evolve changes
  that didn't actually resolve the underlying problem.

Flag format in the proposals file:

```markdown
> ⚠ Pattern regression: [root_cause] was addressed in [evolve-slug] on [date]
> but reappears in [retro-slugs]. Prior fix may be insufficient.
```

### 5. Read health report

If `wiki/reports/` contains a recent health report, read it. Incorporate
WARN findings as proposal candidates (stale research, orphan artifacts,
extension health issues, CLAUDE.md gaps).

### 6. Draft proposals

Categorize each proposal by target:

| Target           | Example                                              |
| ---------------- | ---------------------------------------------------- |
| skill-change     | "Sketch should ask about cross-platform impact"      |
| claude-md-change | "Add convention about error handling in API layer"   |
| code-pattern     | "Extract shared validation into middleware"          |
| test-gap         | "Add integration tests for queue consumer"           |
| docs-gap         | "Document the deployment pipeline"                   |
| research-update  | "React docs are stale, need refresh"                 |
| process-change   | "Lightweight FIX needs sketch for auth-related bugs" |

Per-proposal format:

```markdown
### Proposal N: [title]

- **Target:** [category]
- **Evidence:** [which data points, what pattern]
- **Description:** [what to change and why]
- **Acceptance criteria:** [how to know it's done]
- **Status:** proposed
```

### 7. Write proposals file

Generate slug: `YYMMDD-NNN-kebab-topic` (same convention as all artifacts).
Scan `wiki/evolve/` for highest NNN today, increment.

Write to `wiki/evolve/<slug>-proposals.md`:

```yaml
---
title: Evolve Proposals — [topic]
date: [YYYY-MM-DD]
retros_analyzed: [list of slugs]
reviews_analyzed: [list of slugs]
diagnoses_analyzed: [list of slugs]
status: draft
---
```

## Output

`wiki/evolve/<slug>-proposals.md` with all proposals.

## Gotchas

- No minimum retro count -- user invokes when ready.
- Pattern detection is agent judgment, not algorithm. Meaningful clusters matter, not string matches.
- Always check for prior proposals to avoid duplicates.
- Mine ALL data-point directories, not just retros.
- 3+ occurrences of a root cause category is a signal, not a threshold. Use judgment.
- Health findings are inputs, not re-run. `/health` does the diagnostics; `/propose` reads the results.
- Recurring patterns after evolve = insufficient fix, not "the framework hasn't learned yet." Flag regressions explicitly.
