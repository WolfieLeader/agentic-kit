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

1. "I'll write the test after"
2. "Too simple to test"
3. "Just manually verify"
4. "The test is obvious"
5. "Need to see implementation first"
6. "Get it working then add tests"
7. "Just a refactor"
8. "Existing tests cover this"
9. "Tests in a follow-up"
10. "It's just a prototype/POC"
11. "Too hard to write a test for"
12. "Watch mode shows it's passing"
