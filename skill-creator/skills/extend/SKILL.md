---
name: extend
description: >
  Manage phase extensions. Use when adding, removing, or listing agent/skill
  extensions for framework phases (router, trace, craft, verify). Handles
  validation, cap enforcement, and extension registry in .docs/extend/.
type: user-invokable
---

# Extend

Register or remove agent and skill extensions for framework phases.

## Context

- User provides: agent/skill name + target phase
- Reads extension registry: `.docs/extend/<phase>.md`
- Reads agent/skill file from source directories
- Needs current extension count per phase to enforce caps

## Procedure

1. **Parse request.** Extract extension name, type (agent or skill), target phase, and action (add or remove).

2. **Validate phase.** Reject non-extendable phases with explanation:
   - `sketch` -- single-agent, no extension points
   - `blueprint` -- structured output, no extension points
   - `retro` -- retrospective analysis, no extension points
   - `explore` -- research phase, no extension points

3. **Validate extension type.** Only `craft` supports skill extensions. If user requests a skill extension for any other phase, reject with: "Only craft supports skill extensions. Other phases accept agent extensions only."

4. **Locate file.** Search in order:
   - `.claude/agents/<name>.md` (project agents)
   - `~/.claude/agents/<name>.md` (user agents)
   - `.claude/skills/<name>/SKILL.md` (project skills)
   - `~/.claude/skills/<name>/SKILL.md` (user skills)
   - If not found, report missing and abort.

5. **Determine source.** Set `source: project` if found under `.claude/`, `source: user` if under `~/.claude/`.

6. **Assess fit.** Check extension matches phase expectations:
   - **Router agents** -- must produce structured routing recommendations
   - **Trace agents** -- must produce structured dependency/impact findings
   - **Craft agents** -- must produce evidence-based findings with severity
   - **Craft skills** -- must follow standard skill format, produce per-unit output
   - **Verify agents** -- must use evidence-based finding format + severity scale (critical/high/medium/low)
   - If mismatch: suggest specific modifications, do not auto-reject.

7. **Enforce cap.** Read `.docs/extend/<phase>.md`. Count existing entries for the extension type. Caps:
   - Router: 2 agents
   - Trace: 2 agents
   - Craft: 2 agents + 2 skills (separate caps)
   - Verify: 3 agents
   - If at cap: reject, list current extensions, suggest replacing one.

8. **Write registry.** Create or update `.docs/extend/<phase>.md`:

For most phases:
```yaml
---
phase: <phase>
date_updated: YYYY-MM-DD
---

agents:
  - name: <extension-name>
    source: project | user
```

For craft (supports both types):
```yaml
---
phase: craft
date_updated: YYYY-MM-DD
---

agents:
  - name: <agent-name>
    source: project | user
skills:
  - name: <skill-name>
    source: project | user
```

9. **Confirm.** Print summary: extension name, type, phase, source, remaining capacity.

## Output

- Creates/updates `.docs/extend/<phase>.md`
- Prints confirmation with capacity remaining

## Gotchas

- All extensions are always-on. No conditional or per-task toggling. Every registered extension runs every time the phase executes.
- Craft extensions run per-unit. Adding craft agents/skills multiplies cost by number of units. Warn user about cost implications.
- Agent extensions must use evidence-based finding format with severity scale. If the agent file lacks this structure, surface it in step 6.
- Skill extensions fire sequentially after craft agents complete but before mini-review. Order within the skills list is execution order.
- Removing an extension: delete entry from YAML, update `date_updated`. If last entry removed, keep file with empty list (preserves phase registration).
