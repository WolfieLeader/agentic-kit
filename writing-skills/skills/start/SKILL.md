---
name: start
description: >
  Use when starting any development task. Universal entry point that routes
  to BUILD, FIX, or EXPLORE pipelines with tier-scaled ceremony.
type: user-invokable
---

# Start

Universal entry point. Classifies the task, gathers context, and orchestrates
the full pipeline. This is the only user-invoked skill — everything else is
dispatched from here.

## Context

- **Receives:** user input (natural language task description)
- **Reads:** MAP.md, CLAUDE.md, `.docs/extend/router.md`
- **Greps:** `.docs/work/` YAML frontmatter (resume check), `.docs/research/` (prior research)
- **Scans:** files likely to change, git diff/log (when user references recent changes)
- **Produces:** dispatch summary (in-context), type + tier classification
- **Generates:** MAP.md on first run if missing; slug (YYMMDD-kebab-case)

## Procedure

### Pass 1: Self-Look

Gather project context before engaging the user.

1. Read MAP.md (if exists) + CLAUDE.md for project structure and conventions.
2. Grep `.docs/work/` YAML frontmatter for matching module/tags/title — this
   is the resume check. If a slug matches, hold that for Pass 4.
3. Grep `.docs/research/` for prior research on the topic.
4. Scan likely files based on user input (light grepping — file names, imports,
   key identifiers).
5. Check git context if user references recent changes (diff, log).
6. If MAP.md missing → generate it. See `references/routing-guide.md` for
   MAP.md generation rules.

### Pass 2: Classify

Classify from user input + self-look context.

7. **Type** — BUILD / FIX / EXPLORE. See `references/routing-guide.md` for
   signal words. When ambiguous, lean toward the type that requires more
   investigation (FIX over BUILD, EXPLORE over FIX).

8. **Provisional tier** — lightweight / standard / deep.
   - Lightweight: single file/function, low ambiguity, clear scope, one concern.
   - Standard: multi-file, some decisions needed, 2-3 systems.
   - Deep: multi-subsystem, high ambiguity, architectural decisions.

   Question lightweight classification — most tasks touching 2+ files or 2+
   concerns are standard.

### Pass 3: Dynamic Questioning

Scale question depth to user clarity:

| User clarity               | Behavior                                      |
|----------------------------|-----------------------------------------------|
| Intent + scope clear       | Classify, confirm, dispatch. 1 round.         |
| Intent clear, scope unclear| 1-2 rounds to scope.                          |
| Intent unclear             | Probe intent first, then scope. 2-3 rounds.   |
| Both unclear               | Iterative checkpoints until dispatch-ready.    |

9. **Checkpoint summary pattern:** present facts + assumptions + 0-2 genuine
   questions (with recommended answers). Include agent assumptions from MAP.md,
   CLAUDE.md, and codebase context. If the codebase can answer it, don't ask.

10. **Exit condition:** stop when you can write a clear one-paragraph dispatch
    summary covering what, where, and why.

**Shortcuts:** if the user provides a clear spec or states urgency, fast-track.
Don't force questioning when clarity already exists.

### Pass 4: Resume Check

11. If matching work folder found in Pass 1: "I found existing work for
    [slug] — here's what's done: [summary]. Continue from here or start
    fresh?" User decides.

### Pass 5: Dispatch

12. For std/deep: dispatch explorer agents (code-explorer + docs-explorer) in
    parallel with directed context from self-look — specific search terms,
    not "look around."
13. If `.docs/extend/router.md` exists, dispatch extension explorers defined there.
14. Wait for explorer findings (in-context, not persisted — sketch absorbs
    what matters).
15. Confirm final classification with explorer context. Tier may shift.

### Pass 6: Pipeline Orchestration

16. Route to pipeline based on type and tier:

    ```
    light BUILD:    craft → verify → retro
    light FIX:      trace → craft → verify → retro
    std/deep BUILD: sketch → blueprint → craft → verify → retro
    std/deep FIX:   trace → sketch → blueprint → craft → verify → retro
    EXPLORE:        synthesize findings → persist if external → done
    ```

    See `references/routing-guide.md` for EXPLORE transition rules.

17. For each phase: load the phase's SKILL.md via Skill tool, follow it,
    write artifacts to disk, then load next.
18. Lightweight: all phases run inline in parent session. No subagents
    except trace extensions.
19. EXPLORE may transition to BUILD or FIX — reuse explorer findings and
    research context without re-exploration.

## Output

Pipeline completion. Git workflow is the user's choice — don't suggest it.

## Gotchas

- **Classify after understanding, not before.** Rushed routing = wrong tier,
  wasted work. Self-look first, classify second.
- **Question lightweight.** Most tasks touching 2+ files or 2+ concerns are
  standard. Lightweight is the exception, not the default.
- **Direct the explorers.** Dispatch with specific search terms, file paths,
  module names. "Look at the auth module for token refresh logic" not
  "explore the codebase."
- **Shortcuts exist.** Clear spec + stated urgency = fast-track. Don't force
  ceremony when the user already has clarity.
- **Pipeline ends at retro.** Don't suggest git operations after completion.
- **Resume before restart.** Always check `.docs/work/` before creating a
  new slug. Duplicate slugs mean wasted prior work.
