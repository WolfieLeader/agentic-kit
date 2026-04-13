# Artifact Ecosystem

`.docs/` is a knowledge graph traversable via YAML frontmatter grep.
Grep is traversal. Frontmatter fields are edges. Modules are clusters.

| Path | What | Key frontmatter | Writer | Reader |
|---|---|---|---|---|
| `sketches/<slug>.md` | What/why (std/deep) | module, tags, type, tier | sketch | blueprint, verify, retro |
| `blueprints/<slug>.md` | How — units | source_sketch, tier, unit_count | blueprint | craft, verify |
| `retros/<slug>.md` | Reflections | module, tags, token_effort, outcome, root_cause | retro | propose |
| `reviews/<slug>.md` | Code review findings | module, tags, finding_count, p0-p3 counts | yo (REVIEW) | propose |
| `diagnoses/<slug>.md` | Bug investigation | module, tags, classification, severity | diagnose | sketch, propose |
| `reports/<date>-health.md` | Health snapshots | date, warn_count, info_count | /health | propose |
| `research/<topic>.md` | External knowledge | module, tags, date_updated | docs-explorer | sketch, propose |
| `evolve/<slug>-proposals.md` | Change proposals | retros_analyzed, status | /propose | /evolve |
| `evolve/<slug>-evolve.md` | Execution log | source_proposals, changes_made | /evolve | — |
| `extensions/<phase>.md` | Extension config | phase, date_updated | /extensions | phase skills |
| `MAP.md` | Project navigation | — | /health init, retro | yo (self-look) |
| `CHANGELOG.md` | Evolve history | — | /evolve | — |

## Grep Patterns

```bash
# All retros about a module
grep -r "module: auth" .docs/retros/

# All data points about a module
grep -r "module: auth" .docs/{retros,reviews,diagnoses,reports}/

# Resume candidates
grep -r "status: draft" .docs/sketches/

# Stale research
grep -r "date_updated:" .docs/research/
```
