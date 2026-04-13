# Health -- Init Mode

Triggered by `/health init`, or auto-detected when the project has no `wiki/` directory.

## 1. Structural Discovery

Before generating MAP.md, determine how deep the project goes.

**Depth probe:** Run `find . -type f \( -name "*.ts" -o -name "*.rs" -o -name "*.kt" -o -name "*.go" -o -name "*.py" -o -name "*.java" -o -name "*.swift" \) | head -20` (adapt extensions to the project) and check the longest path depth. Also check for multiple build systems (package.json + Cargo.toml + build.gradle + go.mod + pyproject.toml = umbrella).

- **Shallow project** (max source depth <= 4 levels, single build system): inline discovery with `tree`/`ls` is sufficient. Proceed to step 2.
- **Deep project** (max source depth > 4 levels OR multiple build systems): dispatch `Agent(subagent_type: "general-purpose")` per major sub-project (needs Bash for `find`, not just grep/glob). Each explorer:
  - Uses `find` at depth 6+ to trace actual source paths
  - Reports leaf directories per module (not assumed from convention -- verified)
  - Identifies boilerplate path patterns (the fixed scaffold between module root and source code)
  - Notes README locations and entry points

Explorer findings feed directly into MAP.md generation.

## 2. Generate MAP.md

Use structural discovery results (inline or from explorers). Write `wiki/MAP.md` following format rules in `map-generation.md`:

- Tree structure with annotations, not markdown formatting
- Collapsed platform notation (document boilerplate path pattern once at top)
- **Boilerplate path formulas** for deep frameworks (see `map-generation.md` "Deep Platform Conventions")
- `[README]` markers on directories that have a README
- Comments only when not self-explanatory
- Deep modules philosophy -- show logical structure, not every file
- **Source-reachable rule:** an agent reading MAP.md alone must be able to construct the full path to any source file

## 3. Scaffold wiki/

Create directories:

- `wiki/sketches/`
- `wiki/blueprints/`
- `wiki/retros/`
- `wiki/reviews/`
- `wiki/diagnoses/`
- `wiki/reports/`
- `wiki/research/`
- `wiki/evolve/`
- `wiki/extensions/`

Optional: if the project will accumulate project-specific search patterns (domain exclusions, custom frontmatter fields, recurring query recipes), create `wiki/NAVIGATION.md`. The framework defaults in `skills/navigate/references/navigation-guide.md` cover most cases -- only create a project file if you need overrides.

## 4. Check CLAUDE.md

Run the CLAUDE.md completeness check (see `../SKILL.md` diagnose mode step 2). If missing required sections, offer to add them using `claude-md-template.md`. Walk the user through each missing section with recommended content based on codebase analysis (`package.json`, `Makefile`, `pyproject.toml`, etc.).

## 5. Deep Module READMEs

After scaffolding, identify deep modules that lack READMEs:

- 5+ source files, or 3+ subdirectories, or contains entry points
- Skip self-explanatory leaf directories (`di/`, `dto/`, `model/`)

For qualifying modules: generate starter READMEs with one-line purpose, key files, dependencies, and entry point. Present the list to the user for approval before generating -- not every module needs one.

## 6. Report

Print what was created and what still needs user input. Transition to diagnose mode to validate the setup.
