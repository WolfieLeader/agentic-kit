---
name: yo
description: >
  Use when: user wants to build a feature, fix a bug, explore/research a question,
  review code, or start any development task. Universal entry point -- routes to
  BUILD, FIX, EXPLORE, or REVIEW pipeline with right-sized ceremony.
type: user-invokable
---

# Yo

Universal entry point. Classifies the task, gathers context, and orchestrates
the full pipeline.

## Context

- **Receives:** user input (natural language task description)
- **Reads:** MAP.md, CLAUDE.md, `.docs/extensions/router.md`
- **Greps:** `.docs/sketches/`, `.docs/retros/`, `.docs/research/` YAML frontmatter (module, tags, title)
- **Scans:** files likely to change (grep on keywords), git diff/log when relevant
- **Generates:** slug (`YYMMDD-NNN-kebab-topic`, NNN resets daily starting at 001)

## Procedure

### Pass 1: Self-Look

Gather project context before engaging the user.

1. Read MAP.md (if exists) + CLAUDE.md for project structure and conventions.
2. If `.docs/` directory or MAP.md missing, run `/health init` to onboard the
   project first. Resume self-look after onboarding completes.
3. Grep `.docs/sketches/` and `.docs/blueprints/` for matching module/tags/title --
   this is the resume check. If a slug matches with `status: draft`, hold for Pass 4.
4. Grep `.docs/research/` for prior research on the topic.
5. Scan likely files based on user input (file names, imports, key identifiers).
6. Check git context if user references recent changes (diff, log).

### Pass 2: Classify

Classify from user input + self-look context.

7. **Type** -- BUILD / FIX / EXPLORE / REVIEW.

   | Type    | Signal words                                                              |
   |---------|---------------------------------------------------------------------------|
   | BUILD   | "add", "create", "build", "implement", "new", "feature", "refactor", "migrate" |
   | FIX     | "fix", "bug", "broken", "error", "failing", "crash", "regression", "flaky"     |
   | EXPLORE | "why", "how does", "what would it take", "compare", "investigate", "research"  |
   | REVIEW  | "review", "check code", "audit code", "look at this PR", "code review"        |

   When ambiguous, lean toward more investigation: FIX over BUILD, EXPLORE over FIX.

8. **Provisional tier** (BUILD/FIX only) -- lightweight / standard / deep.
   - Lightweight: single file/function, low ambiguity, clear scope, one concern.
   - Standard: multi-file, some decisions needed, 2-3 systems.
   - Deep: multi-subsystem, high ambiguity, architectural decisions.

   Lightweight is the exception. 2+ files or 2+ concerns = standard.

### Pass 3: Dynamic Questioning

Scale question depth to user clarity:

| User clarity               | Behavior                                    |
|----------------------------|---------------------------------------------|
| Intent + scope clear       | Classify, confirm, dispatch. 1 round.       |
| Intent clear, scope unclear| 1-2 rounds to scope.                        |
| Intent unclear             | Probe intent first, then scope. 2-3 rounds. |
| Both unclear               | Iterative checkpoints until dispatch-ready.  |

9. **Checkpoint summary pattern:** present facts + assumptions + 0-2 genuine
   questions (with recommended answers). If the codebase can answer it, don't ask.

10. **Exit condition:** stop when you can write a clear one-paragraph dispatch
    summary covering what, where, and why.

**Shortcuts:** clear spec or stated urgency = fast-track. Don't force questioning.

### Pass 4: Resume Check

11. If matching artifact found in Pass 1: "I found existing work for
    [slug] -- here's what's done: [summary]. Continue from here or start
    fresh?" User decides.

### Pass 5: Dispatch Explorers (std/deep and REVIEW only)

Lightweight BUILD/FIX skips this entirely.

12. Dispatch code-explorer + docs-explorer in parallel with directed context
    from self-look -- specific search terms, file paths, module names.
13. If `.docs/extensions/router.md` exists, dispatch extension explorers defined there.
14. Wait for explorer findings (in-context, not persisted -- sketch absorbs
    what matters).
15. Confirm final classification with explorer context. Tier may shift.

### Pass 6: Pipeline Orchestration

16. Generate slug: `YYMMDD-NNN-kebab-topic`. To determine NNN: glob today's date
    prefix (`YYMMDD-*`) across `.docs/{sketches,diagnoses,reviews,retros}/`.
    Find highest NNN, increment. If none, start at 001.

17. Route to pipeline based on type and tier:

    ```
    BUILD (light):     craft → verify → retro
    BUILD (std/deep):  sketch → blueprint → craft → verify → retro
    FIX (light):       diagnose → craft → verify → retro
    FIX (std/deep):    diagnose → sketch → blueprint → craft → verify → retro
    EXPLORE:           synthesize → persist research → done | transition
    REVIEW:            explore → code-review → persist review → done | transition
    ```

    See `references/explore-pipeline.md` for EXPLORE synthesis and transition rules.

18. For each phase: load the phase's SKILL.md via Skill tool, follow it,
    write artifacts to disk, then load next.
19. Lightweight: all phases run inline in parent session. No subagents
    except diagnose extensions.

### Pass 7: Transitions

20. EXPLORE may transition to BUILD or FIX -- reuse explorer findings and
    research context without re-exploration.
21. REVIEW may transition to FIX -- reuse review findings and explorer context.
    "Found a bug during review, let's fix it."

Pipeline ends at retro (BUILD/FIX), research persistence (EXPLORE), or review
persistence (REVIEW). Don't suggest git operations after completion.

## REVIEW Pipeline

REVIEW composes existing pieces -- no new skill needed.

1. **Scope**: determine what to review (module path, PR number, file list).
2. **Explore**: dispatch code-explorer + docs-explorer for context.
3. **Review**: dispatch code-reviewer agent with exploration findings + diff/scope.
4. **Persist**: write review artifact to `.docs/reviews/<slug>.md` with YAML frontmatter
   (module, tags, date, finding counts by severity).
5. **Present**: show findings to user. Offer transition to FIX if actionable bugs found.

For PR review: get diff via `gh pr diff <number>`, pass as input to code-reviewer.
For module review: explorers provide the context, code-reviewer reviews the code.

## Artifact Ecosystem

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

**Grep patterns:**
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

## Output

- Dispatch summary (in-context) with type + tier classification
- Slug generated
- Pipeline completion through all routed phases

## References

- `references/explore-pipeline.md` -- EXPLORE synthesis, citation rules, transition protocol

## Gotchas

- **Classify after understanding.** Self-look first, classify second.
- **Lightweight is the exception.** 2+ files or 2+ concerns is standard.
- **Direct the explorers.** Specific search terms and file paths, not "look around."
- **Shortcuts exist.** Clear spec + urgency = fast-track.
- **Resume before restart.** Check `.docs/sketches/` for draft status before creating new slug.
- **REVIEW is not EXPLORE.** EXPLORE = understanding. REVIEW = evaluating and finding problems.
