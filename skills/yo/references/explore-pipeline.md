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

**Critical: research persistence IS the handoff mechanism.** In-context explorer
findings survive only within the current session window. If context compresses
or the session ends between EXPLORE and the subsequent BUILD/FIX, the explorer
findings are lost. But persisted research in `.docs/research/` survives across
sessions. This is why step 4 (persist) is not optional when a transition is
likely — it's the only durable bridge between EXPLORE and the next pipeline.

When sketch runs after an EXPLORE transition, it should:
1. Read `.docs/research/<topic>.md` for the persisted synthesis
2. Use in-context explorer findings if still available (same session)
3. Re-dispatch explorers only if research doc is insufficient AND original
   findings have been compressed out of context

## Gotchas

- Persist external research to `.docs/research/` -- session context dies, files survive
- Distinguish codebase evidence from model knowledge from external research
- No retro for EXPLORE -- research path, not work path
- REVIEW has its own pipeline and transitions (see yo/SKILL.md)
- If transition is likely, persistence is mandatory -- not a nice-to-have. Without it, the next pipeline starts blind.
