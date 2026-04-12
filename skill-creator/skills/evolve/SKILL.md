---
name: evolve
description: >
  Execute accepted proposals from a propose round. Use after team reviews
  proposals and marks items accepted. Edits skills, CLAUDE.md, research docs,
  code, and tests. Handles research staleness. Logs changes and updates changelog.
type: user-invokable
---

# Evolve

Execute accepted proposals. Change the framework, codebase, and docs.

## Context

- Reads: `.docs/evolve/NNN-proposals.md` (proposals file with accepted items)
- Reads: files targeted by each proposal (skills, CLAUDE.md, research docs, code, tests)
- Reads: `.docs/extend/` (if proposals target extension changes)
- Produces: `.docs/evolve/NNN-evolve.md` (execution log)
- Appends: `.docs/CHANGELOG.md`

## Procedure

1. **Load proposals.** Read the specified proposals file. Identify items with `Status: accepted`. If none accepted, stop and inform user.

2. **Plan execution order.** Group by target type, execute in this order:
   - `claude-md-change` -- conventions first (other changes may depend on them)
   - `skill-change` -- framework skill edits
   - `process-change` -- workflow/extension/routing adjustments
   - `research-update` -- refresh stale docs
   - `docs-gap` -- new documentation
   - `code-pattern` -- code refactors and extractions
   - `test-gap` -- new tests (run after code changes)

3. **Execute each proposal.** For each accepted item:
   - Read the target file(s)
   - Make the change described in the proposal
   - Verify the change meets the proposal's acceptance criteria
   - Record what changed (files modified, description of change)

4. **Handle research staleness.** When proposals target `research-update` (triggered by retros tagging "stale research/docs"), evaluate each doc:
   - **Keep** -- still accurate, no changes needed. Log as "reviewed, no changes."
   - **Update** -- core content correct, references or examples drifted. Edit in place, note what changed.
   - **Replace** -- misleading or substantially wrong. Write new version, note replacement rationale.
   - **Delete** -- no longer useful, actively harmful to keep. Remove file (git preserves history). Log deletion rationale.

5. **Update proposal statuses.** In the source proposals file, change each executed item from `accepted` to `completed`. Leave `rejected` and `deferred` items untouched.

6. **Write evolve log.** Create `.docs/evolve/NNN-evolve.md`:

```yaml
---
title: Evolve Execution Round N
date: YYYY-MM-DD
source_proposals: NNN
changes_made:
  - target: skill-change
    description: Added cross-platform impact question to sketch
    files: [skills/sketch/SKILL.md]
  - target: claude-md-change
    description: Added API error handling convention
    files: [CLAUDE.md]
---
```

Body contains per-change detail:

```markdown
### Change 1: [title from proposal]
- **Target:** [target type]
- **Files modified:** [list]
- **What changed:** [brief description of actual edits]
- **Acceptance criteria met:** [yes/no + evidence]
```

7. **Append to CHANGELOG.** Add entry to `.docs/CHANGELOG.md` (create if missing). Format:

```markdown
## Evolve #N -- YYYY-MM-DD
Source: proposals #NNN
Retros analyzed: slug1, slug2, slug3

Changes:
- [skill-change] Added cross-platform impact question to sketch
- [claude-md-change] Added API error handling convention
- [research-update] Refreshed React docs (Update -- examples drifted)
- [test-gap] Added integration tests for queue consumer
```

8. **Summarize.** Print: proposals executed, files changed, any issues encountered.

## Output

- Modifies target files (skills, CLAUDE.md, research docs, code, tests)
- Updates source proposals file (status changes to `completed`)
- Creates `.docs/evolve/NNN-evolve.md` execution log
- Appends to `.docs/CHANGELOG.md`
- Prints execution summary

## Gotchas

- Never execute `proposed` or `deferred` items. Only `accepted`. If user wants to execute a `proposed` item, ask them to mark it `accepted` first.
- Research doc deletion is permanent in the working tree but recoverable via git. Always log the deletion rationale in the evolve log so the team understands why.
- Evolve log NNN matches the source proposals NNN. If proposals file is `003-proposals.md`, evolve log is `003-evolve.md`.
- Run tests after code changes. If tests fail, log the failure in the evolve log, revert the change, and mark the proposal as `blocked` (not `completed`) with the failure reason.
- CHANGELOG is append-only. Never edit prior entries. New evolve rounds add new sections at the top.
