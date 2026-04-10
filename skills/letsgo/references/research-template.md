# Research Document Template

Use this template when writing `.docs/research/<topic>.md`.

Research files are **living documents** — reusable topic knowledge not tied to any work item. Agents check these before doing fresh research and update them when they learn something new.

## Template

```markdown
---
title: "[Topic title]"
date_created: YYYY-MM-DD
date_updated: YYYY-MM-DD
module: [primary module this topic relates to]
tags: [searchable, keywords, for, grep]
---

## Summary

[What this topic is and why it matters to this project. 2-3 sentences.]

## Key Findings

- [Concrete finding with source context]
- [Concrete finding with source context]

## How We Use It

[How this topic integrates with our codebase. Patterns, conventions, existing files.]

## Gotchas

- [Pitfall or non-obvious behavior — what went wrong or could go wrong]
- [Version-specific quirk, rate limit, or constraint]

## Sources

- [Source name] ([date accessed]) — [what it covers]
- [Source name] ([date accessed]) — [what it covers]

## Open Questions

- [Unresolved question or area not yet investigated]
```

## Writing Rules

1. **Topic-scoped, not work-scoped.** One file per topic (e.g., `stripe.md`, not `250410-stripe-webhook-research.md`). Work-specific findings belong in retro.md.
2. **Update, don't duplicate.** If `stripe.md` exists and you learn something new about Stripe, update the existing file. Bump `date_updated`.
3. **Sources with dates.** Every finding should be traceable to a source. External sources need access dates — APIs change.
4. **No placeholders.** Every section has real content or is omitted entirely. Hard-ban: "TBD", "TODO", "etc.", "and so on".
5. **Freshness is implicit.** `date_updated` tells agents how fresh the content is. No separate staleness field — agents compare `date_updated` against their needs.
6. **Gotchas are gold.** The most valuable part of a research file is what tripped us up. If you have nothing else, document the gotchas.
7. **Repo-relative paths only.** When referencing project files, use relative paths.
