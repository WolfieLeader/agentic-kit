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

## Procedure — Lightweight

Inline, no subagent. Four checks.

### 1. Tests pass

Gate: **EVIDENCE-BEFORE-CLAIMS**

Run test command. Read full output. Count pass/fail. State result with numbers.

```
NEVER: "Tests pass" (without running)
ALWAYS: Run. Read output. "14 passed, 0 failed, 2 skipped."
```

### 2. Build clean

Run build command. Read output. Confirm zero errors, zero warnings (or explain known warnings).

### 3. Stub/placeholder scan

Search diff for: TBD, TODO, FIXME, HACK, XXX, "placeholder", "not implemented", "stub".
Any match = fail. Fix before proceeding.

### 4. Quick diff scan

Re-read the diff. Compare against user's original request:
- Does the change do what was asked?
- Any unintended side effects visible in diff?
- Any files changed that shouldn't be?

All 4 pass -> proceed to retro.

## Procedure — Standard/Deep

Two phases: verification (inline) + review (subagent).

### Phase 1: Verification (inline by orchestrator)

#### 1. Full test suite

Run complete test suite (not just affected tests). Read output. State results with counts.

#### 2. Build clean

Run build. Confirm zero errors.

#### 3. Stub/placeholder scan

Same as lightweight step 3, but scan ALL changed files (not just diff).

#### 4. Wiring check

Are new components actually connected?
- New routes registered in router?
- New modules imported where needed?
- New env vars documented?
- New dependencies in package/config files?
- DB migrations included if schema changed?

#### 5. Sketch/blueprint compliance

Re-read sketch.md success criteria. Check each one against implementation.
Re-read blueprint.md units. Verify each unit's verification criteria met.

All 5 pass -> proceed to Phase 2.

### Phase 2: Review (subagent)

#### 1. Dispatch unified code-reviewer agent

Single subagent, 3 sequential passes:

**Pass 1 — Correctness**
- Logic errors, edge cases, error handling
- Race conditions, null safety, type issues
- Security: injection, auth bypass, data exposure

**Pass 2 — Testing**
- Test coverage of new behavior
- Test quality (testing behavior, not implementation)
- Missing edge case tests
- Test isolation (no shared state, no order dependence)

**Pass 3 — Maintainability**
- Naming clarity
- Function/module size
- Duplication
- Coupling and cohesion

Agent returns findings with severity and evidence.

#### 2. Dispatch extension reviewers

If `.docs/extend/verify.md` exists, dispatch reviewers defined there. These handle domain-specific review (accessibility, performance budgets, API contract compliance, etc.).

#### 3. Triage findings

| Priority | Definition | Action |
|---|---|---|
| P0 — Critical | Security flaw, data loss, crash | Fix immediately before proceeding |
| P1 — High | Bug, incorrect behavior, missing error handling | Fix before proceeding |
| P2 — Medium | Code quality, minor issues | Fix if straightforward (<5 min) |
| P3 — Low | Style, preference, minor optimization | User discretion |

### Phase 2b: Defense protocol

See references/review-defense.md for full protocol. Summary:

- Verify each finding against actual code before acting
- Push back on technically wrong findings (with evidence and reasoning)
- Clarify ALL unclear items before implementing any changes
- No performative agreement — disagree when findings are wrong
- Threshold defense: if finding contradicts blueprint durable decision, defend the decision with rationale

## Iron Law of Verification

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE.

Run command. Read output. Count failures. THEN claim result.

"Tests pass" requires: test run output in context showing pass count.
"Build clean" requires: build output in context showing 0 errors.
"No stubs" requires: search output in context showing 0 matches.
```

## Output

Produces:
- Verification evidence (test output, build output, scan results)
- Review findings with severity (std/deep only)
- Resolution of P0/P1 findings

Passes to: retro (after all P0/P1 resolved)

## Gotchas

- Run the FULL test suite for std/deep, not just "affected" tests. Regressions hide in unrelated tests.
- Wiring check catches the #1 demo-day bug: feature works in isolation, not connected to app.
- Review defense is not optional. Blind acceptance of review findings causes churn and regressions.
- Extension reviewers are additive. Core 3-pass review always runs.
- P2 fixes can introduce new bugs. Run verification again after P2 fixes.
