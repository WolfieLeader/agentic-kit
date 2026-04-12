---
name: trace
description: >
  FIX-only gate. Reproduces reported issue, classifies it, assesses severity,
  and routes to done/craft/sketch. No artifact — findings stay in session context.
phase: trace
type: internal
---

## Context

Receives:
- Dispatch summary from start (issue description, tier assignment)
- Explorer findings (if std/deep tier)
- User input describing the problem

Reads:
- Source code relevant to reported issue
- Test output, browser console, logs as applicable
- `.docs/extend/trace.md` for extension investigation agents

## Procedure

### 1. Reproduce

Confirm the issue exists. Pick the fastest path:

- **Test**: Run relevant test suite, read output, find failure
- **Browser**: Navigate to reported location, observe behavior
- **Manual**: Execute reported steps, compare actual vs expected
- **Logs**: Search logs/error output for reported symptoms

Gate: **EVIDENCE-BEFORE-CLAIMS** — run the reproduction, read the output, then state whether reproduced. Never assume from description alone.

If cannot reproduce after 2 attempts with different approaches, state clearly and ask user for more context.

### 2. Classify

Determine issue type:

| Classification | Definition | Next action |
|---|---|---|
| Real bug | Code behaves contrary to intent | Continue to step 3 |
| Environmental | Works in code, fails in env (deps, config, OS) | State finding, ask user |
| User error | Misuse of API/feature | State correct usage, done |
| Works as designed | Behavior is intentional | Explain design rationale, done |
| Incomplete info | Cannot determine | Ask user for specifics |

### 3. Quick hypothesis

Form directional hypothesis. Not committed — just a starting point.

- State what you think the root cause is
- State confidence (high/medium/low)
- State what would confirm or refute it

Gate: **INVESTIGATE-THEN-FIX** — hypothesis comes from evidence, not guessing.

### 4. Assess severity

| Severity | Definition |
|---|---|
| Blocking | Feature unusable, no workaround, data loss risk |
| Degraded | Feature partially works or has workaround |
| Cosmetic | Visual/UX issue, functionality intact |

### 5. Dispatch extensions

If `.docs/extend/trace.md` exists, dispatch investigation agents defined there. These run domain-specific checks (security implications, data integrity, etc.) and feed findings back into context.

### 6. Route

| Condition | Route |
|---|---|
| Not a bug (env/user error/WAD) | Done. Explain to user. |
| Real bug, single file, obvious fix | Craft (lightweight) |
| Real bug, std/deep complexity | Sketch (std/deep) |

### 7. Upgrade heuristic

If any of these are true, propose upgrade from lightweight to std/deep:
- Fix touches 3+ files
- Fix spans 2+ subsystems
- Root cause unclear after initial investigation
- Reproduction reveals deeper systemic issue

Present upgrade rationale to user. User confirms before proceeding.

## Output

All findings remain in session context (no artifact file):
- Reproduction result (reproduced / not reproduced / partial)
- Classification
- Hypothesis with confidence
- Severity assessment
- Extension findings (if any)
- Routing decision with rationale

Passes to: done | craft (lightweight) | sketch (std/deep)

## Gotchas

- Never skip reproduction. "User said X" is not evidence. Run it. Read output. Then classify.
- Hypothesis is directional, not a commitment. Do not tunnel-vision on first guess.
- Upgrade heuristic is a proposal, not automatic. User must confirm tier change.
- Extension agents from `.docs/extend/trace.md` are optional — file may not exist. Skip gracefully.
- If reproduction requires destructive action (DB reset, cache clear), warn user first.
