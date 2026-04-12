# Retro Template

## YAML Frontmatter Schema

```yaml
---
title: Add notification system           # descriptive title
date_completed: 2026-04-11              # completion date (updated as living doc)
source_sketch: 260411-notifications      # omitted for lightweight (no sketch)
type: build                              # build | fix
tier: lightweight                        # lightweight | standard | deep
outcome: success                         # success | partial | failed
module: notifications                    # primary module affected
tags: [email, queue, workers]            # searchable tags
# FIX only:
severity: high                           # critical | high | medium | low
root_cause: poor-test-coverage           # enumerated category
---
```

Fields used by grep-first retrieval: `title`, `module`, `tags`, `type`, `tier`, `outcome`, `root_cause`.
Fields used by `/propose` pattern detection: `root_cause`, `module`, `tags`, `outcome`.

---

## BUILD Mode Template

### Context
<!-- Lightweight only. Omit for std/deep. -->

What was asked, what was found in codebase, approach taken. 2-3 sentences max.

### Result

**Status**: shipped | partial | blocked

Summary of what was delivered. Reference specific behaviors, not files.

- Delivered behavior 1
- Delivered behavior 2
- (If partial/blocked) What remains and why

### What We Learned

Technical discoveries and codebase insights gained during this session.

- Discovery 1 — implication
- Discovery 2 — implication

### What Went Well

Decisions and process steps that worked.

- Thing that worked — why it worked

### What Went Wrong

Failures, rework, surprises. Use root cause categories.

| Issue | Root Cause Category | Detail |
|---|---|---|
| description | category from list | what happened and why |

Root cause categories:
- Poor user description
- Incorrect scope/tier
- Poor sketch decisions
- Stale research/docs
- Poor CLAUDE.md
- Poor code patterns/structure
- Poor test coverage
- Poor enforcement
- Model capability gap
- Poor model assignment
- Poor skill behavior
- External/environmental

### Action Items

Concrete improvements. Each must have an owner and target.

| Action | Target | Notes |
|---|---|---|
| Update CLAUDE.md with X convention | CLAUDE.md | discovered during craft |
| Add test for Y edge case | test suite | missed in blueprint |
| Update MAP.md with new Z module | MAP.md | new module added |

---

## FIX Mode Template

### Context
<!-- Lightweight only. Omit for std/deep. -->

What was reported, what investigation found, approach taken. 2-3 sentences max.

### Result

**Status**: fixed | partial | workaround

Summary of fix outcome.

- What was fixed
- (If workaround) Temporary measure and timeline for proper fix
- (If partial) What remains broken and why

### Root Cause

The actual root cause. May differ from initial hypothesis.

**Initial hypothesis**: (from trace)
**Actual root cause**: (discovered during investigation/fix)
**Hypothesis accuracy**: correct | partially correct | wrong

If wrong, explain what the real cause was and why initial hypothesis was off.

### What Didn't Work

Investigation dead ends and failed fix attempts. Valuable for future similar bugs.

| Attempt | What was tried | Why it failed |
|---|---|---|
| 1 | description | reason |
| 2 | description | reason |

### Fix

What actually fixed it and why.

- **Change**: behavioral description of the fix
- **Why it works**: root cause explanation linking to the change
- **Confidence**: HIGH/MED/LOW that this fully resolves the issue

### What Went Well / What Went Wrong

Process observations (same format as BUILD mode).

**Went well**:
- observation

**Went wrong**:

| Issue | Root Cause Category | Detail |
|---|---|---|
| description | category | what happened |

### Prevention

How to prevent this class of bug from recurring.

| Prevention measure | Type | Notes |
|---|---|---|
| Add test for edge case X | Test coverage | prevents regression |
| Add validation for input Y | Code pattern | catches bad input early |
| Update docs on behavior Z | Documentation | prevents misunderstanding |

---

## Living Document Updates

Retro gets updated during user testing. Append updates, don't overwrite initial content.

### Update Format

```markdown
---
### Update [N] — YYYY-MM-DD

**User feedback**: summary of what user reported
**Resolution**: what was done
**Verification**: evidence that resolution works
**Retro impact**: any new What Went Wrong items or action items
---
```

### Finalization

When user confirms or session ends, update frontmatter:
```yaml
status: final
updated: YYYY-MM-DD
```
