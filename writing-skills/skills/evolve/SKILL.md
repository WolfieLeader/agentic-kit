---
name: evolve
description: >
  Use when proposals have been reviewed and accepted. Executes accepted
  proposals and logs changes to CHANGELOG.md.
type: user-invokable
---

# Evolve

Executes accepted proposals from `/propose`. Modifies target files, logs
execution, and appends to CHANGELOG. Only touches accepted items — skip
proposed, rejected, and deferred.

## Context

- **Receives:** proposals file path (or uses most recent)
- **Reads:** `.docs/evolve/NNN-proposals.md`, files targeted by accepted proposals
- **Produces:** `.docs/evolve/NNN-evolve.md`, updated target files, `.docs/CHANGELOG.md` entry

## Procedure

### 1. Load Proposals

Read the proposals file. If no path given, use the most recent
`.docs/evolve/*-proposals.md`. Identify items with `status: accepted`.

### 2. Execute by Target

For each accepted proposal:

| Target           | Action                                          |
|------------------|-------------------------------------------------|
| skill-change     | Edit the relevant skill's SKILL.md or references/ |
| claude-md-change | Edit CLAUDE.md                                  |
| code-pattern     | Implement the code change                       |
| test-gap         | Write the missing tests                         |
| docs-gap         | Write or update documentation                   |
| research-update  | Handle staleness (see below)                    |
| process-change   | Modify relevant skill or framework behavior     |

**Research staleness handling** — judgment-based per document:

- **Keep:** still accurate, no changes needed.
- **Update:** core correct, references drifted — update references.
- **Replace:** misleading — write better replacement.
- **Delete:** no longer useful (git preserves history).

### 3. Write Execution Log

Write `.docs/evolve/NNN-evolve.md` with YAML frontmatter:

```yaml
---
title: Evolve Execution Round [N]
date: [YYYY-MM-DD]
source_proposals: [NNN]
changes_made:
  - target: [category]
    description: [what changed]
    files: [list of modified files]
---
```

### 4. Append CHANGELOG Entry

Append to `.docs/CHANGELOG.md` (create if missing):

```markdown
## Evolve #N — YYYY-MM-DD
Source: proposals #N
Retros analyzed: [slug list]

Changes:
- [target] Description of change
```

### 5. Update MAP.md

If any changes affect project structure or modules, update MAP.md.
Clean up stale MAP.md entries if noticed.

## Output

`.docs/evolve/NNN-evolve.md` + `.docs/CHANGELOG.md` entry + modified target files.

## Gotchas

- Only execute accepted proposals — skip proposed/rejected/deferred.
- Staleness handling is judgment-based — Keep/Update/Replace/Delete per
  research document. No blanket approach.
- CHANGELOG is append-only — never edit prior entries.
- Git workflow after evolve is user's choice — don't suggest it.
