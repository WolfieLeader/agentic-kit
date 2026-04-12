---
title: TDD Guardrails
type: reference
parent_skill: craft
---

# TDD Guardrails

## The Iron Law

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

## The Cycle

```
RED:      Write one failing test (behavioral, public interface, one behavior)
VERIFY:   Confirm it fails for the expected reason (MANDATORY)
GREEN:    Write minimum code to pass (simplest possible)
VERIFY:   Confirm it passes, no other tests broken (MANDATORY)
REFACTOR: Clean up, remove duplication, improve names (keep green)
```

Each VERIFY step is mandatory. Skipping verification defeats the purpose of the cycle.

## Exception Protocol

When test-first doesn't apply:
- CSS/styling changes
- Configuration files
- Database migrations
- Infrastructure scripts
- Documentation/design tasks
- Legacy code with no test harness

Steps:
1. State why test-first doesn't apply.
2. Specify alternate verification from the project's suite (lint, typecheck, format, build, knip, LSP diagnostics, visual check, migration dry-run, etc.).
3. Retro tags the exception so `/propose` can track frequency.

The iron law is "no unverified code." TDD is the preferred method, not the only method.

## Principles

- Test behavior through public interfaces, not implementation details.
- Vertical slices: one test -> one implementation (not all tests then all code).
- Boundary-only mocking: external APIs, DBs, caches, time, filesystem. Real code internally.
- Refactor only when GREEN.
- Code written before test MUST be deleted entirely. No keeping it as "reference."
- 80%+ coverage target (not 100%).
- Tests should survive internal refactors unchanged.

## 4-Fix Circuit Breaker

- A **fix attempt** = code change with intent to resolve + verification showing it didn't work.
- Investigation (logging, reading code, reproducing, narrowing down) does NOT count.
- 4 failed fix attempts -> STOP.
- Question the approach, not just the symptom.
- Discuss with user before attempting more fixes.
- User can authorize more attempts after discussion.

## Per-Agent Iteration Cap

Separate from the 4-fix breaker — catches runaway agents that hit different errors each time.

- No default number. Projects set their own cap via evolve when retros show runaway sessions.
- When hit: agent pauses with status report to user, does not silently continue.

## 12 Rationalization Red Flags

Hearing yourself think any of these? Stop. Write the test.

1. "I'll write test after"
2. "Too simple to test"
3. "Just manually verify"
4. "Obvious test"
5. "Need to see implementation first"
6. "Get it working then test"
7. "Just a refactor"
8. "Existing tests cover this"
9. "Tests in follow-up"
10. "Prototype/POC"
11. "Too hard to write"
12. "Watch mode shows passing"
