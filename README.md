# agentic-kit

A Claude Code plugin for AI-driven development. Structured brainstorming, planning, and implementation workflows that scale from quick fixes to deep feature design.

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

| Skill | Status | Description |
|-------|--------|-------------|
| `/letsgo` | Built | Brainstorm and design — decides WHAT to build before coding |
| `/plan` | Planned | Implementation planning — decides HOW to build it |
| TDD | Planned | Test-driven development (internal skill) |

## Agents

| Agent | Description |
|-------|-------------|
| `code-explorer` | Scans source code, patterns, and git history to inform brainstorming |
| `docs-explorer` | Researches documentation, existing decisions, and external sources |
| `brainstorm-reviewer` | Reviews brainstorm artifacts for quality and handoff readiness |

## Structure

```
.claude-plugin/            — Plugin manifest
skills/                    — Plugin skills (loaded by Claude Code)
agents/                    — Plugin agents (shared across skills)
.inspiration/
  core/                    — Primary influences (Superpowers, Compound Engineering)
  other/                   — Secondary influences (CC10X, Matt Pocock, ECC)
.docs/                     — Framework design docs, engineering standards, specs
```

## Docs

- `.docs/architecture.md` — Framework design principles and structure
- `.docs/engineering-standards.md` — Rules for building skills and agents
- `.docs/skill-specs.md` — Behavioral specs for each skill
- `.docs/professors.md` — Expert review findings and fix audit trail
- `.docs/sources.md` — Source framework summaries
- `.docs/compare.md` — Side-by-side comparison of source frameworks
