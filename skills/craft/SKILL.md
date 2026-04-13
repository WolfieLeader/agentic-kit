---
name: craft
description: >
  Use when: pipeline reaches implementation phase. Implements with TDD via
  RED-GREEN-REFACTOR. Lightweight runs inline; std/deep dispatches fresh opus
  subagent per unit sequentially. Produces code + tests.
phase: craft
type: internal
---

## Context

Receives:

- Lightweight: dispatch summary from yo
- Std/deep: blueprint.md path + exploration file path
  (`wiki/research/<slug>-exploration.md`, written by yo step 15)

Reads:

- `wiki/blueprints/<slug>.md` (std/deep)
- `wiki/extensions/craft.md` for extension agents/hooks
- Source code, test files, project conventions

## Procedure -- Lightweight

No subagent. Main session implements directly. No extensions.

1. **Identify change** -- read relevant source, identify what changes and where.
2. **Identify test** -- determine which test proves the change works. Process blueprint test scenarios one-at-a-time. Never generate multiple tests before implementing the first. Batch test generation validates the agent's imagination, not the code.
3. **RED** -- write one failing test. Run it. Confirm it fails for the RIGHT reason (missing behavior, not syntax/import error).
4. **GREEN** -- write minimum code to pass. Run full suite. Confirm green, no regressions.
5. **REFACTOR** -- clean up if needed. Run tests. Confirm still green.
6. **Exception protocol** -- if genuinely non-testable (CSS, config, migration): state why, specify alt verification, proceed. NEVER for logic/API/data/behavior.
7. Pass to verify.

## Procedure -- Standard/Deep

Fresh opus subagent per implementation unit, dispatched sequentially per dependency order.

### 1. Read blueprint

Read blueprint.md. Extract unit list with execution order, durable decisions, per-unit details.

### 2. Dispatch per unit

For each unit in execution order:

**A. Construct context bundle:**

- Unit goal, approach, test scenarios, verification criteria
- Relevant durable decisions (only those this unit needs)
- Relevant explorer findings extracted from
  `wiki/research/<slug>-exploration.md` for this unit's affected systems
  (grep the file, extract the scoped section -- don't pass the whole thing)
- Project conventions (test framework, file structure, naming)

**B. Dispatch fresh opus subagent:**

- Subagent gets context bundle only. No full blueprint (**context scoping** —
  the subagent has filesystem access and _could_ read more, but scoping its
  prompt to one unit keeps it focused and prevents context overload).
- Subagent follows TDD cycle (same as lightweight steps 2-6).
- Process test scenarios one-at-a-time. Never batch-generate tests.
- Model: opus default. Sonnet ONLY for trivially mechanical units (rename, color change, single-line config).

**C. Handle return:**

| Status        | Action                                                                |
| ------------- | --------------------------------------------------------------------- |
| DONE          | Mark unit complete, proceed to next                                   |
| BLOCKED       | Re-dispatch with more context / break down further / escalate to user |
| NEEDS_CONTEXT | Provide requested context, re-dispatch                                |

**D. Run extensions** (if `wiki/extensions/craft.md` exists):

- Agent extensions first (lint, style, patterns)
- Skill extensions second (domain workflows on clean code)

**E. Mini-review (inline by orchestrator):**

- Tests pass (run and read output)
- No stubs or placeholder code
- Implementation matches blueprint unit spec
- Quick diff scan for obvious issues

**F. Integration check (unit 2+):** Run full test suite to catch cases where a unit breaks prior work before more units build on broken foundation.

**G. Progress tracker:**

```
[x] Unit 1: <name> -- DONE
[x] Unit 2: <name> -- DONE
[ ] Unit 3: <name> -- IN PROGRESS
[ ] Unit 4: <name> -- PENDING
```

### 3. Pass to verify

After all units complete, pass to verify with full diff. No automatic commits.

## Circuit Breaker (all tiers)

A "fix attempt" = code change + verification failure. Investigation alone does not count.

**4 consecutive fix failures on the same issue -> STOP.**

1. Stop making changes
2. State what was tried and why each attempt failed
3. Question the approach (blueprint wrong? test wrong? assumption wrong?)
4. Discuss with user before continuing

Reset: breaker resets when moving to a different issue/unit.

## Rationalization Red Flags

See references/tdd-guardrails.md § 12 Rationalization Red Flags. If any cross your
mind, STOP and write the test.

## Output

Produces: code changes + tests
Passes to: verify

## References

- references/tdd-guardrails.md -- iron law, RED-GREEN-REFACTOR cycle, exception protocol, circuit breaker, red flags
- yo/references/agent-dispatch.md -- how to compose Agent tool calls (for unit subagent and extension dispatch)

## Gotchas

- Context scoping: subagents get their unit only in the prompt. They _can_ read the full blueprint from disk but shouldn't need to — if a unit needs cross-unit context, the durable decisions section or the context bundle should cover it.
- Durable decisions are authoritative constraints, not suggestions.
- Exception protocol is for genuinely non-testable changes. Logic is always testable.
- Extensions in `wiki/extensions/craft.md` are optional. Skip gracefully if file missing.
- Default is opus. Sonnet is the exception, not the optimization. Downgrade only for trivially mechanical units (rename, color change, single-line config). If you're debating whether a unit is "mechanical enough," it isn't — use opus.
