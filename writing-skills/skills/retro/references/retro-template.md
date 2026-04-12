---
title: Retro Template
type: reference
parent_skill: retro
---

# Retro Template

## YAML Frontmatter

```yaml
---
title: [descriptive title]
date_completed: [YYYY-MM-DD]
source_sketch: [slug, omitted for lightweight]
type: build | fix
tier: lightweight | standard | deep
outcome: success | partial | failed
module: [primary module]
tags: [relevant tags]
# FIX only:
severity: critical | high | medium | low
root_cause: [category tag]
---
```

## BUILD Retro Sections

- **Context** (lightweight only) -- what was asked, what was found, approach taken. 2-3 sentences.
- **Result** -- what was delivered.
- **What We Learned** -- technical insights worth remembering.
- **What Went Well** -- what to repeat.
- **What Went Wrong** -- free-text explanation first, then category tag. See root cause categories below.
- **Action Items** -- immediate follow-ups (if any).

## FIX Retro Sections

- **Context** (lightweight only) -- what was asked, what was found, approach taken. 2-3 sentences.
- **Result** -- what was fixed.
- **Root Cause** -- technical explanation of why it broke.
- **What Didn't Work** -- investigation dead ends and why they failed.
- **Fix** -- the actual solution and why it works.
- **What Went Well** / **What Went Wrong** -- same as BUILD.
- **Prevention** -- how to avoid recurrence (test, guard, pattern change).

## Root Cause Categories

Use for tagging "What Went Wrong" entries. Free-text explanation first, category second.

| Category | Meaning |
|---|---|
| Poor user description | Ambiguous, incomplete, or misleading request |
| Incorrect scope/tier | Router misclassified lightweight/standard/deep |
| Poor sketch decisions | Wrong approach chosen, missed constraints |
| Stale research/docs | Research or docs contain outdated information |
| Poor CLAUDE.md | Project instructions missing or misleading |
| Poor code patterns/structure | Codebase structure caused confusion or bugs |
| Poor test coverage | Pre-existing gap in tests |
| Poor enforcement | Verification didn't catch a problem |
| Model capability gap | Agent produced incorrect output due to model limitations |
| Poor model assignment | Wrong model tier for the role |
| Poor skill behavior | Framework bug |
| External/environmental | Third-party service, CI, environment issue |
