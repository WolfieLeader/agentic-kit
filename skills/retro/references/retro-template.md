# Retro Template

## YAML Frontmatter

```yaml
---
title: Add notification system           # descriptive title
date_completed: 2026-04-11              # updated as living doc
source_sketch: 260411-001-notifications  # omit for lightweight
type: build                              # build | fix
tier: lightweight                        # lightweight | standard | deep
outcome: success                         # success | partial | failed
module: notifications                    # primary module affected
affected_modules: [notifications, queue] # all modules touched (omit if single-module)
tags: [email, queue, workers]            # searchable tags
token_effort: medium                     # low (0-1 retries) | medium (2-3 retries) | high (4+ retries or circuit breaker)
severity: high                           # FIX only: critical | high | medium | low
root_cause: poor-test-coverage           # FIX only: enumerated category
---
```

---

## BUILD Mode

### Context
<!-- Lightweight only. Omit for std/deep. -->
What was asked, what was found, approach taken. 2-3 sentences.

### Result
**Status**: shipped | partial | blocked
- Delivered behaviors; (if partial/blocked) what remains and why

### What We Learned
- Discovery -- implication

### What Went Well
- Thing that worked -- why

### What Went Wrong
| Issue | Root Cause Category | Detail |
|---|---|---|
| description | category | what happened and why |

### Action Items
| Action | Target | Notes |
|---|---|---|
| description | target file/area | context |

---

## FIX Mode

### Context
<!-- Lightweight only. Omit for std/deep. -->
What was reported, what investigation found, approach taken. 2-3 sentences.

### Result
**Status**: fixed | partial | workaround
- What was fixed; (if workaround/partial) what remains and why

### Root Cause
**Initial hypothesis**: (from diagnose) | **Actual root cause**: (from fix) | **Accuracy**: correct | partial | wrong

### What Didn't Work
| Attempt | What was tried | Why it failed |
|---|---|---|
| 1 | description | reason |

### Fix
- **Change**: behavioral description
- **Why it works**: root cause linked to change
- **Confidence**: HIGH / MED / LOW

### What Went Well / What Went Wrong
Same table format as BUILD mode.

### Prevention
| Measure | Type | Notes |
|---|---|---|
| description | Test coverage / Code pattern / Docs | context |

---

## Root Cause Categories

Poor user description, Incorrect scope/tier, Poor sketch decisions, Stale research/docs, Poor CLAUDE.md, Poor code patterns/structure, Poor test coverage, Poor enforcement, Model capability gap, Poor model assignment, Poor skill behavior, External/environmental.

---

## Living Document Updates

Append during user testing -- never overwrite initial content.

```markdown
### Update [N] -- YYYY-MM-DD
**User feedback**: summary
**Resolution**: what was done
**Verification**: evidence it works
**Retro impact**: new What Went Wrong items or action items
```

Finalization -- update frontmatter: `outcome: success | partial | failed`, `date_completed: YYYY-MM-DD`.
