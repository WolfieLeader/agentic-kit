---
name: health
description: >
  Project knowledge health diagnostic. Invoke ONLY when the user explicitly
  types /health, or explicitly requests "check health" / "onboard project" /
  "run diagnostic". Do NOT auto-invoke just because a project looks stale or
  missing artifacts -- the user must opt in. Checks wiki/ for stale research,
  orphan artifacts, MAP.md drift, deep module READMEs, and CLAUDE.md
  completeness. Can initialize a new project. No retros required.
type: user-invocable
---

# Health

Two modes: **diagnose** (default) and **init** (onboarding).

## Context

Receives:

- User request (optional: "init" for onboarding, specific check to run, or default = full diagnostic)

Reads:

- `wiki/` directory tree
- CLAUDE.md
- MAP.md
- `wiki/research/*.md` frontmatter
- `wiki/retros/*.md` frontmatter
- `wiki/reviews/*.md` frontmatter
- `wiki/diagnoses/*.md` frontmatter
- `wiki/extensions/*.md`
- Project directory structure (for README and MAP.md checks)

## Mode: Init (onboarding)

Trigger: `/health init`, or auto-detected when `wiki/` directory does not exist.

Full procedure in `references/init-mode.md`: structural discovery (depth probe, umbrella detection), MAP.md generation, `wiki/` scaffold (including optional `wiki/NAVIGATION.md`), CLAUDE.md completeness check, deep-module README coverage, report. After init completes, transition to diagnose mode to validate.

---

## Mode: Diagnose (default)

Run all checks. Report findings grouped by severity. If `wiki/` doesn't exist,
suggest running `/health init` instead.

### 1. Structure check

Verify `wiki/` exists with expected subdirectories (sketches, blueprints, retros,
reviews, diagnoses, reports, research, evolve, extensions, MAP.md, CHANGELOG.md).
Missing = INFO (not everything is needed from day one).

### 2. CLAUDE.md completeness

Check project's CLAUDE.md for required sections:

**Must have:**

1. Tech Stack — language, framework, database, test runner, package manager
2. Commands — test, lint, typecheck, format, build, dev (exact commands)
3. Verification Suite — ordered list of checks to run before completion claims
4. Hard Gates — the 7 framework hard gates
5. Workflow Artifacts — `wiki/` location and conventions

**Should have:** 6. Available CLI Tools — rtk, tree, gh, etc. 7. Conventions — error handling, naming, imports, state management

Detection: grep CLAUDE.md for "Tech Stack", "Commands", "Verification",
"Hard Gates", "Workflow Artifacts". Missing = WARN.

### 3. Research staleness

Grep `wiki/research/*.md` frontmatter for `date_updated:`.

- **Stale**: `date_updated` older than 90 days — flag for review
- **Undated**: missing `date_updated` — flag for addition
- **Orphaned**: `module:` and `tags:` don't match any retro or sketch frontmatter — candidate for archival

### 4. Artifact integrity

Scan `wiki/` artifact directories:

- **Orphan sketch**: `wiki/sketches/<slug>.md` exists with `status: draft` but no corresponding blueprint — abandoned mid-pipeline
- **Missing retro**: `wiki/blueprints/<slug>.md` exists but no `wiki/retros/<slug>.md` — incomplete task
- **Stale draft**: `status: draft` in frontmatter older than 14 days — forgotten WIP
- **Unlinked diagnosis**: `wiki/diagnoses/<slug>.md` with `routed_to: sketch` but no matching sketch — dropped after diagnosis

### 5. MAP.md integrity

If MAP.md exists:

**Drift detection:**

- Compare directories listed in MAP.md against actual project structure
- Flag directories that exist in the project but not in MAP.md (new, unmapped)
- Flag directories listed in MAP.md that no longer exist (stale entries)

**README marker accuracy:**

- Scan MAP.md for `[README]` markers
- For each marked directory: verify a README file actually exists — stale marker = WARN
- For each unmarked directory that HAS a README: flag as missing marker = INFO

### 6. Deep module README coverage

Identify deep modules — directories with high complexity signals:

- 5+ source files
- 3+ subdirectories
- Contains public interfaces or entry points (index.ts, main.py, mod.rs, etc.)

For each deep module without a README: flag as WARN. Deep modules are where
agents waste the most tokens exploring — a README gives cheap orientation.

### 7. Extension health

If `wiki/extensions/` exists:

- Verify referenced agents/skills exist in `.claude/agents/`, `~/.claude/agents/`, `.claude/skills/`, or `~/.claude/skills/`
- Check extension caps against current count
- If retros exist, flag extensions with zero findings across 3+ retros — candidates for removal

### 8. Research contradictions

If 2+ research docs exist with overlapping `module:` or `tags:`:

**Detection heuristics** (check in order):

1. **Version conflicts** — docs recommend different versions of the same dependency
2. **API shape conflicts** — docs describe different signatures, endpoints, or schemas for the same interface
3. **Architecture conflicts** — docs describe different ownership, data flow, or responsibility boundaries for the same module
4. **Staleness-driven conflicts** — one doc's `date_updated` is 60+ days older than the other on the same topic

For each detected conflict: flag as WARN with both doc paths, the conflicting
claims, and which doc is newer. Do not resolve — present to user for judgment.

### 9. Discoverability audit

Check whether key project knowledge is surfaced where agents will find it.

- **CLAUDE.md coverage**: compare modules listed in MAP.md against CLAUDE.md mentions. Modules with 3+ retros but no CLAUDE.md mention = WARN (undiscoverable conventions).
- **Retro pattern surfacing**: grep recent retros for recurring `root_cause:` categories. If a root cause appears 3+ times but CLAUDE.md has no convention addressing it = WARN (unsurfaced learning).
- **MAP.md README gaps**: modules with high retro/review activity but no README = WARN (agents waste tokens exploring without orientation).

## Output

Write to `wiki/reports/YYMMDD-health.md` using `references/report-template.md`.

## References

- `references/init-mode.md` — full init-mode procedure (structural discovery, MAP.md, scaffold, READMEs)
- `references/claude-md-template.md` — CLAUDE.md scaffold template for init mode
- `references/map-generation.md` — MAP.md generation rules, format, and maintenance
- `references/report-template.md` — Health report output format

## Gotchas

- Diagnose mode does NOT create `wiki/` directories. Report absence, let user decide or run `/health init`.
- Init mode DOES create directories — that's its job. But it still asks before modifying CLAUDE.md.
- MAP.md drift detection is heuristic — new directories may be intentionally unmapped.
- Research contradiction detection is agent judgment. Conflicting claims on different aspects of the same topic are normal.
- Deep module detection uses heuristics (file count, subdirectories, entry points). Not every flagged module needs a README — user decides.
- Health reports accumulate (one per run). Use git or date prefix to find latest.
- Shallow discovery = shallow MAP.md. Use `find` at depth 6+ for deep frameworks. A 2-level `ls` misses source code buried in deep scaffolds (KMP, Rust workspaces, Expo monorepos, Go internal packages, etc.).
- Leaf directories come from `find`, not convention. Different modules in the same framework have different leaf dirs. Verify per module.
