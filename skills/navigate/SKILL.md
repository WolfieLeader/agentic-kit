---
name: navigate
description: >
  Search patterns and exclusion rules for `wiki/` and source code. Invoke ONLY
  when another skill or explorer needs to plan a grep/glob strategy and wants
  canonical query recipes per artifact type. Do NOT invoke for general coding
  help or to answer user search intents directly -- users search directly, this
  skill exists for internal callers that grep heavily. The skill is a thin
  router; the real content lives in references/navigation-guide.md.
type: internal
---

# Navigate

Consolidates search patterns so skills and explorers do not reinvent grep strategies. Cuts noise (build dirs, lockfiles, `.git/`) and standardizes frontmatter-first queries across the framework.

## Context

Reads:

- `references/navigation-guide.md` -- the canonical content
- Optional: project-level `wiki/NAVIGATION.md` if it exists (project overrides)

## Procedure

1. Read `references/navigation-guide.md`.
2. If `wiki/NAVIGATION.md` exists in the project, read it too -- project-level overrides or additions take precedence.
3. Identify what the caller needs:
   - **Artifact search** (`wiki/<type>/`) -- use frontmatter-first recipes (§ Artifact queries).
   - **Source code search** -- apply exclusion patterns (§ Exclusion list) to scope grep.
   - **Cross-artifact relationships** -- use edge traversal (§ Frontmatter graph).
4. Return a composed search plan: exact grep/glob invocation with paths + exclusions, plus expected output shape. Do not execute unless the caller asks for execution.

## Output

A search plan the caller can execute with Grep/Glob/Bash. Shape:

```
Query: <purpose>
Command: <exact grep/glob invocation>
Expected: <what a match looks like — frontmatter hit, line match, file path>
Exclusions applied: <which patterns from guide>
```

## Gotchas

- `wiki/` IS tracked in the repo. Source-code searches must explicitly exclude it (`--glob='!wiki/**'`) or they pick up artifacts as false positives.
- `.git/` is NOT excluded by ripgrep's default. Add `--glob='!.git/**'` when broad-searching.
- Frontmatter matching should anchor (`^module: <name>$`). Unanchored match (`module: auth`) hits `module: auth-middleware` too.
- If your query isn't covered by the guide, add the pattern to the guide rather than inventing an inline one -- the whole point is that patterns accumulate in one place.
- `wiki/NAVIGATION.md` (project-level) is optional. If missing, use the framework guide alone. If present, merge -- project wins on conflict.
