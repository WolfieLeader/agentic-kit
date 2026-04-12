# Routing Guide

Reference for classification, pipeline routing, and onboarding.

## Type Signals

| Type    | Signal words                                                              |
|---------|---------------------------------------------------------------------------|
| BUILD   | "add", "create", "build", "implement", "new", "feature", "refactor", "migrate" |
| FIX     | "fix", "bug", "broken", "error", "failing", "crash", "regression", "flaky"     |
| EXPLORE | "why", "how does", "what would it take", "audit", "compare", "investigate", "research" |

When ambiguous, lean toward more investigation: FIX over BUILD, EXPLORE over FIX.

## Tier Signals

| Tier        | Indicators                                                     |
|-------------|----------------------------------------------------------------|
| Lightweight | Single file/function, low ambiguity, clear scope, one concern  |
| Standard    | Multi-file, some decisions needed, 2-3 systems                 |
| Deep        | Multi-subsystem, high ambiguity, architectural decisions       |

**Lightweight is the exception.** If in doubt, classify standard. Tasks
touching 2+ files or 2+ concerns are standard by default.

## Pipeline Routes

```
light BUILD:    craft -> verify -> retro
light FIX:      trace -> craft -> verify -> retro
std/deep BUILD: sketch -> blueprint -> craft -> verify -> retro
std/deep FIX:   trace -> sketch -> blueprint -> craft -> verify -> retro
EXPLORE:        synthesize -> persist research -> done | transition
```

## Slug Format

`YYMMDD-kebab-case` -- date of creation + descriptive kebab-case name.

Examples: `260412-notifications`, `260412-auth-token-refresh`

Duplicate slug detection triggers resume flow.

## Resume Flow

1. Grep `.docs/work/` YAML frontmatter for matching module, tags, or title.
2. If match found, read existing artifacts (sketch, blueprint, etc.).
3. Present: "I found existing work for [slug] -- here's what's done:
   [summary of completed phases]. Continue from here or start fresh?"
4. "Continue" resumes at the next incomplete phase. "Start fresh" creates new slug.

## .docs/ Artifact Ecosystem

The `.docs/` directory is a knowledge graph traversable via YAML frontmatter grep.
Every artifact has frontmatter with `module:`, `tags:`, and type-specific fields.
Grep is traversal. Frontmatter fields are edges. Modules are clusters.

| Path | What it is | Key frontmatter | Who writes | Who reads |
|---|---|---|---|---|
| `.docs/work/<slug>/sketch.md` | What/why capture (std/deep) | `module`, `tags`, `type`, `tier`, `affected_systems` | sketch | blueprint (orchestrator + reviewer defense), verify, retro |
| `.docs/work/<slug>/blueprint.md` | How — implementation units | `source_sketch`, `tier`, `unit_count`, `overall_confidence` | blueprint | craft, verify |
| `.docs/work/<slug>/retro.md` | Reflection + learnings | `module`, `tags`, `token_effort`, `outcome`, `root_cause` (FIX) | retro | propose (pattern detection) |
| `.docs/research/<topic>.md` | Living knowledge from external research | `module`, `tags`, `date_updated` | docs-explorer, EXPLORE | sketch, propose (linting) |
| `.docs/extend/<phase>.md` | Extension config per phase | `phase`, `date_updated` | /extend | phase skills (craft, verify, trace, router) |
| `.docs/evolve/NNN-proposals.md` | Change proposals from retro patterns | `retros_analyzed`, `status` | /propose | /evolve |
| `.docs/evolve/NNN-evolve.md` | Execution log of applied changes | `source_proposals`, `changes_made` | /evolve | — |
| `.docs/CHANGELOG.md` | Append-only evolve history | — | /evolve | — |
| `.docs/MAP.md` | Project navigation (codebase, not .docs/) | — | router (generates), retro (maintains) | router (self-look) |

**Grep patterns for traversal:**
```bash
# All retros about a module
grep -r "module: auth" .docs/work/*/retro.md

# All work touching a tag
grep -r "tags:.*queue" .docs/work/

# Resume candidates
grep -r "status: draft\|status: complete" .docs/work/*/sketch.md

# Stale research (by date)
grep -r "date_updated:" .docs/research/

# Cross-module retros
grep -r "affected_modules:.*payment" .docs/work/*/retro.md

# Token effort patterns
grep -r "token_effort: high" .docs/work/*/retro.md
```

**MAP.md and READMEs:** MAP.md maps the *project codebase*, not `.docs/`. `[README]` markers indicate deep modules with summary documentation — agents should read the README before diving into individual files. This gives cheap orientation without reading every source file.

## MAP.md Generation (First Run)

When MAP.md doesn't exist, generate as a one-time onboarding step.

**Discovery:** use `rtk tree` / `tree` / `ls` -- whichever is available.

**Format rules:**
- Tree structure with annotations.
- Collapsed platform notation: document boilerplate path patterns once at top
  rather than repeating. E.g., "Each package follows `src/index.ts, src/types.ts, __tests__/`."
- `[README]` markers on directories containing a README.
- Comments only when the name is not self-explanatory.
- Show logical structure (key directories, entry points), not every file.

**Example fragment:**

```
# Boilerplate: each package has src/index.ts, src/types.ts, __tests__/

packages/
  auth/           # JWT + session management [README]
  api/            # Express routes, middleware
    routes/
    middleware/
  shared/         # Cross-package types and utils
    errors.ts
    logger.ts
```
