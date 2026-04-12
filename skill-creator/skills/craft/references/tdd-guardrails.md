# TDD Guardrails

## The Iron Law

**Write a failing test FIRST. Then make it pass. Then refactor. No exceptions for logic.**

Every behavioral change follows RED -> GREEN -> REFACTOR. The cycle is non-negotiable for any code that contains logic, data transformation, API behavior, or state management.

---

## RED Phase

**Goal**: Prove the behavior is missing or broken.

1. Write the test that describes desired behavior
2. Run the test
3. Read the output — confirm it fails
4. Confirm it fails for the RIGHT reason:
   - Correct: assertion fails because behavior doesn't exist yet
   - Wrong: import error, syntax error, wrong test target, fixture missing
5. If fails for wrong reason, fix the test infrastructure, re-run

**Verify step**: Test output in context showing failure message that matches expected missing behavior.

**Common RED mistakes**:
- Test passes immediately (you tested existing behavior, not new behavior)
- Test fails on import (test infrastructure broken, not behavior absent)
- Test is too broad (will never isolate the specific behavior)

---

## GREEN Phase

**Goal**: Minimum code to make the test pass.

1. Write the simplest implementation that makes the test pass
2. Run the test
3. Read output — confirm target test passes
4. Run full relevant test suite — confirm no regressions
5. If regressions, fix without breaking the new test

**Verify step**: Test output showing new test passes + no regressions.

**"Minimum" means**:
- No additional features
- No premature abstraction
- No "while I'm here" improvements
- Hardcode if only one test case exists
- Generalize only when forced by a second test

---

## REFACTOR Phase

**Goal**: Improve code quality without changing behavior.

1. Identify code smells: duplication, poor names, long functions
2. Make one refactoring change
3. Run tests — confirm still green
4. Repeat if needed
5. Stop when code is clear and minimal

**Verify step**: Test output showing all tests still pass after refactoring.

**Refactoring rules**:
- Never refactor RED. Tests must be GREEN before refactoring.
- Never add behavior during refactor. If you need new behavior, start a new RED.
- Small steps. One rename, one extraction, one simplification at a time.

---

## Exception Protocol

For genuinely non-testable changes ONLY:

1. **State explicitly** why automated testing is not possible
2. **Specify alternative verification**:
   - CSS/styling: visual inspection, screenshot comparison
   - Config files: validation command, dry-run
   - Migrations: dry-run, rollback test
   - Environment variables: presence check, format validation
3. **Document** the exception in the commit or craft notes
4. **Proceed** without test for that specific change

**Never applies to**: logic, APIs, data transforms, state changes, error handling, auth, validation. These are always testable.

---

## 4-Fix Circuit Breaker

Counting rule: A "fix attempt" = code change + verification failure. Pure investigation (reading code, forming hypotheses) does not count.

| Attempt | Action |
|---|---|
| 1 | Fix and verify |
| 2 | Fix differently and verify |
| 3 | Fix with different approach and verify |
| 4 | STOP |

**On STOP**:
1. Do not make another code change
2. List all 4 attempts: what was tried, what failed, why
3. Question the approach: Is the blueprint wrong? Is the test wrong? Is the assumption wrong?
4. Present analysis to user
5. Wait for user guidance before continuing

**Reset**: Circuit breaker resets when moving to a different issue/unit.

---

## 12 Rationalization Red Flags

If any of these thoughts cross your mind, recognize them as rationalization and return to the TDD cycle:

| # | Rationalization | Reality |
|---|---|---|
| 1 | "I'll write the test after" | You won't. And you lose the design benefit. |
| 2 | "Too simple to test" | Simple things compound. Test it anyway. |
| 3 | "Just manually verify" | Manual verification is non-reproducible evidence. |
| 4 | "The test is obvious" | Then it's fast to write. Do it. |
| 5 | "Need to see implementation first" | TDD IS the design process. Test describes what, not how. |
| 6 | "Get it working then add tests" | Retrofitted tests test implementation, not behavior. |
| 7 | "Just a refactor" | Refactors need green tests to prove no behavior change. |
| 8 | "Existing tests cover this" | Run them. If they pass without your change, they don't cover it. |
| 9 | "Tests in a follow-up" | Follow-ups have their own priorities. Test now. |
| 10 | "It's just a prototype/POC" | Prototypes become production. Start right. |
| 11 | "Too hard to write a test for" | Signals design problem. Fix the design to be testable. |
| 12 | "Watch mode shows it's passing" | Watch mode output is not verification evidence. Run fresh. |

---

## Per-Cycle Verification Checklist

After each RED-GREEN-REFACTOR cycle:

- [ ] Test written BEFORE implementation
- [ ] Test fails for the right reason (RED verified)
- [ ] Implementation is minimal (GREEN verified)
- [ ] All tests pass after implementation (no regressions)
- [ ] Refactoring preserved green state
- [ ] No rationalization flags triggered
