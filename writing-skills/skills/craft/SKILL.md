---
name: craft
description: >
  Use when router (lightweight) or blueprint (std/deep) is complete.
  Implements code with TDD guardrails. Two modes based on tier.
phase: craft
type: internal
---

# Craft

## Context

Two modes. Lightweight runs inline. Standard/deep dispatches fresh subagents per unit.

**Lightweight mode:**
- Receives: dispatch summary, user input (from router context)
- No subagent. Main session implements directly.
- No extensions — lightweight skips `.docs/extend/craft.md`
- Produces: code changes, tests
- Passes: -> verify

**Standard/Deep mode:**
- Receives: blueprint.md path, explorer findings
- Reads: blueprint.md (extracts units), `.docs/extend/craft.md` (between-unit checks)
- Fresh opus subagent per unit, dispatched sequentially via Agent tool
- Per-unit subagent receives: self-contained context (unit details, relevant durable decisions, relevant explorer findings, project conventions). No file path reading assignments.
- Per-unit subagent returns: DONE | BLOCKED | NEEDS_CONTEXT
- Produces: code changes, tests
- Passes: -> verify

## Procedure

### Lightweight

1. Identify the change from router context (dispatch summary + self-look findings).
2. Identify the test to write (behavioral, public interface).
3. **RED** -- write one failing test. Run it. Confirm it fails for the expected reason.
4. **GREEN** -- write minimum code to pass. Run tests. Confirm green, no regressions.
5. **REFACTOR** -- clean up if needed (naming, duplication). Keep green.
6. Repeat 2-5 if multiple behaviors (rare for lightweight).
7. **Exception protocol:** if non-testable (CSS, config, migration), state why, specify alternate verification, proceed.
8. Pass to verify.

### Standard/Deep

1. Read blueprint.md. Extract per-unit context.
2. For each unit (sequential):
   a. Construct self-contained context: unit details (goal, files, approach, test scenarios), relevant durable decisions, relevant explorer findings, project conventions.
   b. Dispatch fresh opus subagent via Agent tool. Sonnet only for trivially mechanical tasks (color change, comment edit, single-line config).
   c. Subagent implements using TDD. See `references/tdd-guardrails.md` for the iron law and cycle.
   d. Handle return:
      - DONE → next step
      - BLOCKED → assess: context problem → re-dispatch with more context. Too large → break down. Genuine blocker → escalate to user.
      - NEEDS_CONTEXT → provide and retry
   e. Run agent extensions from `.docs/extend/craft.md` (fast checks: lint, style, patterns).
   f. Run skill extensions from `.docs/extend/craft.md` (domain workflows). Agents run first so skills work on clean code.
   g. Mini-review (inline, by orchestrator): tests pass, no stubs/placeholders, matches blueprint goal, quick correctness scan.
   h. Restate progress: `[x] Unit 1. [x] Unit 2. [ ] Unit 3 -- current. [ ] Unit 4.`

3. System-wide test check:
   - What fires when this runs? (callbacks, middleware, observers)
   - Do tests exercise the real chain? (not just mocked isolation)
   - Can failure leave orphaned state?

4. No automatic commits -- git workflow is user's choice.

## Output

Code changes, tests. No persisted artifact -- code IS the artifact.

## Gotchas

- Test behavior through public interfaces. Tests asserting implementation details break on refactor.
- Verify the test fails for the right reason. Wrong-reason failure proves nothing.
- Write one test, then one implementation. Not all tests then all code.
- Subagent gets everything upfront. No file path reading assignments.
- Sonnet for trivially mechanical only. Opus is the default.
- 4-fix circuit breaker: 4 failed fix attempts → STOP, question the approach, discuss with user. Investigation does not count as a fix attempt.
- Per-agent iteration cap: separate from 4-fix breaker. Projects set their own cap via evolve when retros show runaway sessions. When hit: agent pauses with status report to user, does not silently continue.
- 12 rationalization red flags: "I'll write test after", "too simple to test", "just manually verify", "obvious test", "need to see implementation first", "get it working then test", "just a refactor", "existing tests cover this", "tests in follow-up", "prototype/POC", "too hard to write", "watch mode shows passing".
