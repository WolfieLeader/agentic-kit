---
name: evolve
description: >
  Use when: proposals from /propose have been reviewed and accepted by the team.
  Executes accepted proposals -- edits skills, CLAUDE.md, research docs, code,
  and tests. Logs changes to CHANGELOG. The framework improves itself.
type: user-invokable
---

## Context

Receives:
- Proposals file path (or uses most recent)

Reads:
- `.docs/evolve/<slug>-proposals.md` (items with `status: accepted`)
- Files targeted by each proposal
- `.docs/extensions/` (if proposals target extension changes)

Produces:
- `.docs/evolve/<slug>-evolve.md` (execution log)
- `.docs/CHANGELOG.md` entry

## Procedure

### 1. Load proposals

Read the specified proposals file. If no path given, use most recent `.docs/evolve/*-proposals.md` by date prefix. Identify `status: accepted` items. If none, stop and inform user.

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

**Skill changes:** For `skill-change` proposals, prefer invoking `/skill-creator`
if available -- it handles validation, formatting, and test case management that
manual edits miss. Fall back to direct edits only if skill-creator is not installed.

### 3. Handle research staleness

For `research-update` proposals, evaluate each doc:
- **Keep**: still accurate. Log "reviewed, no changes."
- **Update**: core correct, references drifted. Edit in place.
- **Replace**: misleading. Write new version, note rationale.
- **Delete**: no longer useful. Remove file, log rationale.

### 4. Update proposal statuses

Change executed items from `accepted` to `completed`. Leave `rejected` and `deferred` untouched.

### 5. Write evolve log

Create `.docs/evolve/<slug>-evolve.md` (slug matches source proposals). YAML frontmatter with `title`, `date`, `source_proposals`, `changes_made` list. Body has per-change detail: target, files modified, what changed, acceptance criteria met.

### 6. Append CHANGELOG

Add to `.docs/CHANGELOG.md` (create if missing):

```markdown
## Evolve [slug] -- YYYY-MM-DD
Source: [proposals slug]
Data points analyzed: slug1, slug2, slug3

Changes:
- [target] Description of change
```

### 7. Run tests

If `code-pattern` or `test-gap` proposals executed, run the test suite. Fail: revert change, mark proposal `blocked` (not `completed`), log failure reason.

### 8. Create GitHub issues (if applicable)

If proposals suggest changes that belong in a different repository (upstream
framework fixes, cross-repo contract changes, external dependency updates):

1. Check CLAUDE.md for a **GitHub Issue Routing** table. Route to the correct repo.
2. If no routing table exists, ask the user which repo to target.
3. Create issues with clear context: what changed, why, and what the other repo needs to do.

Never create framework issues on application repos or vice versa.

## Output

Modified target files, updated proposals file (completed statuses), `.docs/evolve/<slug>-evolve.md`, `.docs/CHANGELOG.md` entry.

## Gotchas

- Only execute `accepted` items. Never `proposed` or `deferred`.
- Evolve log slug matches source proposals slug.
- CHANGELOG is append-only. Never edit prior entries.
- Research doc deletion is recoverable via git. Always log deletion rationale.
- Test failures trigger revert + blocked status, not completed.
- Route GitHub issues correctly. Framework changes → framework repo. App changes → app repo. Check CLAUDE.md routing table.
- Prefer `/skill-creator` for skill edits. Direct `Edit` calls on SKILL.md files skip validation and formatting that skill-creator provides.
