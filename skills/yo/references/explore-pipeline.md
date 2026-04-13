# EXPLORE Pipeline Reference

EXPLORE is lightweight by nature. No retro produced.

## Procedure

1. Explorer findings already dispatched by router -- wait for completion.
2. Synthesize findings into clear answer for user.
3. Cite sources for every finding:
   - **Codebase evidence** -- file path, line, grep result
   - **Model knowledge** -- label explicitly
   - **External research** -- URL, doc version, date accessed
4. If external research was done, persist to `.docs/research/<topic>.md` with frontmatter:
   ```yaml
   ---
   title: Topic Name
   date_created: YYYY-MM-DD
   date_updated: YYYY-MM-DD
   module: relevant-module
   tags: [tag1, tag2]
   ---
   ```
5. Present answer to user.

## Transition (Optional)

After presenting findings, offer transition:
- "Let's build it" -- reclassify as BUILD, reuse explorer findings and research
- "Fix what we found" -- reclassify as FIX, same context reuse
- "Just needed to know" -- done

No re-exploration on transition. All context carries forward in session.

## Gotchas

- Persist external research to `.docs/research/` -- session context dies, files survive
- Distinguish codebase evidence from model knowledge from external research
- No retro for EXPLORE -- research path, not work path
- REVIEW has its own pipeline and transitions (see yo/SKILL.md)
