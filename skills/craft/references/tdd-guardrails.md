# TDD Guardrails

## The Iron Law

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

Every behavioral change follows RED -> GREEN -> REFACTOR. Non-negotiable for logic, data transformation, API behavior, or state management.

## The Cycle: RED-VERIFY-GREEN-VERIFY-REFACTOR

**RED:** Write one failing test (behavioral, public interface, one behavior).

**VERIFY:** Run test. Read output. Confirm it fails for the RIGHT reason:
- Correct: assertion fails because behavior doesn't exist yet
- Wrong: import error, syntax error, wrong target, fixture missing
- If wrong reason: fix test infrastructure, re-run

**GREEN:** Write minimum code to make test pass.
- No additional features, no premature abstraction, no "while I'm here"
- Hardcode if only one test case; generalize when forced by a second

**VERIFY:** Run full suite. Confirm target passes AND no regressions.

**REFACTOR:** Improve code quality without changing behavior.
- Never refactor RED -- tests must be GREEN first
- Never add behavior during refactor -- start a new RED
- Small steps: one rename, one extraction, one simplification

Each VERIFY step is mandatory. Skipping verification defeats the cycle.

## Exception Protocol

For genuinely non-testable changes ONLY (CSS/styling, config files, migrations, infrastructure scripts):

1. State explicitly why automated testing doesn't apply
2. Specify alternative verification (visual check, dry-run, config validation, lint/typecheck)
3. Tag the exception so retro can track frequency

Never applies to: logic, APIs, data transforms, state changes, error handling, auth, validation.

## 4-Fix Circuit Breaker

A "fix attempt" = code change + verification failure. Investigation (reading code, forming hypotheses) does NOT count.

| Attempt | Action |
|---|---|
| 1 | Fix and verify |
| 2 | Fix differently and verify |
| 3 | Different approach and verify |
| 4 | **STOP** |

On STOP:
1. No more code changes
2. List all 4 attempts: what was tried, what failed, why
3. Question the approach (blueprint wrong? test wrong? assumption wrong?)
4. Present analysis to user. Wait for guidance.

Reset: breaker resets when moving to a different issue/unit.

## 12 Rationalization Red Flags

If any of these cross your mind, STOP and write the test:

1. "I'll write the test after" — the test defines what "working" means. Without it first, you're coding toward a moving target.
2. "Too simple to test" — simple code has simple tests. If it's too simple to get wrong, the test takes 30 seconds and is free insurance.
3. "Just manually verify" — manual verification dies with the session. A test persists across every future change.
4. "The test is obvious" — if it's obvious, writing it is fast. Skip it and you're betting the obvious behavior never regresses.
5. "Need to see implementation first" — TDD is the design tool. The test clarifies what the implementation needs to do before you write it.
6. "Get it working then add tests" — "working" without a test is an unchecked claim. GREEN requires proof.
7. "Just a refactor" — refactors change behavior more often than expected. The test catches the drift you didn't intend.
8. "Existing tests cover this" — run them before your change. If they pass, they don't test the new behavior you're adding.
9. "Tests in a follow-up" — follow-ups have their own scope and priorities. This behavior ships untested indefinitely.
10. "It's just a prototype/POC" — prototypes become production faster than you think. The test is the only thing that survives the transition.
11. "Too hard to write a test for" — hard-to-test code is a design smell. Refactor for testability first, then the test becomes straightforward.
12. "Watch mode shows it's passing" — watch mode runs existing tests. It says nothing about the new behavior you haven't tested yet.
