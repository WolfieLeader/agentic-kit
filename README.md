# agentic-kit

A Claude Code plugin that makes every task improve the next one. Structured workflows with right-sized ceremony — lightweight for small changes, full pipeline for complex work — and a feedback loop that compounds project knowledge over time.

**Claude Code only. By design.** Depth over breadth.

## The Problem

AI coding assistants forget everything between sessions. They repeat the same mistakes, miss the same edge cases, and can't learn from what went wrong last time.

## How agentic-kit Solves It

Every task produces data points — retros, diagnoses, reviews, health reports. `/propose` mines all data points for recurring patterns. `/evolve` turns patterns into tighter instructions, better skills, and sharper guardrails. The framework improves itself.

```
task → data points → propose → evolve → better next task
```

## Quickstart

```bash
# Install the plugin
claude plugin add WolfieLeader/agentic-kit
```

Then in any project:

```
/yo add user authentication with JWT
```

The router classifies your task, scales ceremony to scope, and runs the right pipeline:

- **BUILD (lightweight)**: craft → verify → retro
- **BUILD (std/deep)**: sketch → blueprint → craft → verify → retro
- **FIX**: diagnose → craft → verify → retro (light) or diagnose → sketch → blueprint → craft → verify → retro (std/deep)
- **EXPLORE**: synthesize → persist research → done
- **REVIEW**: explore → code-review → persist review → done

## Skills

**User-facing:**

| Skill         | Purpose                                                                           |
| ------------- | --------------------------------------------------------------------------------- |
| `/yo`         | Universal entry point. Routes to BUILD, FIX, EXPLORE, or REVIEW.                  |
| `/health`     | Project diagnostic and onboarding. Checks wiki/ health, initializes new projects. |
| `/extensions` | Add project-specific agents or skills to pipeline phases.                         |
| `/propose`    | Mine all data points for patterns, draft change proposals.                        |
| `/evolve`     | Execute accepted proposals. The framework improves.                               |

**Pipeline phases** (invoked by `/yo`, not directly): `diagnose` → `sketch` → `blueprint` → `craft` → `verify` → `retro`

## Agents

| Agent                | Model  | Role                                                   |
| -------------------- | ------ | ------------------------------------------------------ |
| `code-explorer`      | Sonnet | Scans source code, patterns, dependencies, git history |
| `docs-explorer`      | Sonnet | Searches prior work, research docs, external sources   |
| `blueprint-reviewer` | Sonnet | Validates blueprints for coherence, feasibility, scope |
| `code-reviewer`      | Opus   | 3-pass review: correctness, testing, maintainability   |

## Key Design Decisions

- **Knowledge graph via filesystem** — All artifacts use YAML frontmatter for grep-first retrieval. `module:` and `tags:` are edges, `grep` is traversal. Inspired by Karpathy's LLM Wiki: persistent compilation over runtime retrieval.
- **4-handoff boundary** — Research shows >4 agent handoffs degrade quality. The pipeline has 6 phases but only 4 disk-based artifact handoffs per BUILD.
- **TDD by default** — RED-GREEN-REFACTOR with exception protocol for non-testable changes. 4-fix circuit breaker stops runaway debugging.
- **Extension system with caps** — Projects add domain-specific agents/skills via `/extensions`. Phase caps prevent token bloat.
- **Lint as first-class operation** — `/health` is the wiki's lint: finds contradictions, stale claims, orphans, missing cross-references.

## Project Structure

```
skills/              — 11 skills (5 user-facing, 6 pipeline phases)
agents/              — 4 agents (2 explorers, 1 blueprint reviewer, 1 code reviewer)
hooks/               — PostToolUse hooks (placeholder enforcement)
docs/                — Framework design documentation
.claude-plugin/      — Plugin manifest
```

**Per-project artifacts** (created by the framework at runtime):

```
wiki/
  sketches/          — What/why captures (std/deep builds)
  blueprints/        — How — implementation units
  retros/            — Reflections and learnings (data point)
  reviews/           — Code review findings (data point)
  diagnoses/         — Bug investigations (data point)
  reports/           — Health check snapshots (data point)
  research/          — External knowledge docs
  evolve/            — Proposals and change logs
  extensions/        — Phase extension configs
  MAP.md             — Project navigation index
  CHANGELOG.md       — Evolve history
```

## Design Documentation

See [docs/WHITEPAPER.md](docs/WHITEPAPER.md) for the full architectural spec, resolved decisions, and research backing.

## License

MIT
