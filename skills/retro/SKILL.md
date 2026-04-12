---
name: retro
description: >
  Automatic at end of every BUILD/FIX. Writes retro.md as living document.
  User tests, provides feedback, agent resolves and updates retro.
phase: retro
type: internal
---

## Context

Receives:
- Session context (full conversation history)
- Sketch.md path (std/deep; omitted for lightweight)

Reads:
- Git diff (all changes in session)
- Test results (final verification output)
- Blueprint.md (std/deep, if exists)
- MAP.md (for incremental updates)

## Procedure

### 1. Determine mode

- **BUILD**: new feature or enhancement
- **FIX**: bug fix (trace -> sketch/craft -> verify -> here)
- **Context section**: add for lightweight tier (all types), omit for std/deep (sketch.md covers that context)

### 2. Gather evidence

- Run `git diff` against session start point. Read output.
- Read final test results from verify phase.
- Read sketch.md success criteria (std/deep).

### 3. Write initial retro

Write to `.docs/work/<slug>/retro.md` using template (see references/retro-template.md). Include YAML frontmatter.

**Frontmatter matters downstream.** Every field feeds `/propose` pattern detection:
- `module:` + `affected_modules:` — cluster retros by subsystem, detect cross-module pain points
- `tags:` — grep-traversable keywords connecting retros to research and sketches
- `root_cause:` (FIX) — aggregated across retros to detect systemic patterns
- `token_effort:` — routing efficiency signal (step 5)
- `outcome:` — success rate tracking per module/tier

Set `affected_modules:` to ALL modules this task touched (not just the primary). Omit if single-module.

**BUILD sections:** Context (lightweight only), Result, What We Learned, What Went Well, What Went Wrong, Action Items.

**FIX sections:** Context (lightweight only), Result, Root Cause, What Didn't Work, Fix, What Went Well / What Went Wrong, Prevention.

For "What Went Wrong": write free-text explanation first, then tag with root cause category. Categories help `/propose` detect patterns.

### 4. Living document flow

1. Agent writes initial retro
2. Tell user: "Initial retro written. Please test and share feedback."
3. User tests feature/fix
4. User provides feedback (works / partially works / broken / suggestions)
5. If issues found -- agent resolves, runs verification, updates retro
6. Repeat until user satisfied or session ends

### 5. Assess token effort

Set `token_effort` in frontmatter — agent self-assessment of whether this task burned more tokens than its tier/scope warranted:
- **low**: straightforward, minimal retries or exploration
- **medium**: expected effort for the scope
- **high**: significant retries, exploration, or context-heavy work

This feeds `/propose` pattern detection. Consistent `high` on lightweight tasks signals a routing problem.

### 6. Finalize

After user confirms or session ends:
- Update frontmatter with final status
- Incorporate user feedback
- Add any new What Went Wrong items from testing phase

### 7. Update MAP.md

If session touched new modules, paths, or architectural boundaries:
- Read current MAP.md
- Append new entries incrementally (do not rewrite existing content)

## Output

Produces: `.docs/work/<slug>/retro.md`
Updates: MAP.md (if new modules/paths touched)
Passes to: done

## References

- `references/retro-template.md` -- YAML frontmatter schema, section templates, root cause categories

## Gotchas

- Retro is mandatory. Lightweight gets a lighter format, not no retro.
- Context section is lightweight-only. Std/deep have sketch.md for that context.
- User testing loop can modify code. Any code changes need fresh verification.
- MAP.md updates are incremental -- do not rewrite or reorganize existing content.
- Root cause categories are for structured thinking, not blame. Multiple categories normal.
