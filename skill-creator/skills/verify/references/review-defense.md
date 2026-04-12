# Review Defense Protocol

How the orchestrator handles review findings from the code-reviewer agent and extension reviewers. Defense is not adversarial — it ensures only valid findings drive changes.

---

## Receiving Findings

### Step 1: Verify each finding against actual code

Before acting on ANY finding:

1. Read the specific code the finding references
2. Determine if the finding accurately describes what the code does
3. Check if the finding's suggested concern is real in context

**Never act on a finding without reading the referenced code first.**

### Step 2: Classify each finding

| Classification | Action |
|---|---|
| Valid + actionable | Accept, prioritize, fix |
| Valid + not actionable | Accept, log for future (P3) |
| Technically wrong | Reject with evidence |
| Unclear | Clarify before acting |
| Contradicts durable decision | Threshold defense (see below) |

### Step 3: Clarify ALL unclear items before implementing ANY

Do not start fixing findings while unclear items remain. Unclear findings may change the priority or approach to other findings.

Ask reviewer agent for:
- Specific code location
- Concrete example of the problem
- Suggested alternative

---

## Threshold Defense

When a review finding contradicts a durable decision from the blueprint:

### 1. Identify the conflict

State clearly:
- The finding: what the reviewer wants changed
- The durable decision: what the blueprint specifies
- The conflict: why they cannot both be true

### 2. Defend the decision

Durable decisions were made during blueprint with full context. Reviewers see code in isolation. The decision stands unless:

- New evidence emerged during implementation that wasn't available at blueprint time
- The implementation revealed the decision is technically infeasible
- The security implications were not considered

### 3. Override conditions

If override is warranted:
1. State what new evidence justifies overriding
2. Update the durable decision in blueprint.md
3. Check ripple effects on other units
4. Proceed with the change

If override is NOT warranted:
1. Reject the finding with rationale
2. Reference the durable decision
3. Log the disagreement for retro

---

## Push-Back Protocol

When a finding is technically wrong:

### Template

```
REJECTED: [finding summary]

Evidence: [specific code reference showing finding is wrong]

Reasoning: [why the reviewer's concern doesn't apply in this context]

Code state: [what the code actually does vs what reviewer thinks it does]
```

### Rules for push-back

- Must include evidence (file:line reference)
- Must include reasoning (not just "I disagree")
- Must be specific (not "the reviewer is wrong about everything")
- Tone: professional, factual, no sarcasm

---

## Anti-Sycophancy Rules

1. **No performative agreement**: Do not say "great catch" or "good point" unless the finding is genuinely valuable
2. **No bulk acceptance**: Do not accept all findings to avoid conflict
3. **No hedging**: If a finding is wrong, say it's wrong. Don't say "this might not apply"
4. **No scope creep**: Findings that suggest improvements beyond the original scope are P3/deferred, not acted on
5. **No gold plating**: Findings suggesting additional abstractions, patterns, or optimizations not in the blueprint are rejected unless they fix actual bugs

---

## Priority Resolution

### P0 — Critical

Fix immediately. No other work until resolved.
- Security vulnerability
- Data loss/corruption
- Application crash

### P1 — High

Fix before proceeding to retro.
- Bug in new code
- Missing error handling for likely cases
- Test coverage gap for core behavior

### P2 — Medium

Fix if straightforward (under 5 minutes of work).
- Code quality improvement
- Minor naming issue
- Small refactoring opportunity

If fix is not straightforward, log for retro action items.

### P3 — Low

User discretion. Present to user, let them decide.
- Style preferences
- Optional optimizations
- Future-proofing suggestions

---

## Feeding Rejected Findings Into Retro

All rejected findings get logged in retro under "What Went Wrong" or action items:

- If reviewer consistently makes wrong findings about a pattern: action item to update CLAUDE.md or project conventions
- If reviewer misunderstands architecture: action item to update MAP.md
- If finding was wrong due to stale context: action item to update research docs
- If finding reveals skill/agent behavior issue: action item to update agent prompt

This feedback loop improves future reviews without accepting bad findings in the current review.
