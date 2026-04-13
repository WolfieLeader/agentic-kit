---
name: health
description: >
  Use when: user wants a quick diagnostic of project knowledge health, to onboard
  a new project into the framework, or before starting a task on a project that
  hasn't been worked on recently. Checks .docs/ for stale research, orphan
  artifacts, MAP.md drift, deep module READMEs, and CLAUDE.md completeness.
  Can initialize a project. No retros required.
type: user-invokable
---

# Health

Two modes: **diagnose** (default) and **init** (onboarding).

## Context

Receives:
- User request (optional: "init" for onboarding, specific check to run, or default = full diagnostic)

Reads:
- `.docs/` directory tree
- CLAUDE.md
- MAP.md
- `.docs/research/*.md` frontmatter
- `.docs/retros/*.md` frontmatter
- `.docs/reviews/*.md` frontmatter
- `.docs/diagnoses/*.md` frontmatter
- `.docs/extensions/*.md`
- Project directory structure (for README and MAP.md checks)

## Mode: Init (onboarding)

Trigger: `/health init`, or auto-detected when `.docs/` directory does not exist.

### 1. Structural Discovery

Before generating MAP.md, determine how deep the project goes.

**Depth probe:** Run `find . -type f \( -name "*.ts" -o -name "*.rs" -o -name "*.kt" -o -name "*.go" -o -name "*.py" -o -name "*.java" -o -name "*.swift" \) | head -20` (adapt extensions to the project) and check the longest path depth. Also check for multiple build systems (package.json + Cargo.toml + build.gradle + go.mod + pyproject.toml = umbrella).

- **Shallow project** (max source depth ≤ 4 levels, single build system): inline
  discovery with `tree`/`ls` is sufficient. Proceed to step 2.
- **Deep project** (max source depth > 4 levels OR multiple build systems):
  dispatch `Agent(subagent_type: "general-purpose")` per major sub-project
  (needs Bash for `find`, not just grep/glob). Each explorer:
  - Uses `find` at depth 6+ to trace actual source paths
  - Reports leaf directories per module (not assumed from convention — verified)
  - Identifies boilerplate path patterns (the fixed scaffold between module root and source code)
  - Notes README locations and entry points

Explorer findings feed directly into MAP.md generation.

### 2. Generate MAP.md

Use structural discovery results (inline or from explorers). Write
`.docs/MAP.md` following format rules in `references/map-generation.md`:
- Tree structure with annotations, not markdown formatting
- Collapsed platform notation (document boilerplate path pattern once at top)
- **Boilerplate path formulas** for deep frameworks (see map-generation.md "Deep Platform Conventions")
- `[README]` markers on directories that have a README
- Comments only when not self-explanatory
- Deep modules philosophy — show logical structure, not every file
- **Source-reachable rule:** an agent reading MAP.md alone must be able to
  construct the full path to any source file

### 3. Scaffold .docs/

Create directories:
- `.docs/sketches/`
- `.docs/blueprints/`
- `.docs/retros/`
- `.docs/reviews/`
- `.docs/diagnoses/`
- `.docs/reports/`
- `.docs/research/`
- `.docs/evolve/`
- `.docs/extensions/`

### 4. Check CLAUDE.md

Run the CLAUDE.md completeness check (see diagnostic step 2). If missing
required sections, offer to add them using `references/claude-md-template.md`.
Walk the user through each missing section with recommended content based on
codebase analysis (package.json, Makefile, pyproject.toml, etc.).

### 5. Deep Module READMEs

After scaffolding, identify deep modules that lack READMEs:
- 5+ source files, or 3+ subdirectories, or contains entry points
- Skip self-explanatory leaf directories (di/, dto/, model/)

For qualifying modules: generate starter READMEs with one-line purpose, key
files, dependencies, and entry point. Present the list to the user for
approval before generating — not every module needs one.

### 6. Report

Print what was created and what still needs user input. Transition to diagnostic
mode to validate the setup.

---

## Mode: Diagnose (default)

Run all checks. Report findings grouped by severity. If `.docs/` doesn't exist,
suggest running `/health init` instead.

### 1. Structure check

Verify `.docs/` exists with expected subdirectories (sketches, blueprints, retros,
reviews, diagnoses, reports, research, evolve, extensions, MAP.md, CHANGELOG.md).
Missing = INFO (not everything is needed from day one).

### 2. CLAUDE.md completeness

Check project's CLAUDE.md for required sections:

**Must have:**
1. Tech Stack — language, framework, database, test runner, package manager
2. Commands — test, lint, typecheck, format, build, dev (exact commands)
3. Verification Suite — ordered list of checks to run before completion claims
4. Hard Gates — the 7 framework hard gates
5. Workflow Artifacts — `.docs/` location and conventions

**Should have:**
6. Available CLI Tools — rtk, tree, gh, etc.
7. Conventions — error handling, naming, imports, state management

Detection: grep CLAUDE.md for "Tech Stack", "Commands", "Verification",
"Hard Gates", "Workflow Artifacts". Missing = WARN.

### 3. Research staleness

Grep `.docs/research/*.md` frontmatter for `date_updated:`.

- **Stale**: `date_updated` older than 90 days — flag for review
- **Undated**: missing `date_updated` — flag for addition
- **Orphaned**: `module:` and `tags:` don't match any retro or sketch frontmatter — candidate for archival

### 4. Artifact integrity

Scan `.docs/` artifact directories:
- **Orphan sketch**: `.docs/sketches/<slug>.md` exists with `status: draft` but no corresponding blueprint — abandoned mid-pipeline
- **Missing retro**: `.docs/blueprints/<slug>.md` exists but no `.docs/retros/<slug>.md` — incomplete task
- **Stale draft**: `status: draft` in frontmatter older than 14 days — forgotten WIP
- **Unlinked diagnosis**: `.docs/diagnoses/<slug>.md` with `routed_to: sketch` but no matching sketch — dropped after diagnosis

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

If `.docs/extensions/` exists:
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

Write to `.docs/reports/YYMMDD-health.md` using `references/report-template.md`.

## References

- `references/claude-md-template.md` — CLAUDE.md scaffold template for init mode
- `references/map-generation.md` — MAP.md generation rules, format, and maintenance
- `references/report-template.md` — Health report output format

## Gotchas

- Diagnose mode does NOT create `.docs/` directories. Report absence, let user decide or run `/health init`.
- Init mode DOES create directories — that's its job. But it still asks before modifying CLAUDE.md.
- MAP.md drift detection is heuristic — new directories may be intentionally unmapped.
- Research contradiction detection is agent judgment. Conflicting claims on different aspects of the same topic are normal.
- Deep module detection uses heuristics (file count, subdirectories, entry points). Not every flagged module needs a README — user decides.
- Health reports accumulate (one per run). Use git or date prefix to find latest.
- Shallow discovery = shallow MAP.md. Use `find` at depth 6+ for deep frameworks. A 2-level `ls` misses source code buried in deep scaffolds (KMP, Rust workspaces, Expo monorepos, Go internal packages, etc.).
- Leaf directories come from `find`, not convention. Different modules in the same framework have different leaf dirs. Verify per module.
