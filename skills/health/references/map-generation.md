# MAP.md Generation

MAP.md maps the project codebase (not `.docs/`). Generated during `/health init`.

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

## Maintenance

MAP.md is maintained incrementally by retros that touch new modules/paths.
`/health` diagnose mode checks for drift between MAP.md and actual structure.
`/evolve` cleans up stale entries when proposals target it.
