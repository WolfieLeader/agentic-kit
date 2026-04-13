# Navigation Guide

Search patterns for `wiki/` and source code. Keeps grep noise low, query shape consistent, frontmatter edges grep-discoverable.

## When to consult this guide

- Explorers (`code-explorer`, `docs-explorer`) planning search strategy
- Skills performing self-look (e.g., `yo` Pass 1 for `wiki/sketches/` resume check)
- Any agent searching `wiki/` for prior work
- Health checks scanning artifacts

## Exclusion list (always-exclude when broad-searching)

When searching broadly (e.g., `grep -r` from repo root), exclude these to cut noise. Most are gitignored, but ripgrep's coverage varies by version and flag set.

### Build and dependency directories

- `node_modules/`
- `.next/`, `.nuxt/`, `.svelte-kit/`, `.turbo/`, `.parcel-cache/`
- `dist/`, `build/`, `out/`
- `target/` (Rust, Java, Scala)
- `.venv/`, `venv/`, `__pycache__/`, `*.pyc`
- `.cache/`, `tmp/`, `temp/`
- `coverage/`, `.coverage`, `.nyc_output/`

### IDE and OS noise

- `.git/` -- NOT excluded by ripgrep default; always add explicitly
- `.DS_Store`, `Thumbs.db`
- `.idea/`, `.vscode/` (except when you're specifically reviewing editor config)

### Lockfiles (too large to be useful in keyword search)

- `package-lock.json`, `pnpm-lock.yaml`, `yarn.lock`
- `Gemfile.lock`, `Cargo.lock`, `poetry.lock`, `uv.lock`, `go.sum`

### Secrets (NEVER read)

- `.env`, `.env.*`, `*.pem`, `*.key`, `credentials.json`, `*.pfx`

## Search flag recipes

### Searching source code, excluding `wiki/` and build noise

With ripgrep:

```
rg <pattern> \
  --glob='!wiki/**' \
  --glob='!.git/**' \
  --glob='!node_modules/**' \
  --glob='!dist/**' \
  --glob='!build/**' \
  --glob='!target/**'
```

With the Grep tool: pass `glob` to scope to source extensions (`"**/*.{ts,tsx,py,go,rs}"`) or `path` to narrow to a specific source subdir. Grep tool respects `.gitignore` automatically but not `.git/` itself.

### Searching `wiki/` only

Scope with `path=wiki/`. Add `glob="**/*.md"` for markdown-only (excludes any binary or directory index files).

### Source code AND `wiki/` (rare — usually wrong)

Usually a sign you're conflating "where does this concept live" with "has anyone written about this before." Prefer two separate searches.

## Artifact queries (frontmatter-first)

Convention: YAML frontmatter fields are edges in the knowledge graph. Grep anchored (`^field: value$`) for exact match. See `skills/yo/references/artifact-ecosystem.md` for the full per-artifact frontmatter schema.

### Sketches (`wiki/sketches/`)

- By slug: `wiki/sketches/<slug>.md`
- By module: `grep -l "^module: auth$" wiki/sketches/*.md`
- Resume candidates (draft status): `grep -l "^status: draft$" wiki/sketches/*.md`
- By tier: `grep -l "^tier: deep$" wiki/sketches/*.md`

### Blueprints (`wiki/blueprints/`)

- By slug: `wiki/blueprints/<slug>.md`
- By source sketch: `grep -l "^source_sketch: <slug>$" wiki/blueprints/*.md`
- By scale (unit count): `grep "^unit_count:" wiki/blueprints/*.md`

### Retros (`wiki/retros/`)

- By module: `grep -l "^module: auth$" wiki/retros/*.md`
- By outcome: `grep -l "^outcome: \(success\|failed\|partial\)$" wiki/retros/*.md`
- By root cause category: `grep -l "^root_cause: <category>$" wiki/retros/*.md`
- Recent (last 20): `ls -t wiki/retros/??????-* | head -20`

### Reviews (`wiki/reviews/`)

- By module: `grep -l "^module: " wiki/reviews/*.md`
- Critical findings present: `grep -l "^p0_count: [1-9]" wiki/reviews/*.md`

### Diagnoses (`wiki/diagnoses/`)

- By classification: `grep -l "^classification: <type>$" wiki/diagnoses/*.md`
- By severity: `grep -l "^severity: \(high\|critical\)$" wiki/diagnoses/*.md`

### Research (`wiki/research/`)

- By module: `grep -l "^module: <name>$" wiki/research/*.md`
- By tag (unanchored, tags are arrays): `grep -l "tags:.*<tag>" wiki/research/*.md`
- Stale candidates (pre-current year): `grep "date_updated: 2025-" wiki/research/*.md`

### Pipeline exploration findings (`wiki/research/<slug>-exploration.md`)

- Per slug (written by `yo` step 15): `wiki/research/<slug>-exploration.md`
- Scoped section for one affected system (when unit-scoped context is needed in craft): grep within the file for the module/file name and Read only the matched section.

### Evolve artifacts (`wiki/evolve/`)

- Proposal file: `wiki/evolve/<slug>-proposals.md`
- Execution log: `wiki/evolve/<slug>-evolve.md`
- Open proposals: `grep -l "^status: open$" wiki/evolve/*-proposals.md`

### Reports (`wiki/reports/`)

- Health reports accumulate: `ls -t wiki/reports/*-health.md | head -5`

## Frontmatter graph (edges)

Each artifact's frontmatter defines edges to other nodes. Traversal = grep for edge field, follow value, read target.

| Field              | Meaning                  | Example traversal                    |
| ------------------ | ------------------------ | ------------------------------------ |
| `module`           | Logical module cluster   | All artifacts touching `auth`        |
| `tags`             | Topic tags               | All `security`-tagged work           |
| `slug`             | Node identity            | Direct lookup                        |
| `status`           | Node state               | Resume `draft`, skip `archived`      |
| `source_sketch`    | Blueprint -> Sketch      | Find blueprint's parent sketch       |
| `pattern`          | Retro recurring pattern  | All retros about "forgot to migrate" |
| `classification`   | Diagnosis category       | Cluster bugs by type                 |
| `related_research` | Sketch -> Research edges | Research that informed a sketch      |
| `target`           | Review -> code path      | Reviews of a specific file           |
| `diagnosis`        | Retro -> Diagnosis       | Which diagnosis prompted this retro  |

### Common cross-artifact queries

**All work touching the auth module across types:**

```
grep -lr "^module: auth$" wiki/
```

**Retros whose root cause was "missing migration":**

```
grep -l "^root_cause: missing-migration$" wiki/retros/*.md
```

**Retros downstream of a specific diagnosis:**

```
grep -l "diagnosis: 260413-001-login-flaky" wiki/retros/*.md
```

**All artifacts from today:**

```
ls wiki/{sketches,blueprints,retros,reviews,diagnoses,reports}/260413-*
```

**Stale research (any doc with a 2025 date_updated):**

```
grep -l "^date_updated: 2025-" wiki/research/*.md
```

## Anti-patterns

- `grep -r "keyword" .` from repo root -- picks up `wiki/` artifacts, build dirs, lockfiles, `node_modules/`, and `.git/`. Grep-first discovery becomes grep-first noise.
- Searching a slug without scoping the path -- many files may reference the slug; narrow to the artifact type you expect (`wiki/sketches/<slug>.md`, not `grep -r <slug> wiki/`).
- `cat wiki/retros/*.md | grep X` -- dump-and-filter pattern. Prefer `grep -l X wiki/retros/*.md` to get the file list first, then Read the matches you need.
- Broad keyword search when you have a frontmatter field -- always prefer the anchored field match (`^module: auth$`) over unanchored content match (`auth`) -- the former gives you typed edges, the latter gives you false positives.
- Forgetting `.git/` in the exclusion list -- ripgrep does not exclude it by default; you'll match commit objects and pack files.
- Reading `.env` or other secret files "to understand configuration" -- never. The exclusion list is also a read-list for "do not open."

## Project-level overrides

If `wiki/NAVIGATION.md` exists in the current project, read it after this guide. It provides project-specific:

- Additional exclusions (e.g., a generated `docs-site/build/` directory not in standard excludes)
- Project-specific artifact types or frontmatter fields
- Domain query recipes (e.g., "find all auth-module retros with `root_cause: token-expiry`")

Project overrides win on conflict. This framework guide is the default.

## Maintenance

If you write a query that isn't covered here, add a recipe to this file before duplicating the pattern inline. The guide is load-bearing precisely because patterns accumulate in one place rather than drifting across skills.
