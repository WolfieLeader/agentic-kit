---
name: propose
description: >
  Use when: user wants to review what went well/wrong across recent tasks,
  find recurring patterns, or identify framework improvements. Aggregates all
  data points, detects clusters, drafts change proposals. Invoke after several tasks.
type: user-invokable
---

## Context

Receives:
- User request (optional scope filter: module, tag, date range)

Reads:
- `.docs/retros/*.md` (retros in scope)
- `.docs/reviews/*.md` (code review findings)
- `.docs/diagnoses/*.md` (bug investigation findings)
- `.docs/reports/*-health.md` (health check findings)
- `.docs/research/*.md` (external knowledge)
- `.docs/evolve/*-proposals.md` (prior proposals for overlap check)

Produces:
- `.docs/evolve/<slug>-proposals.md`

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
grep -r "root_cause:" .docs/{retros,diagnoses}/

# Cluster by module (all data points)
grep -r "module:" .docs/{retros,reviews,diagnoses,reports}/

# Cross-module work
grep -r "affected_modules:" .docs/retros/

# Token efficiency
grep -r "token_effort:" .docs/retros/

# Outcomes
grep -r "outcome:" .docs/retros/

# Severity patterns (diagnoses + reviews)
grep -r "severity:" .docs/diagnoses/
grep -r "p0_count:\|p1_count:" .docs/reviews/
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

### 4. Overlap check

Grep `.docs/evolve/*-proposals.md` for prior proposals. Avoid duplicates.
If a prior proposal covers the same ground, reference it instead of re-proposing.

### 5. Read health report

If `.docs/reports/` contains a recent health report, read it. Incorporate
WARN findings as proposal candidates (stale research, orphan artifacts,
extension health issues, CLAUDE.md gaps).

### 6. Draft proposals

Categorize each proposal by target:

| Target | Example |
|---|---|
| skill-change | "Sketch should ask about cross-platform impact" |
| claude-md-change | "Add convention about error handling in API layer" |
| code-pattern | "Extract shared validation into middleware" |
| test-gap | "Add integration tests for queue consumer" |
| docs-gap | "Document the deployment pipeline" |
| research-update | "React docs are stale, need refresh" |
| process-change | "Lightweight FIX needs sketch for auth-related bugs" |

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
Scan `.docs/evolve/` for highest NNN today, increment.

Write to `.docs/evolve/<slug>-proposals.md`:

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

`.docs/evolve/<slug>-proposals.md` with all proposals.

## Gotchas

- No minimum retro count -- user invokes when ready.
- Pattern detection is agent judgment, not algorithm. Meaningful clusters matter, not string matches.
- Always check for prior proposals to avoid duplicates.
- Mine ALL data-point directories, not just retros.
- 3+ occurrences of a root cause category is a signal, not a threshold. Use judgment.
- Health findings are inputs, not re-run. `/health` does the diagnostics; `/propose` reads the results.
