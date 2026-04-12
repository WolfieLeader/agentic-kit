---
name: verify
description: >
  Single step that scales by tier. Lightweight runs inline checks.
  Std/deep adds unified code-reviewer agent and extension reviewers.
  Produces verification evidence and review findings.
phase: verify
type: internal
---

## Context

Receives:
- Lightweight: diff + user's original request
- Std/deep: diff + sketch.md path + blueprint.md path

Reads:
- Test output, build output
- `.docs/extend/verify.md` for extension reviewers
- Source code as needed for wiring checks

## Iron Law of Verification

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE.

Run command. Read output. Count failures. THEN claim result.

"Tests pass" requires: test run output in context showing pass count.
"Build clean" requires: build output in context showing 0 errors.
"No stubs" requires: search output in context showing 0 matches.
```

## Procedure -- Lightweight

Inline, no subagent. Four checks.

1. **Tests pass** -- run test command, read full output, count pass/fail, state result with numbers. Never claim without running.
2. **Build clean** -- run build, read output, confirm zero errors (explain known warnings).
3. **Stub/placeholder scan** -- search diff for: TBD, TODO, FIXME, HACK, XXX, "to be determined", "placeholder", "not implemented", "stub", "will decide later". Any match = fail.
4. **Quick diff scan** -- re-read diff against original request. Does it do what was asked? Unintended side effects? Wrong files changed?

All 4 pass -> proceed to retro.

## Procedure -- Standard/Deep

### Phase 1: Verification (inline by orchestrator)

1. **Full test suite** -- run complete suite (not just affected tests). Read output. State results with counts.
2. **Build clean** -- run build. Confirm zero errors.
3. **Stub/placeholder scan** -- scan ALL changed files (not just diff). Hard ban: TBD, TODO, FIXME, HACK, XXX, "to be determined", "placeholder", "not implemented", "stub", "will decide later".
4. **Wiring check** -- are new components actually connected?
   - New routes registered in router?
   - New modules imported where needed?
   - New env vars documented?
   - New dependencies in package/config files?
   - DB migrations included if schema changed?
5. **Sketch/blueprint compliance** -- check sketch.md success criteria against implementation. Verify each blueprint unit's verification criteria met.

All 5 pass -> proceed to Phase 2.

### Phase 2: Review (subagent)

**1. Dispatch unified code-reviewer agent** -- single subagent, 3 sequential passes:

- **Correctness:** logic errors, edge cases, error handling, race conditions, null safety, type issues, security (injection, auth bypass, data exposure)
- **Testing:** coverage of new behavior, test quality (behavior not implementation), missing edge cases, test isolation
- **Maintainability:** naming clarity, function/module size, duplication, coupling and cohesion

Agent returns findings with severity and evidence.

**2. Dispatch extension reviewers** -- if `.docs/extend/verify.md` exists, dispatch domain-specific reviewers (accessibility, performance, API contracts, etc.).

**3. Triage findings:**

| Priority | Definition | Action |
|---|---|---|
| P0 -- Critical | Security flaw, data loss, crash | Fix immediately |
| P1 -- High | Bug, missing error handling | Fix before proceeding |
| P2 -- Medium | Code quality, minor issues | Fix if straightforward (<5 min) |
| P3 -- Low | Style, preference, optimization | User discretion |

**4. Defense protocol** -- see references/review-defense.md. Summary:
- Verify each finding against actual code before acting
- Classify: valid+actionable, valid+not actionable, technically wrong, unclear, contradicts durable decision
- Clarify ALL unclear items before implementing any changes
- Push back on technically wrong findings (with evidence and reasoning)
- Threshold defense: if finding contradicts durable decision, defend it
- No performative agreement -- disagree when findings are wrong

After P0/P1 resolved -> pass to retro.

## Output

Produces:
- Verification evidence (test output, build output, scan results)
- Review findings with severity (std/deep only)
- Resolution of P0/P1 findings

Passes to: retro

## References

- references/review-defense.md -- defense protocol, push-back template, anti-sycophancy rules

## Gotchas

- Run the FULL test suite for std/deep. Regressions hide in unrelated tests.
- Wiring check catches the #1 demo-day bug: feature works in isolation, not connected to app.
- Review defense is not optional. Blind acceptance causes churn and regressions.
- Extension reviewers are additive. Core 3-pass review always runs.
