---
name: craft
description: >
  Implements with TDD. Two modes: lightweight (inline, no subagent) and
  std/deep (fresh opus subagent per implementation unit). Produces code + tests.
phase: craft
type: internal
---

## Context

Receives:
- Lightweight: dispatch summary from start
- Std/deep: blueprint.md path + explorer findings

Reads:
- `.docs/work/<slug>/blueprint.md` (std/deep)
- `.docs/extend/craft.md` for extension agents/hooks
- Source code, test files, project conventions

## Procedure — Lightweight

No subagent. Main session implements directly. No extensions.

### 1. Identify change

Read relevant source. Identify exactly what needs to change and where.

### 2. Identify test

Determine which test(s) will prove the change works. If test file exists, identify insertion point. If not, determine test file location following project conventions.

### 3. TDD cycle

Gate: **TEST-THEN-CODE** — failing test first, always.

**RED**: Write failing test. Run test suite. Confirm test fails for the RIGHT reason (not syntax error, not wrong import — the actual missing behavior).

**GREEN**: Write minimum code to make test pass. Run test suite. Confirm target test passes AND no regressions.

**REFACTOR**: If code or test needs cleanup, refactor. Run tests. Confirm still green.

Repeat for each distinct behavior being added/changed.

### 4. Exception protocol

If change is genuinely non-testable (CSS-only, config file, migration, environment variable):
1. State explicitly WHY it cannot be tested
2. Specify alternative verification (visual check, dry-run, config validation)
3. Proceed without test for that specific change
4. NEVER use this for logic, API, data, or behavior changes

### 5. Pass to verify

## Procedure — Standard/Deep

Fresh opus subagent per implementation unit, dispatched sequentially per dependency order.

### 1. Read blueprint

Read blueprint.md. Extract:
- Unit list with execution order
- Durable decisions (shared context for all units)
- Per-unit details

### 2. Dispatch per unit

For each unit in execution order:

**A. Prepare context bundle**
- Unit goal, approach, test scenarios, verification criteria
- Relevant durable decisions (only those this unit needs)
- Relevant explorer findings for affected systems
- Project conventions (test framework, file structure, naming)

**B. Dispatch fresh opus subagent**
- Subagent gets context bundle only. No full blueprint (context isolation).
- Subagent follows TDD cycle (same as lightweight steps 2-4)
- Model: opus default. Sonnet ONLY for trivially mechanical units (rename, move, config change).

**C. Run extensions**
- Agent extensions from `.docs/extend/craft.md` (if file exists)
- Skill extensions from `.docs/extend/craft.md` (if file exists)
- Extensions run after subagent completes, before mini-review

**D. Mini-review (inline)**
- Tests pass (run and read output)
- No stubs or placeholder code
- Implementation matches blueprint unit spec
- Quick diff scan for obvious issues

**E. Subagent returns**

| Status | Action |
|---|---|
| DONE | Mark unit complete, proceed to next |
| BLOCKED | Assess: re-dispatch with more context / break down further / escalate to user |
| NEEDS_CONTEXT | Provide requested context, re-dispatch |

### 3. Progress tracker

At each unit boundary, restate the full unit checklist:
```
[x] Unit 1: <name> — DONE
[x] Unit 2: <name> — DONE
[ ] Unit 3: <name> — IN PROGRESS
[ ] Unit 4: <name> — PENDING
```

### 4. Pass to verify

After all units complete, pass to verify with full diff.

## Circuit Breaker (all tiers)

A "fix attempt" = code change + verification failure. Investigation alone does not count.

**4 consecutive fix failures on the same issue -> STOP.**

1. Stop making changes
2. State what was tried and why it failed
3. Question the approach (is the blueprint/sketch wrong?)
4. Discuss with user before continuing

## Rationalization Red Flags

If you catch yourself thinking any of these, STOP and follow the TDD cycle:

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

See references/tdd-guardrails.md for the full TDD protocol.

## Output

Produces: code changes + tests (committed or staged)
Passes to: verify

## Gotchas

- Context isolation means subagents do NOT see the full blueprint. They get their unit only.
- Durable decisions are not optional for subagents. They are authoritative constraints.
- Exception protocol is for genuinely non-testable changes. Logic is always testable.
- Circuit breaker counts code changes, not investigation. Reading code to understand a failure is not a fix attempt.
- Extensions in `.docs/extend/craft.md` are optional. Skip gracefully if file missing.
