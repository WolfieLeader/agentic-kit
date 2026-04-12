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

- BUILD: new feature or enhancement
- FIX: bug fix (trace -> sketch/craft -> verify -> here)
- Lightweight adds Context section at top

### 2. Gather evidence

Gate: **EVIDENCE-BEFORE-CLAIMS** — read actual outputs, not memory.

- Run `git diff` against session start point. Read output.
- Read final test results from verify phase.
- Read sketch.md success criteria (std/deep).
- Note any P0/P1 findings resolved during verify.

### 3. Write initial retro

Write to `.docs/work/<slug>/retro.md` using template (see references/retro-template.md).

**BUILD sections:**
1. Context (lightweight only) — what was asked, found, approach taken (2-3 sentences)
2. Result — shipped/partial/blocked, summary of what was delivered
3. What We Learned — technical discoveries, codebase insights
4. What Went Well — things that worked, good decisions
5. What Went Wrong — failures, rework, surprises (use root cause categories)
6. Action Items — concrete improvements for next time

**FIX sections:**
1. Context (lightweight only) — what was asked, found, approach taken (2-3 sentences)
2. Result — fixed/partial/workaround
3. Root Cause — actual root cause (may differ from hypothesis)
4. What Didn't Work — investigation dead ends, failed fix attempts
5. Fix — what actually fixed it and why
6. What Went Well / What Went Wrong — process observations
7. Prevention — how to prevent this class of bug

### 4. Present to user

Tell user: "Initial retro written. Please test the feature/fix and share feedback."

### 5. User testing loop

Retro is a living document during its session:

1. User tests feature/fix
2. User provides feedback (works / partially works / broken / suggestions)
3. If issues found:
   - Agent investigates and resolves
   - Runs verification again (EVIDENCE-BEFORE-CLAIMS)
   - Updates retro with new findings
4. Repeat until user satisfied or session ends

### 6. Finalize retro

After user confirms or session ends, update retro with:
- Final result status
- User feedback incorporated
- Any additional What Went Wrong items from testing phase
- Updated action items

### 7. Update MAP.md

If session touched new modules, paths, or architectural boundaries:
- Read current MAP.md
- Add new entries incrementally (do not rewrite existing content)
- New modules, new API routes, new services, new test directories

Gate: **ARTIFACT-BEFORE-HANDOFF** — retro.md and MAP.md updates written to disk.

## "What Went Wrong" Root Cause Categories

Use these categories for structured analysis. Multiple can apply.

| Category | Example |
|---|---|
| Poor user description | Ambiguous requirements led to wrong interpretation |
| Incorrect scope/tier | Should have been std, was treated as lightweight |
| Poor sketch decisions | Selected approach had hidden complexity |
| Stale research/docs | .docs/research had outdated API reference |
| Poor CLAUDE.md | Missing convention led to inconsistent patterns |
| Poor code patterns/structure | Existing code made correct change hard |
| Poor test coverage | No tests caught the regression |
| Poor enforcement | Gate was bypassed or not checked |
| Model capability gap | Task exceeded model's reliable capability |
| Poor model assignment | Sonnet used where opus was needed |
| Poor skill behavior | Skill instructions led to wrong action |
| External/environmental | CI flake, dependency break, infra issue |

## Output

Produces: `.docs/work/<slug>/retro.md`
Updates: MAP.md (if new modules/paths touched)
Passes to: done

## Gotchas

- Retro is mandatory. Never skip even for trivial changes. Lightweight gets a lighter format, not no retro.
- Context section is lightweight-only. Std/deep have sketch.md for that context.
- User testing loop can modify code. Any code changes need fresh verification.
- MAP.md updates are incremental. Do not rewrite or reorganize existing MAP.md content.
- Root cause categories are for structured thinking, not blame. Multiple categories normal.
