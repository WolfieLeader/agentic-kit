---
name: propose
description: >
  Aggregates retros, detects recurring patterns, and drafts change proposals.
  Pattern detection is agent judgment -- look for meaningful clusters.
type: user-invokable
---

## Context

Receives:
- User request (optional scope filter: module, tag, date range)

Reads:
- `.docs/work/*/retro.md` (retros in scope)
- `.docs/evolve/*-proposals.md` (prior proposals for overlap check)
- `.docs/extend/` (extension manifests for health check)

Produces:
- `.docs/evolve/NNN-proposals.md`

## Procedure

### 1. Scope

Determine which retros to analyze:

- **Default**: all since last evolve round
- **User filter**: by module, tag, or date range
- Grep `.docs/work/*/retro.md` YAML frontmatter for filtering

### 2. Analyze retros

Read all retros in scope. Grep frontmatter first, then read content of matches:

```bash
# Cluster by root cause (FIX retros)
grep -r "root_cause:" .docs/work/*/retro.md

# Cluster by module
grep -r "module:" .docs/work/*/retro.md

# Cross-module work
grep -r "affected_modules:" .docs/work/*/retro.md

# Token efficiency
grep -r "token_effort:" .docs/work/*/retro.md

# Outcomes
grep -r "outcome:" .docs/work/*/retro.md
```

Extract from content:
- Root cause categories and frequency
- Modules involved (including cross-module via `affected_modules:`)
- "What went wrong" themes
- Action items (completed and outstanding)
- Token effort patterns per tier and module

### 3. Detect patterns

Agent judgment -- look for meaningful clusters, not mechanical counting.

- Group by root cause category -- flag 3+ occurrences
- Same module appearing in multiple retros
- Recurring "what went wrong" themes across different modules
- Clusters of related issues

### 4. Overlap check

Grep `.docs/evolve/*-proposals.md` for prior proposals. Avoid duplicates. If a prior proposal covers the same ground, reference it instead of re-proposing.

### 5. Draft proposals

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
- **Evidence:** [which retros, what pattern]
- **Description:** [what to change and why]
- **Acceptance criteria:** [how to know it's done]
- **Status:** proposed
```

### 6. Check extension health

Review `.docs/extend/` manifests against analyzed retros. Flag extensions with zero findings across 3+ retros -- candidates for removal (unused extensions waste tokens every run).

### 7. Lint research docs

Scan `.docs/research/` for health issues:
- **Stale**: `date_updated` older than 90 days -- flag for review or refresh
- **Orphaned**: no retro or sketch references the doc (grep `module:` and `tags:` against work artifacts) -- candidate for archival
- **Contradictions**: multiple research docs covering overlapping topics with conflicting claims -- flag for resolution

### 8. Detect token efficiency patterns

Grep retro frontmatter for `token_effort:` values. Flag:
- Lightweight tasks consistently rated `high` -- routing problem (should be standard)
- Specific modules with disproportionate `high` ratings -- complexity signal
- `high` effort correlated with specific root cause categories -- systemic issue

### 9. Write proposals file

Determine next NNN: scan `.docs/evolve/` for highest existing number + 1.

Write to `.docs/evolve/NNN-proposals.md`:

```yaml
---
title: Evolve Proposals Round [N]
date: [YYYY-MM-DD]
retros_analyzed: [list of slugs]
status: draft
---
```

## Output

`.docs/evolve/NNN-proposals.md` with all proposals and extension health findings.

## Gotchas

- No minimum retro count -- user invokes when ready.
- Pattern detection is agent judgment, not algorithm. Meaningful clusters matter, not string matches.
- Always check for prior proposals to avoid duplicates.
- Extension health check flags extensions with zero findings across 3+ retros as removal candidates.
- 3+ occurrences of a root cause category is a signal, not a threshold. Use judgment.
