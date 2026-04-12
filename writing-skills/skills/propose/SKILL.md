---
name: propose
description: >
  Use when ready to analyze retros and identify improvement patterns.
  Aggregates retros, detects patterns, drafts change proposals.
type: user-invokable
---

# Propose

Mines retros for recurring patterns and drafts actionable change proposals.
Pattern detection is agent judgment — look for meaningful clusters, not
mechanical counting.

## Context

- **Receives:** user request (optional scope filter)
- **Reads:** `.docs/work/*/retro.md`, `.docs/evolve/` (prior proposals)
- **Produces:** `.docs/evolve/NNN-proposals.md`

## Procedure

### 1. Scope

Determine which retros to analyze:

- **Default:** all since last evolve.
- **User filter:** by module, tag, or date range.
- Grep `.docs/work/*/retro.md` YAML frontmatter for filtering.

### 2. Analyze Retros

Read all retros in scope. Extract:

- Root cause categories
- Modules involved
- "What went wrong" themes
- Action items (completed and outstanding)

### 3. Detect Patterns

- Group by root cause category — flag 3+ occurrences.
- Same module appearing in multiple retros.
- Recurring "what went wrong" themes.
- Clusters of related issues across different modules.

### 4. Overlap Check

Grep `.docs/evolve/*-proposals.md` for prior proposals. Avoid duplicates.
If a prior proposal covers the same ground, reference it instead of
re-proposing.

### 5. Draft Proposals

Categorize each proposal by target:

| Target            | Example                                                   |
|-------------------|-----------------------------------------------------------|
| skill-change      | "Sketch should ask about cross-platform impact"           |
| claude-md-change  | "Add convention about error handling in API layer"        |
| code-pattern      | "Extract shared validation into middleware"               |
| test-gap          | "Add integration tests for queue consumer"                |
| docs-gap          | "Document the deployment pipeline"                        |
| research-update   | "React docs are stale, need refresh"                      |
| process-change    | "Lightweight FIX still needs sketch for auth-related bugs"|

Per-proposal format:

```markdown
### Proposal N: [title]
- **Target:** [category]
- **Evidence:** [which retros, what pattern]
- **Description:** [what to change and why]
- **Acceptance criteria:** [how to know it's done]
- **Status:** proposed
```

### 6. Check Extension Health

Flag extensions that produce no findings across analyzed retros. These are
candidates for removal — unused extensions waste tokens every run.

### 7. Write Proposals File

Determine next NNN: scan `.docs/evolve/` for highest existing number + 1.

Write to `.docs/evolve/NNN-proposals.md` with YAML frontmatter:

```yaml
---
title: Evolve Proposals Round [N]
date: [YYYY-MM-DD]
retros_analyzed: [list of slugs]
status: draft
---
```

## Output

`.docs/evolve/NNN-proposals.md`.

## Gotchas

- No minimum retro count — user invokes when ready.
- Pattern detection is agent judgment, not algorithm. Look for meaningful
  clusters, not just string matches.
- Always check for prior proposals to avoid duplicates.
- Extension health check is valuable — unused extensions waste tokens
  every run.
