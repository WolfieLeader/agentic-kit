---
name: trace
description: >
  FIX-only gate. Reproduces reported issue, classifies it, assesses severity,
  and routes to done/craft/sketch. No artifact -- findings stay in session context.
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

- **Test**: run relevant test suite, read output, find failure
- **Browser**: navigate to reported location, observe behavior
- **Manual**: execute reported steps, compare actual vs expected
- **Logs**: search logs/error output for reported symptoms

If cannot reproduce after 2 attempts with different approaches, state clearly and ask user for more context.

### 2. Classify

| Classification | Definition | Next action |
|---|---|---|
| Real bug | Code behaves contrary to intent | Continue to step 3 |
| Environmental | Works in code, fails in env (deps, config, OS) | State finding, ask user |
| User error | Misuse of API/feature | State correct usage, done |
| Works as designed | Behavior is intentional | Explain design rationale, done |
| Incomplete info | Cannot determine | Ask user for specifics |

### 3. Quick hypothesis

Form directional hypothesis -- not committed, just a starting point.

- State what you think the root cause is
- State confidence (high/medium/low)
- State what would confirm or refute it

### 4. Assess severity

| Severity | Definition |
|---|---|
| Blocking | Feature unusable, no workaround, data loss risk |
| Degraded | Feature partially works or has workaround |
| Cosmetic | Visual/UX issue, functionality intact |

### 5. Dispatch extensions

If `.docs/extend/trace.md` exists, dispatch investigation agents defined there. Merge findings into context before routing.

### 6. Route

| Condition | Route |
|---|---|
| Not a bug (env/user error/WAD) | Done -- explain to user |
| Real bug, single file, obvious fix | Craft (lightweight) |
| Real bug, std/deep complexity | Sketch (std/deep) |

### 7. Upgrade heuristic

Propose upgrade from lightweight to std/deep if any:
- Fix touches 3+ files
- Fix spans 2+ subsystems
- Root cause unclear after initial investigation
- Reproduction reveals deeper systemic issue

User confirms before proceeding.

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

- Hypothesis is directional, not a commitment. Do not tunnel-vision on first guess.
- Upgrade heuristic is a proposal, not automatic. User must confirm tier change.
- Extension agents from `.docs/extend/trace.md` are optional -- file may not exist. Skip gracefully.
- If reproduction requires destructive action (DB reset, cache clear), warn user first.
- Symptom is not cause. "API returns 500" is a symptom -- push past it to the missing validation.
