---
name: extensions
description: >
  Use when: user wants to add a project-specific agent or skill to a pipeline
  phase (router, diagnose, craft, verify). Validates fit, checks phase caps,
  updates .docs/extensions/ configuration.
type: user-invokable
---

## Context

Receives:
- Agent/skill name and target phase from user

Reads:
- The agent/skill file
- `.docs/extensions/<phase>.md` (if exists)

Produces:
- Updated `.docs/extensions/<phase>.md`

## Procedure

### 1. Accept input

Get agent/skill name and target phase from user.

### 2. Validate phase

Extendable phases: **router, diagnose, craft, verify**.

Reject with explanation: sketch, blueprint, retro, explore -- "single-agent or conversational -- no dispatch point for extensions."

### 3. Validate extension type

- **Agent extensions**: all extendable phases (router, diagnose, craft, verify).
- **Skill extensions**: craft only. Reject for other phases -- "only craft supports skill extensions because it's the only phase where extensions do work, not just report findings."

### 4. Locate the file

Search in order:

| Type | Project path | User path |
|---|---|---|
| Agents | `.claude/agents/` | `~/.claude/agents/` |
| Skills | `.claude/skills/` | `~/.claude/skills/` |

If not found, tell user where to create it.

### 5. Assess fit

Does the extension match the phase's expectations?

- **Router extensions**: must return structured output (Key Findings, Relevant Files, Open Questions)
- **Diagnose extensions**: must provide investigation findings
- **Craft agent extensions**: must return structured findings (fast checks)
- **Craft skill extensions**: must follow standard skill format
- **Verify extensions**: must use evidence-based finding format with severity (P0-P3)

Suggest modifications if format doesn't match.

### 6. Check extension cap

| Phase | Framework agents | Extension cap |
|---|---|---|
| Router | 2 (code + docs explorer) | 2 |
| Diagnose | 0 | 2 |
| Craft | 0 | 2 agents + 2 skills |
| Verify | 1 (unified code-reviewer) | 3 |

If cap reached: reject, suggest replacing an existing extension.

### 7. Write extension manifest

Create or update `.docs/extensions/<phase>.md`:

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

Updated `.docs/extensions/<phase>.md`.

## Gotchas

- All extensions are always-on -- no per-task toggling or conditional triggers.
- Lightweight craft skips extensions entirely.
- Extension caps are evolvable -- `/propose` can recommend raising a cap if retros show gaps.
- Agent extensions must use the same evidence-based finding format as framework agents.
