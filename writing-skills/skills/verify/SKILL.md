---
name: verify
description: >
  Use when craft phase is complete. Single verification step that scales
  by tier. Evidence-based -- no completion claims without fresh output.
phase: verify
type: internal
---

# Verify

## Context

Single step. Scales by tier. Evidence-based -- run the command, read the output, count failures, THEN claim.

**Lightweight:**
- Receives: diff, user's original request
- Reads: test output, build output
- Produces: verification evidence (in-context)
- Passes: -> retro

**Standard/Deep:**
- Receives: diff, sketch.md path, blueprint.md path
- Reads: test output, build output, sketch.md, blueprint.md, `.docs/extend/verify.md`
- Dispatches: unified code-reviewer agent (3 sequential passes) + extension reviewers from `.docs/extend/verify.md`
- Produces: verification evidence, review findings
- Passes: -> retro (after P0/P1 findings resolved)

## Procedure

### Lightweight

1. Run tests. Read output. Evidence before claims.
2. Confirm build clean.
3. Scan for stubs/placeholders. Hard ban: "TBD", "TODO", "etc.", "similar", "and so on", "as needed". Soft ban (flag + replace): "appropriate", "relevant", "necessary", "proper", "handle accordingly", "standard".
4. Quick diff scan -- does it match what was asked?
5. Report evidence. Pass to retro.

### Standard/Deep

**Verification (structural, automated, by orchestrator inline):**

1. Run full test suite. Read output. Count failures.
2. Confirm build clean.
3. Stub/placeholder scan (hard ban: TBD, TODO, etc., similar, and so on, as needed; soft ban: appropriate, relevant, necessary, proper, handle accordingly, standard).
4. Wiring check -- are new components actually connected? New exports used? New routes registered?
5. Sketch/blueprint compliance -- does implementation match spec?

**Review (multi-persona, subagent):**

6. Dispatch code-reviewer agent (opus, 3 sequential passes):
   - **Correctness:** logic errors, edge cases, state bugs, error propagation
   - **Testing:** coverage gaps, weak assertions, brittle tests
   - **Maintainability:** coupling, complexity, naming, dead code
7. If `.docs/extend/verify.md` exists, dispatch extension reviewers.
8. Receive findings. Act by priority:
   - **P0 (critical):** fix immediately
   - **P1 (high):** fix before proceeding
   - **P2 (moderate):** fix if straightforward
   - **P3 (low):** user's discretion
9. Orchestrator defends findings that contradict blueprint or durable decisions. Findings aligned with spec accepted. Rejected findings logged with reasoning for retro.
10. For each finding: verify against actual code before acting. Push back if technically wrong (with reasoning). Clarify ALL unclear items before implementing any.
11. No performative agreement. No sycophancy. Technical correctness over social comfort.
12. After P0/P1 resolved, pass to retro.

**Finding format (plain markdown, in-context):**

```
### [short title]
- **Severity:** P0 | P1 | P2 | P3
- **File/line:** path:line
- **Observed:** [what the code does]
- **Expected:** [what it should do]
- **Why:** [why this is a problem]
```

## Output

Verification evidence + review findings (in-context). No persisted artifact.

## Gotchas

- Run verification commands and read output. "Tests should pass" is not evidence.
- Check wiring. New components not connected to anything pass all tests and do nothing.
- Verify against sketch/blueprint, not just "does it compile."
- No "should pass", no "looks correct" -- only evidence.
- Iron law: NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE.
- Zero-finding halt: if review finds nothing, say so and stop. No inventing issues.
- Evidence-based findings only: file/line, observed, expected, why. Findings without specifics suppressed.
