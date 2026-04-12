---
name: evolve
description: >
  Execute accepted proposals from a propose round. Edits skills, CLAUDE.md,
  research docs, code, and tests. Logs changes and updates changelog.
type: user-invokable
---

## Context

Receives:
- Proposals file path (or uses most recent)

Reads:
- `.docs/evolve/NNN-proposals.md` (items with `status: accepted`)
- Files targeted by each proposal
- `.docs/extend/` (if proposals target extension changes)

Produces:
- `.docs/evolve/NNN-evolve.md` (execution log)
- `.docs/CHANGELOG.md` entry

## Procedure

### 1. Load proposals

Read the specified proposals file. If no path given, use most recent `.docs/evolve/*-proposals.md`. Identify `status: accepted` items. If none, stop and inform user.

### 2. Execute in order

Dependencies flow downward -- execute by target type:

1. `claude-md-change` -- conventions first (other changes depend on them)
2. `skill-change` -- framework skill edits
3. `process-change` -- workflow/extension/routing adjustments
4. `research-update` -- refresh stale docs (Keep/Update/Replace/Delete per doc)
5. `docs-gap` -- new documentation
6. `code-pattern` -- code refactors and extractions
7. `test-gap` -- new tests (run after code changes)

For each: read target files, make the change, verify acceptance criteria, record what changed.

### 3. Handle research staleness

For `research-update` proposals, evaluate each doc:
- **Keep**: still accurate. Log "reviewed, no changes."
- **Update**: core correct, references drifted. Edit in place.
- **Replace**: misleading. Write new version, note rationale.
- **Delete**: no longer useful. Remove file, log rationale.

### 4. Update proposal statuses

Change executed items from `accepted` to `completed`. Leave `rejected` and `deferred` untouched.

### 5. Write evolve log

Create `.docs/evolve/NNN-evolve.md` (NNN matches source proposals). YAML frontmatter with `title`, `date`, `source_proposals`, `changes_made` list. Body has per-change detail: target, files modified, what changed, acceptance criteria met.

### 6. Append CHANGELOG

Add to `.docs/CHANGELOG.md` (create if missing):

```markdown
## Evolve #N -- YYYY-MM-DD
Source: proposals #NNN
Retros analyzed: slug1, slug2, slug3

Changes:
- [target] Description of change
```

### 7. Run tests

If `code-pattern` or `test-gap` proposals executed, run the test suite. Fail: revert change, mark proposal `blocked` (not `completed`), log failure reason.

## Output

Modified target files, updated proposals file (completed statuses), `.docs/evolve/NNN-evolve.md`, `.docs/CHANGELOG.md` entry.

## Gotchas

- Only execute `accepted` items. Never `proposed` or `deferred`.
- Evolve log NNN matches source proposals NNN.
- CHANGELOG is append-only. Never edit prior entries.
- Research doc deletion is recoverable via git. Always log deletion rationale.
- Test failures trigger revert + blocked status, not completed.
