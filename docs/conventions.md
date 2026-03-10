# Conventions

Naming and structure conventions for the agentic-kit monorepo.

## Repository Layout

```
agentic-kit/
├── plugins/           # Each subdirectory is an independent plugin
│   ├── plugin-a/
│   ├── plugin-b/
│   └── ...
├── docs/              # Monorepo-level documentation
├── README.md
└── LICENSE
```

- Monorepo with a flat `plugins/` directory
- Each plugin is fully self-contained and independently installable
- Convention-over-configuration: directory structure IS the API

## Plugin Structure

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json        # Required — minimal manifest
├── skills/                # Required — at least one skill
│   └── skill-name/
│       └── SKILL.md
├── agents/                # Optional
├── hooks/                 # Optional
├── commands/              # Optional
├── lib/                   # Optional — shared code
├── docs/                  # Optional — plugin-specific docs
├── tests/                 # Optional
└── README.md              # Optional
```

## Naming Conventions

| Component        | Convention    | Examples                               |
| ---------------- | ------------- | -------------------------------------- |
| Plugin directory | kebab-case    | `scaffolding`, `git-workflows`         |
| Skill directory  | kebab-case    | `node-project`, `pr-creation`          |
| Skill main file  | UPPERCASE     | `SKILL.md` (always)                    |
| Agent file       | kebab-case.md | `api-reviewer.md`, `code-architect.md` |
| Command file     | kebab-case.md | `scaffold.md`, `execute-plan.md`       |
| Shell scripts    | imperative    | `validate.sh`, `run-hook.cmd`          |

Cross-plugin references use qualified names: `plugin-name:component-name`.

## plugin.json Manifest

Only `name` and `description` are required.

```json
{
  "name": "plugin-name",
  "description": "What this plugin does",
  "version": "0.1.0",
  "author": { "name": "WolfieLeader" },
  "repository": "https://github.com/WolfieLeader/agentic-kit",
  "license": "MIT",
  "keywords": ["keyword1", "keyword2"]
}
```

Optional: add `marketplace.json` in `.claude-plugin/` for marketplace listing.

## SKILL.md Format

### Frontmatter

```yaml
---
name: skill-name
description: >-
  This skill should be used when the user asks to "trigger phrase 1",
  "trigger phrase 2", or mentions specific-topic.
version: 0.1.0
---
```

- `name` and `description` are required; `version` is optional
- Description uses third person: "This skill should be used when..."
- Include exact trigger phrases in the description (these drive skill activation)

### Body

- Written in imperative/infinitive form ("Create X by doing Y", not "You should create X")
- No second person ("you should...")
- Target 1,500–2,000 words; never exceed 3,000
- Use progressive disclosure: lean SKILL.md + detailed `references/` subdirectory

### Skill Directory Structure

```
skill-name/
├── SKILL.md              # Required — main skill file
├── references/           # Optional — detailed docs for progressive disclosure
│   ├── patterns.md
│   └── advanced.md
├── examples/             # Optional — working code examples
│   └── example.sh
├── scripts/              # Optional — utilities
│   └── validate.sh
└── assets/               # Optional — templates, output resources
    └── template/
```

Reference files from SKILL.md like this:

```markdown
## Additional Resources

### Reference Files

- **`references/patterns.md`** — Detailed patterns

### Examples

- **`examples/example.sh`** — Working example
```

## Agent File Format

```yaml
---
name: agent-name
description: Clear description of what agent does and when to use it
tools: [Read, Grep, Glob, Bash]
---
# Agent Title

[System prompt: mission statement, step-by-step approach, output guidance]
```

| Field         | Required | Notes                                         |
| ------------- | -------- | --------------------------------------------- |
| `name`        | Yes      | kebab-case identifier                         |
| `description` | Yes      | When to use this agent                        |
| `tools`       | No       | Explicit tool restrictions for security/focus |

Agent specialization patterns:

- **Explorers** — analysis, tracing, read-only tools
- **Architects** — design, blueprints, planning
- **Reviewers** — quality, compliance, validation

## Command File Format

```yaml
---
description: Brief description
argument-hint: Optional argument documentation
allowed-tools: ["Read", "Write", "Grep", "Bash", "Skill", "Task"]
---

# Command Title

[Multi-phase workflow with numbered steps per phase]

Initial request: $ARGUMENTS
```

- Multi-phase workflows (typically 5–7 phases)
- Each phase has numbered, actionable steps
- Use Task/Todo tools to track progress
- `$ARGUMENTS` placeholder for user input
- Load skills via: `Skill: "plugin-name:skill-name"`

## Hook Configuration

Hooks are defined in `hooks.json` inside `.claude-plugin/`.

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume|clear|compact",
        "hooks": [
          {
            "type": "command",
            "command": "'${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd' session-start",
            "async": false
          }
        ]
      }
    ]
  }
}
```

| Event          | When it fires                   |
| -------------- | ------------------------------- |
| `SessionStart` | Session begins, resumes, clears |
| `PreToolUse`   | Before a tool call executes     |
| `PostToolUse`  | After a tool call completes     |
| `Stop`         | Agent is about to stop          |

- Use `matcher` patterns for conditional execution
- `${CLAUDE_PLUGIN_ROOT}` resolves to the plugin's root directory
- Set `async: true` for non-blocking hooks

## Cross-Platform Compatibility

SKILL.md is the **universal format** — write once, works on 14+ AI coding tools. Platform-specific components (hooks, agents, commands) are Claude Code features that also work in Cursor.

When writing skills:

- Stick to SKILL.md as the primary format for maximum portability
- Use platform-specific features (hooks, agents, commands) only when needed
- Keep `.claude-plugin/` as the only manifest directory (avoid per-platform adapter clutter)
