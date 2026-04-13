# CLAUDE.md Template

Template for projects using the agentic-kit framework. Fill in project specifics.
Hard gates and workflow artifacts sections stay constant.

```markdown
# [Project Name]

## Tech Stack
- **Language:** [e.g., TypeScript 5.x]
- **Framework:** [e.g., Next.js 15, Express 4]
- **Database:** [e.g., PostgreSQL 16 via Prisma]
- **Test runner:** [e.g., Vitest]
- **Package manager:** [e.g., pnpm]

## Commands
- **Test:** `[e.g., pnpm test]`
- **Test (single):** `[e.g., pnpm test -- path/to/file]`
- **Lint:** `[e.g., pnpm lint]`
- **Typecheck:** `[e.g., pnpm typecheck]`
- **Build:** `[e.g., pnpm build]`
- **Dev:** `[e.g., pnpm dev]`

## Verification Suite
Run before any completion claim, in this order:
1. `[typecheck command]` -- 0 errors
2. `[lint command]` -- must pass
3. `[test command]` -- must pass, read output, count failures
4. `[build command]` -- must succeed

## Available CLI Tools
- [e.g., `rtk` -- token-optimized CLI proxy]
- [e.g., `gh` -- GitHub CLI for PR/issue operations]

## Conventions
- [Error handling pattern]
- [Naming conventions]
- [Import conventions]

## Workflow Artifacts
- All artifacts in `.docs/` (dotdir, invisible to rg/grep by default)
- YAML frontmatter on all artifacts for grep-first retrieval
- Slugs: `YYMMDD-NNN-kebab-topic` (NNN resets daily)
- Sketches: `.docs/sketches/<slug>.md`
- Blueprints: `.docs/blueprints/<slug>.md`
- Retros: `.docs/retros/<slug>.md`
- Reviews: `.docs/reviews/<slug>.md`
- Diagnoses: `.docs/diagnoses/<slug>.md`
- Research: `.docs/research/<topic>.md`
- Health: `.docs/reports/YYMMDD-health.md`
- Extensions: `.docs/extensions/<phase>.md`
- Navigation: `.docs/MAP.md`

## Hard Gates
1. **DESIGN-THEN-CODE** -- sketch (std/deep) or classification (light) before implementation
2. **OPTIONS-THEN-RECOMMEND** -- present ALL approaches before recommending
3. **ARTIFACT-BEFORE-HANDOFF** -- persist artifact to disk before next phase
4. **EXPLORE-BEFORE-IMPLEMENT** -- self-look always; explorer dispatch for std/deep
5. **EVIDENCE-BEFORE-CLAIMS** -- run verification, read output, then claim result
6. **INVESTIGATE-THEN-FIX** -- reproduce, hypothesize, confirm root cause, then fix
7. **TEST-THEN-CODE** -- failing test first, then implementation
```
