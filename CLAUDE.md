- Be extremely concise.
- You may read and write gitignored files in this project.

## Tech Stack

- **Type:** Claude Code plugin (skills + agents in Markdown)
- **Structure:** `skills/` (SKILL.md per skill), `agents/` (one .md per agent), `docs/` (design docs)
- **Artifacts at runtime:** `wiki/` (sketches, blueprints, retros, reviews, diagnoses, reports, research, evolve, extensions, MAP.md)

## Conventions

- YAML frontmatter on all `wiki/` artifacts for grep-first retrieval
- Skill files: < 200 lines in SKILL.md, overflow to `references/`
- Agent files: < 120 lines, one-line voice reference ("Follows framework voice conventions")
- Slugs: `YYMMDD-NNN-kebab-topic` (NNN resets daily at 001)
- No placeholders in artifacts: hard ban on TBD, TODO, FIXME, HACK, XXX

## Hard Gates

1. **DESIGN-THEN-CODE** — sketch (std/deep) or router classification (light) before implementation
2. **OPTIONS-THEN-RECOMMEND** — present ALL approaches before recommending (anti-anchoring)
3. **ARTIFACT-BEFORE-HANDOFF** — persist artifact to disk before transitioning to next phase
4. **EXPLORE-BEFORE-IMPLEMENT** — router self-look always; explorer dispatch for std/deep
5. **EVIDENCE-BEFORE-CLAIMS** — run verification, read output, then claim result
6. **INVESTIGATE-THEN-FIX** — reproduce, hypothesize, confirm root cause, then fix
7. **TEST-THEN-CODE** — write failing test first, then implementation (exception protocol for non-testable changes: state why, specify alt verification, retro tags exception)
