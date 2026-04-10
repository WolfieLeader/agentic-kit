# Brainstorm Document Template

Use this template when writing `.docs/work/YYMMDD-<slug>/brainstorm.md` in Phase 5.

The brainstorm.md captures **decisions and their rationale** — not a transcript. Write it so `/plan` reading it in a fresh session has full context without conversation history. Write it so a teammate who was NOT in the brainstorm conversation can understand what was decided and why.

## Full Template (Standard / Deep Scope)

```markdown
---
title: "[Descriptive title, not the slug]"
date: YYYY-MM-DD
type: build | fix | explore
scope: standard | deep
status: draft | complete
module: [primary module this work targets]
tags: [searchable, keywords, for, grep]
affected_systems: [list of systems touched]
resume_from: [section number when status is draft, omit when complete]
---

## Purpose & Context

[What we're building and why. The problem this solves. What triggered this work.]

## Requirements

Requirements use stable IDs (R1, R2, R3...) so that `/plan` implementation units, reviews, and discussions can reference specific requirements unambiguously. IDs are permanent — never renumber after assignment.

**[Group Header]**
- R1. [Concrete requirement]
- R2. [Concrete requirement]

**[Group Header]**
- R3. [Concrete requirement]

Group by logical theme when requirements span distinct concerns. Requirements keep original IDs — numbering does not restart per group. Skip grouping when all requirements address the same concern.

## Scope & Boundaries

### In Scope
- [Concrete item]
- [Concrete item]

### Out of Scope
- [Concrete item — why excluded]
- [Concrete item — why excluded]

## Affected Systems

### Direct Changes

| System | Role in This Change |
|--------|-------------------|
| [System name] | [How it's directly modified] |

Only include systems with an actual role. Do not list every system in the project.

### Cross-Platform Contracts

[API shapes, shared types, or data formats that cross system boundaries. When a backend API changes, which clients consume it? When a mobile data model changes, does the backend need to know?]

| Contract | Producer | Consumer(s) | Impact |
|----------|----------|-------------|--------|
| [API endpoint / shared type / event] | [System that owns it] | [Systems that consume it] | [What changes for consumers] |

[If no cross-platform contracts are affected: "No cross-platform contracts affected — change is contained within [system]."]

### Integration Points

[Third-party services, SDKs, or external APIs involved. These have different risk profiles from internal systems — you don't control their versioning, uptime, or behavior.]

| Service | How It's Involved | Key Constraints |
|---------|------------------|-----------------|
| [Service name] | [What this change does with it] | [Rate limits, API version, webhook behavior, etc.] |

[If no third-party integrations: "No third-party integrations involved."]

## Research Context

[Summary of what code-explorer and docs-explorer found:]
- **code-explorer:** Search terms used, key findings, relevant files discovered
- **docs-explorer:** Search terms used, existing decisions found, external research conducted (with dates)
- **Not covered:** Areas the agents did NOT search — budget limits, agent failures, search misses. What remains unexplored?

[If an agent failed or returned empty, state that explicitly — never omit this section.]

## Chosen Approach

[D1. The selected approach — what it is, how it works at the architecture level, and why it was chosen over alternatives.]

### Alternatives Considered

**[Approach Name]:** [1-2 sentences. Why rejected — name the specific constraint, risk, or tradeoff. "Not as good" is not a reason.]

**[Approach Name]:** [1-2 sentences. Why rejected — specific constraint, risk, or tradeoff.]

Alternatives must come from different solution axes. If the chosen approach is "build a new service," alternatives should include "use an existing library" or "extend an existing service" — not "build a slightly different new service."

## Key Constraints & Risks

- **[D2. Constraint/Risk]:** [Description. Mitigation if exists. Affected: R1, R3]
- **[D3. Constraint/Risk]:** [Description. Mitigation if exists. Affected: R2]

## Success Criteria

- [ ] [R1] [Concrete, testable condition traceable to a requirement]
- [ ] [R2] [Concrete, testable condition traceable to a requirement]
- [ ] [R3] [Concrete, testable condition traceable to a requirement]

Each success criterion must trace to at least one requirement ID. Every requirement must have at least one success criterion.

## Open Questions

### Must Resolve Before Planning
[Questions that block /plan. Tag each with affected R-IDs.]

- [Affects R1] [Question that must be answered before planning]

[If none: "None — all blocking questions resolved during brainstorming."]

### Deferred to Planning
[Questions where the answer depends on implementation details /plan will determine.]

- [Affects R3] [Question answerable during planning or codebase exploration]

[If none: "None."]
```

## Minimal Template (Lightweight Scope)

```markdown
---
title: "[Title]"
date: YYYY-MM-DD
type: build | fix | explore
scope: lightweight
status: draft | complete
module: [primary module]
tags: [keywords]
affected_systems: [comma-separated list]
---

## Purpose
[One or two sentences: what and why.]

## Research
[One-line summary per agent, or "No existing implementation found." If an agent failed, state that.]

## Scope
[What's in, what's out — brief.]
- R1. [In-scope item]
- R2. [In-scope item, if applicable]

## Approach
[D1. What we're doing and a one-line rationale.]

## Constraints
[Key risks or limitations. "None identified" if truly none.]

## Success Criteria
- [ ] [R1] [How we know it's done]
- [ ] [R2] [How we know it's done, if applicable]
```

## Writing Rules

1. **Decisions, not history.** Write what was decided, not how the conversation got there.
2. **No placeholders.** Every section has real content or explicit "N/A — [reason]". Hard-ban: "TBD", "TODO", "etc.", "and so on". **Implementing agent test:** if an agent reading this phrase would need to make a judgment call about what it means, it is a placeholder.
3. **Repo-relative paths only.** Never absolute paths.
4. **No implementation details.** No schemas, endpoint specs, file paths to modify, or pseudo-code — those belong in `/plan`. Test: "Would removing this change a brainstorm decision?" If no, omit it.
5. **Alternatives mandatory** for standard/deep. Rejection reasons MUST name a specific constraint, risk, or tradeoff. Alternatives MUST come from different solution axes.
6. **Open Questions split into blocking vs. deferred.** This is the bridge to `/plan`. Tag each with affected R-IDs. If all resolved, say so explicitly.
7. **Set `status: complete`** only after review passes. A `status: draft` signals downstream skills the artifact may be incomplete.
8. **Requirement IDs are permanent.** Once R1 is assigned, it stays R1. Never renumber. Deleted requirements leave a gap.
9. **No retroactive weakening.** Do not soften, qualify, or narrow decisions from earlier sections without explicitly noting the change and justification. If Section 5 reveals a Section 2 commitment is infeasible, call it out — never silently reduce scope.
10. **Affected systems is not a checklist.** Only include systems with an actual role. Use the "No cross-platform contracts affected" or "No third-party integrations involved" shorthand when sections don't apply — don't fill them with empty rows.
11. **Team-readable.** Write for a developer who was NOT in the brainstorm conversation. Avoid shorthand, inside references, or context that only makes sense if you were there.
