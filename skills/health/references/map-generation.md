# MAP.md Generation

MAP.md maps the project codebase (not `wiki/`). Generated during `/health init`.

## Discovery

Use `rtk tree` / `tree` / `ls` — whichever is available.

## Format Rules

- Tree structure with annotations, not markdown formatting
- Collapsed platform notation: document boilerplate path patterns once at top
  rather than repeating. E.g., "Each package follows `src/index.ts, src/types.ts, __tests__/`."
- `[README]` markers on directories containing a README
- Comments only when the name is not self-explanatory
- Show logical structure (key directories, entry points), not every file
- Deep modules philosophy — show architecture, not file inventory

## Example

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

## README Markers

`[README]` markers serve as cheap orientation for agents. An agent reading
MAP.md can decide "this module has a README, read that first" instead of
opening 10 source files.

During init: scan each directory for README.md / README / readme.md. Mark
with `[README]` in the tree output.

During diagnose: verify markers are accurate (no stale markers, no missing
markers) and flag deep modules that lack READMEs entirely.

## Deep Platform Conventions

**When to apply:** source code lives 4+ directories below module root, a fixed
repeating scaffold exists between the module name and actual source, and multiple
modules share the same pattern.

### Boilerplate Path Formulas

Document the fixed scaffold as a formula at the top of MAP.md. This lets agents
construct the full path to source code without `find`. Adapt to whatever
framework the project uses — these are examples of the pattern, not the only
frameworks that need it.

```
# Rust workspace:
#   crates/{crate}/src/{module}.rs
#   crates/{crate}/src/{module}/mod.rs

# Expo / React Native monorepo:
#   packages/{package}/src/{feature}/
#   apps/{app}/src/screens/{screen}/

# KMP multiplatform:
#   mobile/{group}/{module}/{layer}/src/{sourceSet}/kotlin/com/{org}/{...}/
#   sourceSet: commonMain | androidMain | iosMain

# Go services:
#   services/{service}/internal/{package}/

# Gradle multi-module (Android / Spring):
#   modules/{module}/src/main/{lang}/com/{org}/{module}/
```

Any framework where source code is 4+ levels below the module root benefits
from a formula. The formula is project-specific — discover it, don't assume it.

### Per-Module Leaf Directories

Below the formula, list each module's actual leaf directories. These cannot be
assumed from convention — they must be verified via `find` or explorer output.

```
# Example (adapt to your project):
packages/
  auth/src/      → hooks/ services/ types/
  payments/src/  → api/ hooks/ utils/ types/
  shared/src/    → components/ helpers/
```

Different modules in the same framework have different leaf dirs — they can't
be inferred from the formula alone.

### When NOT to Apply

Flat projects where source files live 1-2 levels below the module root don't
need path formulas. The standard collapsed platform notation is sufficient.
Most single-package TypeScript, Python, or Ruby projects fall here.

### Source-Reachable Rule

An agent reading MAP.md alone must be able to construct the full path to any
source file. If the MAP.md entry for a module is just `appconfig/` with no
path formula and no leaf directories, the agent cannot navigate there without
running `find` — defeating the purpose. Test your MAP.md by picking a random
source file and verifying you can derive its path from the map alone.

## Maintenance and Ownership

MAP.md has multiple writers. This is the authoritative lifecycle:

| Operation        | Owner                       | When                            | Rule                                                                                       |
| ---------------- | --------------------------- | ------------------------------- | ------------------------------------------------------------------------------------------ |
| **Create**       | `/health init`              | Project onboarding              | Full generation from structural discovery                                                  |
| **Append**       | `retro` (step 7)            | After each task                 | Incremental — add new modules/paths only, never rewrite existing content                   |
| **Validate**     | `/health diagnose` (step 5) | On-demand diagnostic            | Detect drift (unmapped dirs, stale entries, missing README markers). Report only, no edits |
| **Clean up**     | `/evolve`                   | When proposals target MAP.md    | Remove stale entries, update annotations. Only via accepted proposal                       |
| **Deep refresh** | `/health init` (re-run)     | When MAP.md is severely drifted | User-triggered. Re-runs structural discovery, regenerates                                  |

**Conflict rule:** if retro appends an entry that `/health` later flags as
stale, `/evolve` is the tiebreaker — it decides whether to keep or remove
via the proposal process. No skill silently deletes MAP.md content.
