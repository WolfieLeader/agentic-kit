---
name: verify
description: >
  Use when: craft phase completes. Single step that scales by tier. Lightweight
  runs inline checks. Std/deep adds unified code-reviewer agent (3-pass) and
  extension reviewers. Produces verification evidence and review findings.
phase: verify
type: internal
---

## Context

Receives:

- Lightweight: diff + user's original request
- Std/deep: diff + sketch.md path + blueprint.md path

Reads:

- Test output, build output
- `wiki/extensions/verify.md` for extension reviewers
- Source code as needed for wiring checks

## Iron Law of Verification

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE.

Run command. Read output. Count failures. THEN claim result.

"Tests pass" requires: test run output in context showing pass count.
"Build clean" requires: build output in context showing 0 errors.
"No stubs" requires: search output in context showing 0 matches.
```

## Operational Modes

Set by user or orchestrator before verify runs. Default: interactive.

| Mode            | Behavior                                                  |
| --------------- | --------------------------------------------------------- |
| **interactive** | Triage findings, fix P0/P1, user decides P2/P3. Default.  |
| **report-only** | All findings reported, no fixes attempted. For audits.    |
| **autofix**     | P0/P1 fixed automatically, P2/P3 logged to retro. For CI. |

Mode applies to Phase 2 (review) only. Phase 1 (verification) always runs fully.

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
5. **Sketch/blueprint compliance** -- check `wiki/sketches/<slug>.md` success criteria against implementation. Verify each blueprint unit's verification criteria met.
6. **Cross-repo contract check** (umbrella projects only) -- if the change touches
   APIs, shared types, message schemas, or HTTP endpoints consumed by other repos:
   - Check CLAUDE.md for a **Cross-Repo Dependencies** table (provider → consumer → contract)
   - If no table exists, infer consumers from imports, API clients, and shared type references
   - Verify contracts still hold (type compatibility, endpoint paths, request/response shapes)
   - Run type-check or build in affected consumer repos if feasible
   - Skip when the change is purely internal to one repo with no external surface

All 6 pass (or 5 for single-repo) -> proceed to Phase 2.

### Phase 2: Review (subagent)

**1. Dispatch unified code-reviewer agent** -- single subagent, 3 sequential passes:

- **Correctness:** logic errors, edge cases, error handling, race conditions, null safety, type issues, security (injection, auth bypass, data exposure)
- **Testing:** coverage of new behavior, test quality (behavior not implementation), missing edge cases, test isolation
- **Maintainability:** naming clarity, function/module size, duplication, coupling and cohesion

Agent returns findings with severity and evidence.

**2. Dispatch extension reviewers** -- if `wiki/extensions/verify.md` exists, dispatch domain-specific reviewers (accessibility, performance, API contracts, etc.).

**3. Triage findings:**

| Priority       | Definition                      | Action                          |
| -------------- | ------------------------------- | ------------------------------- |
| P0 -- Critical | Security flaw, data loss, crash | Fix immediately                 |
| P1 -- High     | Bug, missing error handling     | Fix before proceeding           |
| P2 -- Medium   | Code quality, minor issues      | Fix if straightforward (<5 min) |
| P3 -- Low      | Style, preference, optimization | User discretion                 |

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
- yo/references/agent-dispatch.md -- how to compose Agent tool calls (for code-reviewer and extension dispatch)
- references/security-checklist.md -- OWASP, auth, injection, data protection (for security extension reviewers)
- references/performance-checklist.md -- DB, API, frontend optimization (for performance extension reviewers)
- references/accessibility-checklist.md -- WCAG 2.1, keyboard, ARIA, forms (for accessibility extension reviewers)

## Gotchas

- Run the FULL test suite for std/deep. Regressions hide in unrelated tests.
- Wiring check catches the #1 demo-day bug: feature works in isolation, not connected to app.
- Review defense is not optional. Blind acceptance causes churn and regressions.
- Extension reviewers are additive. Core 3-pass review always runs.
- Cross-repo breaks hide in passing tests. A backend API change can break a mobile client that never runs in the same test suite.

## Rationalization Red Flags

If you catch yourself thinking any of these, STOP and follow the verify procedure:

1. "Tests pass so it's done" — tests verify code correctness, not feature correctness. Check wiring.
2. "The build succeeded, no need for the stub scan" — all 4/5 checks run. No shortcuts.
3. "This reviewer finding looks right, I'll just fix it" — verify against actual code first. Push back if wrong.
4. "Great point!" / "You're absolutely right!" — no sycophancy. Evaluate technically.
5. "I already verified during craft" — fresh verification evidence. Not stale claims from earlier.
6. "The review found nothing major, skip the defense protocol" — zero-finding halt is a valid outcome. Inventing issues is not.
