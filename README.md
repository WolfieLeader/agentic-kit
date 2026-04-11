# agentic-kit

A Claude Code plugin for AI-driven development. One entry point, three workflows, knowledge that compounds over time.

## Install

```bash
claude plugin add /path/to/agentic-kit
```

Or add to your project's `.claude/settings.json`:

```json
{
  "plugins": ["/path/to/agentic-kit"]
}
```

## Skills

| Skill | Purpose |
|-------|---------|
| `/start` | Universal entry point. Routes to BUILD, FIX, or EXPLORE. |
| `/extend` | Add agents/skills to framework phases. |
| `/propose` | Aggregate retros, identify patterns, draft change proposals. |
| `/evolve` | Execute accepted proposals. |

Internal skills (invoked by the pipeline, not directly): `trace`, `sketch`, `blueprint`, `craft`, `verify`, `retro`.

## Agents

| Agent | Role |
|-------|------|
| `code-explorer` | Scans source code, patterns, and git history |
| `docs-explorer` | Searches prior work, research docs, and external sources |
| `blueprint-reviewer` | Validates blueprints for coherence, feasibility, and scope |
| `correctness-reviewer` | Logic errors, edge cases, state bugs |
| `testing-reviewer` | Coverage gaps, weak assertions, brittle tests |
| `maintainability-reviewer` | Coupling, complexity, naming, dead code |

## Structure

```
.claude-plugin/            — Plugin manifest
skills/                    — Plugin skills (loaded by Claude Code)
agents/                    — Plugin agents (shared across skills)
.docs/
  FRAMEWORK.md             — Full framework spec (design + implementation reference)
  work/                    — Per-task artifacts (sketch, blueprint, retro)
  research/                — Living docs from external research
  evolve/                  — Proposals and change logs
  extend/                  — Phase extension configs
  MAP.md                   — Project navigation index
.inspiration/
  core/                    — Primary influences (Superpowers, Compound Engineering)
  other/                   — Secondary influences (CC10X, Matt Pocock, ECC)
```

## How It Works

`/start` classifies your task (BUILD, FIX, or EXPLORE) and scales ceremony to scope:

- **Lightweight** — single file/function → craft → verify → retro
- **Standard/Deep** — multi-file/subsystem → sketch → blueprint → craft → verify → retro
- **Explore** — research question → synthesize → persist if external

Every task ends with a retro. `/propose` finds patterns across retros. `/evolve` acts on them. The framework improves itself.

See [`.docs/FRAMEWORK.md`](.docs/FRAMEWORK.md) for the full spec.
