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

### 1. Generate MAP.md

Scan the project structure (`tree` or `ls`, whichever is available). Write
`.docs/MAP.md` following format rules in `references/map-generation.md`:
- Tree structure with annotations, not markdown formatting
- Collapsed platform notation (document boilerplate path pattern once at top)
- `[README]` markers on directories that have a README
- Comments only when not self-explanatory
- Deep modules philosophy — show logical structure, not every file

### 2. Scaffold .docs/

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

### 3. Check CLAUDE.md

Run the CLAUDE.md completeness check (see diagnostic step 2). If missing
required sections, offer to add them using `references/claude-md-template.md`.
Walk the user through each missing section with recommended content based on
codebase analysis (package.json, Makefile, pyproject.toml, etc.).

### 4. Report

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
- Read both, compare claims
- Flag conflicting information between docs on the same topic

## Output

Write to `.docs/reports/YYMMDD-health.md`:

```yaml
---
date: YYYY-MM-DD
type: health
checks_run: 8
warn_count: N
info_count: N
---
```

```markdown
## Health Report — [project name] — [date]

### WARN (act on these)
- [finding]

### INFO (awareness)
- [finding]

### OK (passing)
- [check name] — passed
```

Also print the report to the user. The persisted file lets `/propose`
reference health findings when drafting proposals.

## References

- `references/claude-md-template.md` — CLAUDE.md scaffold template for init mode
- `references/map-generation.md` — MAP.md generation rules, format, and maintenance

## Gotchas

- Diagnose mode does NOT create `.docs/` directories. Report absence, let user decide or run `/health init`.
- Init mode DOES create directories — that's its job. But it still asks before modifying CLAUDE.md.
- MAP.md drift detection is heuristic — new directories may be intentionally unmapped.
- Research contradiction detection is agent judgment. Conflicting claims on different aspects of the same topic are normal.
- Deep module detection uses heuristics (file count, subdirectories, entry points). Not every flagged module needs a README — user decides.
- Health reports accumulate (one per run). Use git or date prefix to find latest.
