# Routing Guide

Reference for classification, pipeline routing, and onboarding.

## Type Signals

| Type    | Signal words                                                              |
|---------|---------------------------------------------------------------------------|
| BUILD   | "add", "create", "build", "implement", "new", "feature", "refactor", "migrate" |
| FIX     | "fix", "bug", "broken", "error", "failing", "crash", "regression", "flaky"     |
| EXPLORE | "why", "how does", "what would it take", "audit", "compare", "investigate", "understand", "research" |

When ambiguous, lean toward more investigation: FIX over BUILD, EXPLORE over FIX.

## Tier Signals

| Tier        | Indicators                                                     |
|-------------|----------------------------------------------------------------|
| Lightweight | Single file/function, low ambiguity, clear scope, one concern  |
| Standard    | Multi-file, some decisions needed, 2-3 systems                 |
| Deep        | Multi-subsystem, high ambiguity, architectural decisions, unknown scope |

**Lightweight is the exception.** If in doubt, classify standard. Tasks
touching 2+ files or 2+ concerns are standard by default.

## Pipeline Routes

```
light BUILD:    craft → verify → retro
light FIX:      trace → craft → verify → retro
std/deep BUILD: sketch → blueprint → craft → verify → retro
std/deep FIX:   trace → sketch → blueprint → craft → verify → retro
EXPLORE:        synthesize → persist research → done | transition
```

## EXPLORE Transitions

EXPLORE may transition to BUILD or FIX after synthesis:

| User says             | Action                                          |
|-----------------------|-------------------------------------------------|
| "Let's build it"      | Reclassify as BUILD. Reuse explorer findings + research. |
| "Fix what we found"   | Reclassify as FIX. Reuse context.               |
| "Just needed to know" | Done. No further pipeline.                      |

No re-exploration on transition. Explorer findings and research context
carry forward.

## Slug Format

`YYMMDD-kebab-case` — date of creation + descriptive kebab-case name.

Examples: `260411-notifications`, `260412-auth-token-refresh`

Duplicate slug detection triggers resume flow (see below).

## Resume Flow

1. Grep `.docs/work/` YAML frontmatter for matching module, tags, or title.
2. If match found, read the existing artifacts (sketch, blueprint, etc.).
3. Present to user: "I found existing work for [slug] — here's what's done:
   [summary of completed phases and current status]. Continue from here or
   start fresh?"
4. User decides. "Continue" resumes at the next incomplete phase. "Start fresh"
   creates a new slug.

## MAP.md Generation (First Run)

When MAP.md doesn't exist, generate it as a one-time onboarding step.

**Discovery:** use `rtk tree` / `tree` / `ls` — whichever is available.

**Format rules:**
- Tree structure with annotations.
- Collapsed platform notation: document boilerplate path patterns once at the
  top rather than repeating them. E.g., "Each package follows
  `src/index.ts, src/types.ts, __tests__/` convention."
- `[README]` markers on directories that contain a README.
- Comments only when the name is not self-explanatory.
- Deep modules: show logical structure (key directories, entry points),
  not every file. The map should fit in one screen for most projects.

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
