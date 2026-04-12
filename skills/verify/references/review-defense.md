# Review Defense Protocol

Defense is not adversarial -- it ensures only valid findings drive changes.

## Step 1: Verify Against Actual Code

Before acting on ANY finding:
1. Read the specific code the finding references
2. Determine if the finding accurately describes what the code does
3. Check if the concern is real in context

**Never act on a finding without reading the referenced code first.**

## Step 2: Classify Each Finding

| Classification | Action |
|---|---|
| Valid + actionable | Accept, prioritize, fix |
| Valid + not actionable | Accept, log for future (P3) |
| Technically wrong | Reject with evidence |
| Unclear | Clarify before acting |
| Contradicts durable decision | Threshold defense (see below) |

## Step 3: Clarify Before Acting

Do not start fixing findings while unclear items remain. Unclear findings may change the priority or approach to other findings. Ask reviewer for: specific code location, concrete example, suggested alternative.

## Threshold Defense

When a finding contradicts a durable decision from the blueprint:

**Defend the decision.** Durable decisions were made with full context. Reviewers see code in isolation. The decision stands unless:
- New evidence emerged during implementation not available at blueprint time
- Implementation revealed the decision is technically infeasible
- Security implications were not considered

**If override warranted:**
1. State what new evidence justifies overriding
2. Update the durable decision in blueprint.md
3. Check ripple effects on other units
4. Proceed with the change

**If override NOT warranted:**
1. Reject the finding with rationale
2. Reference the durable decision
3. Log disagreement for retro

## Push-Back Protocol

When a finding is technically wrong, REJECTED requires:

```
REJECTED: [finding summary]
Evidence: [file:line reference showing finding is wrong]
Reasoning: [why the concern doesn't apply in this context]
Code state: [what the code actually does vs what reviewer thinks]
```

Rules: must include evidence (file:line), must include reasoning, must be specific, tone professional and factual.

## Anti-Sycophancy Rules

1. **No performative agreement** -- don't say "great catch" unless genuinely valuable
2. **No bulk acceptance** -- don't accept all findings to avoid conflict
3. **No hedging** -- if a finding is wrong, say it's wrong, not "might not apply"
4. **No scope creep** -- improvements beyond original scope are P3/deferred
5. **No gold plating** -- additional abstractions/patterns not in blueprint are rejected unless they fix actual bugs

## Priority Resolution

| Priority | Action |
|---|---|
| P0 -- Critical | Fix immediately. Security, data loss, crash. |
| P1 -- High | Fix before retro. Bugs, missing error handling, coverage gaps. |
| P2 -- Medium | Fix if <5 min, else log for retro. Quality, naming, minor refactors. |
| P3 -- Low | User discretion. Style, optional optimizations, future-proofing. |

## Feeding Rejected Findings Into Retro

All rejected findings logged in retro:
- Wrong findings about a pattern -> update CLAUDE.md or project conventions
- Misunderstood architecture -> update MAP.md
- Wrong due to stale context -> update research docs
- Reveals skill/agent issue -> update agent prompt
