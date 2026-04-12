---
name: trace
description: >
  Use when the router classifies a task as FIX. Gate that determines if the
  issue is a real bug before committing to a fix pipeline.
phase: trace
type: internal
---

# Trace

Reproduction-first investigation. Confirms the bug exists, classifies it, and
routes to the right fix path. Does not fix anything.

## Context

- **Receives:** dispatch summary, explorer findings (if std/deep), user input
- **Reads:** source code, test output, browser/logs as needed, `.docs/extend/trace.md` (investigation specialists)
- **Dispatches:** extension investigation agents from `.docs/extend/trace.md`
- **Produces:** in-context trace summary (no persisted artifact)

## Procedure

### 1. Reproduce

Confirm the issue exists before anything else.

- **Test-based:** run existing tests, write a minimal failing test if none covers the path
- **Browser-based:** hit the relevant UI flow, capture the failure
- **Manual/log-based:** check logs, replicate the reported sequence

If the issue cannot be reproduced, say so. Ask the user for clarification or
additional repro steps. Do not hypothesize about unreproduced issues.

### 2. Classify

Determine what this actually is:

| Classification     | Meaning                                    |
|--------------------|--------------------------------------------|
| Real bug           | Code behaves contrary to intent            |
| Environmental      | Config, infra, or dependency issue         |
| User error         | Misuse or misunderstanding of the feature  |
| Works as designed  | Behavior is intentional                    |

### 3. Hypothesize (directional only)

Form a quick hypothesis about root cause. Stay tentative.

- "Looks like a race condition in the queue consumer"
- "Likely a missing null check on the optional field"
- NOT "The problem is X" — avoid committing prematurely

### 4. Assess Severity

| Level    | Criteria                                        |
|----------|-------------------------------------------------|
| Blocking | Core functionality broken, no workaround        |
| Degraded | Feature impaired but workaround exists           |
| Cosmetic | Visual/UX issue, functionality intact            |

### 5. Check Extensions

If `.docs/extend/trace.md` exists and defines investigation agents, dispatch
them for domain-specific analysis. Merge their findings with yours before
routing.

### 6. Route

Based on classification and severity:

- **Not a bug** → done. Tell the user what it actually is (environmental, user
  error, works as designed) with evidence.
- **Lightweight bug** → pass to **craft** directly. Trace context flows
  in-session — no artifact needed.
- **Std/deep bug** → pass to **sketch**. Trace context (reproduction result,
  hypothesis, severity) informs the FIX mode sections.

### 7. Upgrade Heuristic

If trace reveals any of:
- Fix touches 3+ files
- Fix spans 2+ subsystems
- Root cause unclear after initial investigation

Propose upgrade from lightweight to std/deep. User confirms before proceeding.

## Output

All output stays in-context. Nothing persisted to disk.

- **Reproduction result** — confirmed / not reproduced / partially reproduced
- **Classification** — real bug / environmental / user error / works as designed
- **Hypothesis** — directional root cause (tentative)
- **Severity** — blocking / degraded / cosmetic
- **Routing decision** — craft (lightweight) / sketch (std/deep) / done (not a bug)

## Gotchas

- **Reproduce before hypothesizing.** Confirm the bug exists before explaining
  why. Skipping reproduction leads to fixing the wrong thing.
- **Symptom ≠ cause.** "The API returns 500" is a symptom. The missing
  validation on line 42 is the cause. Trace must push past symptoms.
- **Stay tentative.** "Looks like" not "the problem is." Early commitment to a
  hypothesis creates confirmation bias in the fix phase.
- **Don't fix during trace.** Trace is an investigation gate. Resist the urge
  to patch while investigating — that's craft's job.
- **Environmental issues need evidence.** Don't classify as environmental
  without checking config, versions, or infra state.
