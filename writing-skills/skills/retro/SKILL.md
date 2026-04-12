---
name: retro
description: >
  Use at the end of every BUILD and FIX pipeline. Captures structured
  reflection as a living document. Automatic -- not user-invoked.
phase: retro
type: internal
---

# Retro

## Context

Automatic at the end of every BUILD and FIX pipeline. Captures what happened, what went well, what went wrong. Living document -- updated as user tests and provides feedback.

- Receives: session context (what happened), sketch.md path (std/deep, omitted for light)
- Reads: git diff, test results
- Produces: `.docs/work/<slug>/retro.md`
- Updates: MAP.md (if new modules/paths touched)
- Passes: -> done (pipeline ends)

## Procedure

1. Gather session context: git diff, test results, what happened during the session.

2. Write `retro.md` to `.docs/work/<slug>/` using the template in `references/retro-template.md`. Include YAML frontmatter.

3. For lightweight: add Context section at top -- what was asked, what was found, what approach was taken. Two to three sentences. Replaces the sketch that doesn't exist.

4. Fill sections based on type:
   - **BUILD:** Result, What We Learned, What Went Well, What Went Wrong, Action Items
   - **FIX:** Result, Root Cause, What Didn't Work, Fix, What Went Well, What Went Wrong, Prevention

5. For "What Went Wrong": write free-text explanation first, then tag with a root cause category if one fits. Categories help `/propose` detect patterns.

6. If new modules or paths were touched, update MAP.md incrementally. Don't rewrite -- append or modify the relevant section.

7. Retro is a LIVING document during the session:
   a. Agent writes initial retro.
   b. User tests the feature/fix.
   c. User provides feedback (failures, style issues, things missed).
   d. Agent resolves issues found.
   e. Retro updated with full picture -- including what user found and how it was resolved.

8. Pipeline ends here. Don't suggest git operations.

## Output

`.docs/work/<slug>/retro.md` + MAP.md update (if new modules/paths touched).

## Gotchas

- Write specific technical findings, not generic summaries. "Auth middleware doesn't validate token expiry" not "there were some issues."
- Include what went wrong with root cause, not just what went right. Honest retros drive improvement.
- Living document -- update as user discovers issues during testing. Don't treat initial write as final.
- Pipeline ends at retro. Don't suggest git operations.
- Root cause categories are for pattern detection, not blame. Free-text explanation first, category tag second.
