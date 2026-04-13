# Diagnose Template

## YAML Frontmatter Schema

```yaml
---
title: Login crash on token refresh
date: 2026-04-13
type: diagnose
source_task: 260413-002-login-crash     # slug of parent task
module: auth
tags: [jwt, refresh, session]
classification: real-bug                 # real-bug | environmental | user-error | works-as-designed | incomplete-info
severity: blocking                       # blocking | degraded | cosmetic
hypothesis: Missing mutex on token refresh causes race condition
confidence: high                         # high | medium | low
reproduced: true                         # true | false | partial
routed_to: sketch                        # craft | sketch | done
---
```

Fields used by grep-first retrieval: `module`, `tags`, `classification`, `severity`, `confidence`.

## Sections

### Reproduction
Steps taken, expected vs actual, environment.
**Reproduction status**: Reproduced / Partial / Not reproduced

### Classification
Why this classification was chosen. Evidence for/against alternatives.

### Root Cause Hypothesis
What we think is wrong, supporting evidence, what would refute it.

### Severity Assessment
Impact, workaround availability, data loss risk.

### Extension Findings
If extension agents dispatched. Omit section if none.

### Routing Decision
Where this goes next and why. If upgrade proposed, state rationale.
