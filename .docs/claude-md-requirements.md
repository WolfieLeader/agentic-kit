# CLAUDE.md Requirements

> Things that must be included in the project's CLAUDE.md so that skills, agents, and Claude sessions have the right context. Actual CLAUDE.md content will be written separately — this section documents what needs to be covered.

## Workflow artifacts directory
```
# Workflow Artifacts
All AI workflow artifacts live in `.docs/` (hidden directory to avoid polluting grep/rg search results).
Structure:
  .docs/work/<YYMMDD-slug>/     — brainstorm.md + plan.md + retro.md (full lifecycle per work item)
  .docs/MAP.md                  — dynamic project navigation index
All files use YAML frontmatter (module, tags, type) for grep-first retrieval.
```
**Why in CLAUDE.md**: Skills reference these paths, but `rg` and `grep` skip dotdirs by default. Without this note, an agent doing codebase exploration won't know to look in `.docs/` for existing research, plans, or solutions. Every skill that reads or writes to `.docs/` depends on this being documented.

## Available CLI tools
```
# CLI Tools
- `tree` is available (macOS) — use it for directory structure exploration
- `rtk` (https://github.com/rtk-ai/rtk) is installed — token-optimized CLI proxy for dev operations (60-90% savings). There is a hook that rewrites commands automatically, but be aware it exists for context
```
**Why in CLAUDE.md**: `tree` is not available on all systems — stating it's available means Claude can use it confidently for directory exploration instead of falling back to `ls -R` or `find`. RTK is already handled by hooks, but noting it in CLAUDE.md gives Claude awareness that CLI output may be filtered/compressed, which matters if output looks unexpectedly terse.
