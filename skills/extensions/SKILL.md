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

Read the agent/skill file. Check for these structural markers per phase:

- **Router extensions**: file must contain `## Key Findings`, `## Relevant Files`,
  `## Open Questions` sections (or equivalent output format). Check: does the
  file define an output template matching this structure?
- **Diagnose extensions**: file must define investigation output with classification
  support. Check: does it produce findings that feed into the routing decision?
- **Craft agent extensions**: file must define pass/fail output per check.
  Check: does the output format include structured findings (not prose)?
- **Craft skill extensions**: file must have YAML frontmatter with `name:`.
  Check: does it follow the standard SKILL.md format with a Procedure section?
- **Verify extensions**: file must define severity-tagged findings (P0-P3) with
  file:line references. Check: does the output format match the code-reviewer's
  finding structure (Severity, File/line, Observed, Expected, Why)?

If format doesn't match: show the user what's missing and suggest specific
additions. Do not silently register an extension with incompatible output.

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

## References

- `references/registry.md` -- Extension types, integration points, output contracts, and examples per phase

## Gotchas

- All extensions are always-on -- no per-task toggling or conditional triggers.
- Lightweight craft skips extensions entirely.
- Extension caps are evolvable -- `/propose` can recommend raising a cap if retros show gaps.
- Agent extensions must use the same evidence-based finding format as framework agents.
