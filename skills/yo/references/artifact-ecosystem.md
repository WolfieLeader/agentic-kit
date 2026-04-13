# Artifact Ecosystem

`wiki/` is a knowledge graph traversable via YAML frontmatter grep.
Grep is traversal. Frontmatter fields are edges. Modules are clusters.

| Path                         | What                 | Key frontmatter                                 | Writer              | Reader                   |
| ---------------------------- | -------------------- | ----------------------------------------------- | ------------------- | ------------------------ |
| `sketches/<slug>.md`         | What/why (std/deep)  | module, tags, type, tier                        | sketch              | blueprint, verify, retro |
| `blueprints/<slug>.md`       | How — units          | source_sketch, tier, unit_count                 | blueprint           | craft, verify            |
| `retros/<slug>.md`           | Reflections          | module, tags, token_effort, outcome, root_cause | retro               | propose                  |
| `reviews/<slug>.md`          | Code review findings | module, tags, finding_count, p0-p3 counts       | yo (REVIEW)         | propose                  |
| `diagnoses/<slug>.md`        | Bug investigation    | module, tags, classification, severity          | diagnose            | sketch, propose          |
| `reports/<date>-health.md`   | Health snapshots     | date, warn_count, info_count                    | /health             | propose                  |
| `research/<topic>.md`        | External knowledge   | module, tags, date_updated                      | docs-explorer       | sketch, propose          |
| `evolve/<slug>-proposals.md` | Change proposals     | retros_analyzed, status                         | /propose            | /evolve                  |
| `evolve/<slug>-evolve.md`    | Execution log        | source_proposals, changes_made                  | /evolve             | —                        |
| `extensions/<phase>.md`      | Extension config     | phase, date_updated                             | /extensions         | phase skills             |
| `MAP.md`                     | Project navigation   | —                                               | /health init, retro | yo (self-look)           |
| `CHANGELOG.md`               | Evolve history       | —                                               | /evolve             | —                        |

## Grep Patterns

```bash
# All retros about a module (anchored match; prefer ^module: auth$)
grep -l "^module: auth$" wiki/retros/*.md

# All data points about a module
grep -lr "^module: auth$" wiki/{retros,reviews,diagnoses,reports}/

# Resume candidates
grep -l "^status: draft$" wiki/sketches/*.md

# Stale research (pre-current year)
grep -l "^date_updated: 2025-" wiki/research/*.md
```

For full query catalog, exclusion rules, and cross-artifact traversal recipes,
see `skills/navigate/references/navigation-guide.md`. This table lists the
graph's nodes; the navigation guide lists how to walk between them.
