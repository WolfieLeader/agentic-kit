# Changelog

Framework-level changes. Project-level evolve changes go in `.docs/CHANGELOG.md`.

## 2026-04-13 — v0.3.0

### Added
- REVIEW router type — code review as a 4th pipeline (`explore → code-review → persist review → done | transition`). Composes existing explorers + code-reviewer agent. Produces `.docs/reviews/<slug>.md`.
- Diagnose artifact — `/diagnose` now persists findings to `.docs/diagnoses/<slug>.md` with YAML frontmatter (classification, severity, hypothesis, confidence). Previously session-only.
- `diagnose/references/diagnose-template.md` — frontmatter schema and section template for diagnosis artifacts
- Health reports as data points — `/health` writes to `.docs/reports/YYMMDD-health.md` (accumulates, not overwritten)
- Artifact ecosystem table in yo/SKILL.md — full `.docs/` knowledge graph reference with grep patterns
- REVIEW → FIX transition — "found a bug during review, let's fix it"

### Changed
- `/start` → `/yo` — conversational entry point. "yo fix the login bug" > "start fix the login bug"
- `/trace` → `/diagnose` — covers full scope: reproduce, classify, hypothesize, assess severity, route
- `/extend` → `/extensions` — noun form matches directory contents, consistent with other dirs
- `.docs/work/<slug>/` → separated artifact directories — sketches/, blueprints/, retros/, reviews/, diagnoses/, reports/ (Karpathy: organize by what you'll search for)
- `.docs/extend/` → `.docs/extensions/` — matches skill rename
- `.docs/health-report.md` → `.docs/reports/YYMMDD-health.md` — health reports accumulate as data points
- Slug format: `YYMMDD-kebab-case` → `YYMMDD-NNN-kebab-topic` (NNN resets daily at 001)
- Evolve files: `NNN-proposals.md` → `<slug>-proposals.md` / `<slug>-evolve.md`
- `/propose` — mines ALL data-point directories (retros, reviews, diagnoses, reports), not just retros. Health diagnostics read from reports instead of re-running.
- `hooks/scripts/no-placeholders.sh` — checks all `.docs/` artifact dirs, not just `.docs/work/`
- `CLAUDE.md` — updated artifact description and slug convention
- `plugin.json` — v0.3.0, updated description for 4 workflows

### Removed
- `routing-guide.md` — 60% duplicated yo/SKILL.md. Unique content (artifact ecosystem table + grep patterns) merged into yo/SKILL.md
- `claude-md-checklist.md` — thin wrapper. Checklist inlined into health/SKILL.md step 2
- Duplicate red flags in craft/SKILL.md — 12 rationalization flags now single-sourced in tdd-guardrails.md
- `/propose` steps 6-8 (extension health, research lint, token patterns) — duplicated `/health` diagnostics

### Fixed
- Stale "Generates: MAP.md on first run if missing" in yo Context section — removed (delegated to /health init)
- All `.docs/work/<slug>/` path references updated across 10 skills and 4 templates
- All `.docs/extend/` references updated to `.docs/extensions/`
- All "trace" references updated to "diagnose" across skills

## 2026-04-13 — v0.2.0

### Added
- `/health` skill — project diagnostic and onboarding (Karpathy-inspired lint operation). Two modes: `init` (scaffolds `.docs/`, generates MAP.md, checks CLAUDE.md completeness with template) and `diagnose` (8 checks: structure, CLAUDE.md completeness, research staleness, work folder integrity, MAP.md drift + README marker accuracy, deep module README coverage, extension health, research contradictions). Writes `.docs/health-report.md` so findings feed `/propose`.
- `hooks/hooks.json` — PostToolUse hook enforcing placeholder ban in `.docs/` artifacts (deterministic enforcement of hard gate)
- `hooks/scripts/no-placeholders.sh` — hook script for placeholder detection
- `CHANGELOG.md` — framework evolution tracking (this file)
- Anti-rationalization red flags to sketch (6), blueprint (6), and verify (6) skills — phase-specific rationalizations the model uses to skip steps
- "Use when:" trigger patterns in all skill descriptions — helps Claude select the right skill

### Changed
- `CLAUDE.md` — upgraded from 2 lines to full hard gates and framework conventions
- `README.md` — rewritten to lead with problem/solution, added quickstart, fixed agent table to match actual files
- `WHITEPAPER.md` → `docs/WHITEPAPER.md` — design documentation moved out of root; skills and agents are the product
- `RESEARCH.md` → `docs/RESEARCH.md` — reference research moved alongside design docs
- `/start` — onboarding (MAP.md generation, `.docs/` scaffolding) delegated to `/health init`. Router now invokes `/health init` when `.docs/` is missing instead of doing inline generation. CLAUDE.md template moved to `/health/references/`.
- `/propose` — now reads `.docs/health-report.md` as input when it exists, connecting health diagnostics to the proposal cycle
- `routing-guide.md` — MAP.md generation section replaced with pointer to `/health init`

### Fixed
- README agent table listed `correctness-reviewer`, `testing-reviewer`, `maintainability-reviewer` as separate agents — these are passes within the single `code-reviewer` agent
