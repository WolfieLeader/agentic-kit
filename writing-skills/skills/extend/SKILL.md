---
name: extend
description: >
  Use when adding agents or skills to framework phases. Inspects fit,
  suggests modifications, updates .docs/extend/ configuration.
type: user-invokable
---

# Extend

Registers agent or skill extensions into framework phases. Validates fit,
checks caps, updates the phase's extension manifest.

## Context

- **Receives:** agent/skill name and target phase from user
- **Reads:** the agent/skill file, `.docs/extend/<phase>.md` (if exists)
- **Produces:** updated `.docs/extend/<phase>.md`

## Procedure

### 1. Accept Input

Get agent/skill name and target phase from user.

### 2. Validate Phase

Extendable phases: **router, trace, craft, verify**.

Reject these with explanation: sketch, blueprint, retro, explore —
"single-agent or conversational — no dispatch point for extensions."

### 3. Validate Extension Type

- **Agent extensions:** all extendable phases (router, trace, craft, verify).
- **Skill extensions:** craft ONLY. Reject for other phases —
  "only craft supports skill extensions because it's the only phase where
  extensions do work, not just report findings."

### 4. Locate the File

Search in order:

| Type   | Project path         | User path         |
|--------|----------------------|-------------------|
| Agents | `.claude/agents/`    | `~/.claude/agents/` |
| Skills | `.claude/skills/`    | `~/.claude/skills/` |

If not found, tell user where to create it.

### 5. Assess Fit

Does the extension's role match the phase's expectations?

- **Router extensions:** must return structured output (Key Findings,
  Relevant Files, Open Questions).
- **Trace extensions:** must provide investigation findings.
- **Craft agent extensions:** must return structured findings (fast checks).
- **Craft skill extensions:** must follow standard skill format.
- **Verify extensions:** must use evidence-based finding format with
  severity scale (P0-P3).

Suggest modifications if format doesn't match.

### 6. Check Extension Cap

| Phase  | Framework agents               | Extension cap |
|--------|--------------------------------|---------------|
| Router | 2 (code + docs explorer)       | 2             |
| Trace  | 0                              | 2             |
| Craft  | 0                              | 2             |
| Verify | 1 (unified code-reviewer)      | 3             |

If cap reached: reject, suggest replacing an existing extension.

### 7. Write Extension Manifest

Create or update `.docs/extend/<phase>.md`:

```yaml
---
phase: [phase name]
date_updated: [YYYY-MM-DD]
---

agents:
  - name: [agent-name]
    source: project | user

# craft only:
skills:
  - name: [skill-name]
    source: project | user
```

## Output

Updated `.docs/extend/<phase>.md`.

## Gotchas

- All extensions are always-on — no conditional triggers.
- Lightweight craft skips extensions entirely.
- Extension caps are evolvable — `/propose` can recommend raising a cap
  if retros show gaps.
- Agent extensions must use the same evidence-based finding format as
  framework agents.
