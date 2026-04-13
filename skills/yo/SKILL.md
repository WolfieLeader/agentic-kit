---
name: yo
description: >
  Pipeline orchestrator. Invoke ONLY when the user explicitly types /yo, or
  explicitly requests "run the pipeline" / "use the full workflow" / "route
  through the router". Do NOT auto-invoke on routine development requests
  (features, bugs, code review) -- handle those with direct tools unless the
  user opts into the pipeline's ceremony. The ceremony is opt-in, not default.
type: user-invocable
---

# Yo

Universal entry point. Classifies the task, gathers context, and orchestrates
the full pipeline.

## Context

- **Receives:** user input (natural language task description)
- **Reads:** MAP.md, CLAUDE.md, `wiki/extensions/router.md`
- **Greps:** `wiki/sketches/`, `wiki/retros/`, `wiki/research/` YAML frontmatter (module, tags, title)
- **Scans:** files likely to change (grep on keywords), git diff/log when relevant
- **Generates:** slug (`YYMMDD-NNN-kebab-topic`, NNN resets daily starting at 001)

## Procedure

### Pass 1: Self-Look

Gather project context before engaging the user.

1. Read MAP.md (if exists) + CLAUDE.md for project structure and conventions.
2. If `wiki/` directory or MAP.md missing, run `/health init` to onboard the
   project first. Resume self-look after onboarding completes.
3. **Umbrella detection:** if the project has multiple repos (monorepo workspaces,
   sibling repos in a parent directory, or CLAUDE.md lists multiple repos), run
   `git status -sb` across **all** repos. This surfaces uncommitted work, active
   branches, and pending changes you'd otherwise miss during commit phase.
4. Grep `wiki/sketches/` and `wiki/blueprints/` for matching module/tags/title --
   this is the resume check. If a slug matches with `status: draft`, hold for Pass 4.
5. Grep `wiki/research/` for prior research on the topic.
6. Scan likely files based on user input (file names, imports, key identifiers).
7. Check git context if user references recent changes (diff, log).

### Pass 2: Classify

Classify from user input + self-look context.

8. **Type** -- BUILD / FIX / EXPLORE / REVIEW.

   | Type    | Signal words                                                                   |
   | ------- | ------------------------------------------------------------------------------ |
   | BUILD   | "add", "create", "build", "implement", "new", "feature", "refactor", "migrate" |
   | FIX     | "fix", "bug", "broken", "error", "failing", "crash", "regression", "flaky"     |
   | EXPLORE | "why", "how does", "what would it take", "compare", "investigate", "research"  |
   | REVIEW  | "review", "check code", "audit code", "look at this PR", "code review"         |

   When ambiguous, lean toward more investigation: FIX over BUILD, EXPLORE over FIX.

9. **Provisional tier** (BUILD/FIX only) -- lightweight / standard / deep.
   - Lightweight: single file/function, low ambiguity, clear scope, one concern.
   - Standard: multi-file, some decisions needed, 2-3 systems.
   - Deep: multi-subsystem, high ambiguity, architectural decisions.

   Lightweight is the exception. 2+ files or 2+ concerns = standard.

### Pass 3: Dynamic Questioning

Scale question depth to user clarity:

| User clarity                | Behavior                                    |
| --------------------------- | ------------------------------------------- |
| Intent + scope clear        | Classify, confirm, dispatch. 1 round.       |
| Intent clear, scope unclear | 1-2 rounds to scope.                        |
| Intent unclear              | Probe intent first, then scope. 2-3 rounds. |
| Both unclear                | Iterative checkpoints until dispatch-ready. |

10. **Checkpoint summary pattern:** present facts + assumptions + 0-2 genuine
    questions (with recommended answers). If the codebase can answer it, don't ask.

11. **Exit condition:** stop when you can write a clear one-paragraph dispatch
    summary covering what, where, and why.

**Shortcuts:** clear spec or stated urgency = fast-track. Don't force questioning.

### Pass 4: Resume Check

12. If matching artifact found in Pass 1: "I found existing work for
    [slug] -- here's what's done: [summary]. Continue from here or start
    fresh?" User decides.

### Pass 5: Dispatch Explorers (std/deep and REVIEW only)

Lightweight BUILD/FIX skips this entirely.

13. Dispatch **framework explorers** in parallel with directed context from
    self-look -- specific search terms, file paths, module names:
    - `Agent(subagent_type: "general-purpose")` with `agents/code-explorer.md` instructions -- scans source code, traces dependencies, checks git history
    - `Agent(subagent_type: "general-purpose")` with `agents/docs-explorer.md` instructions -- searches `wiki/` artifacts, research docs, external sources

    See `references/agent-dispatch.md` for the `subagent_type` disambiguation (built-in `Explore` vs marketplace `feature-dev:code-explorer` vs framework `general-purpose` pattern).

14. If `wiki/extensions/router.md` exists, dispatch extension explorers defined there.
15. Collect explorer findings and **persist immediately** to
    `wiki/research/<slug>-exploration.md` with YAML frontmatter (slug, date,
    explorers, scope). Keep only a 5-line digest + file path in the orchestrator's
    active context. Sketch, blueprint, and craft re-read specific sections on
    demand via grep/Read -- findings do not accumulate in the orchestrator
    through the pipeline. This is the single biggest lever against context
    bloat: raw findings are 2-5k tokens per explorer, and without persistence
    they ride through every subsequent phase.
16. Confirm final classification with the digest. Tier may shift.

### Pass 6: Pipeline Orchestration

17. Generate slug: `YYMMDD-NNN-kebab-topic`. To determine NNN: glob today's date
    prefix (`YYMMDD-*`) across `wiki/{sketches,diagnoses,reviews,retros}/`.
    Find highest NNN, increment. If none, start at 001.

18. Route to pipeline based on type and tier:

    ```
    BUILD (light):     craft → verify → retro
    BUILD (std/deep):  sketch → blueprint → craft → verify → retro
    FIX (light):       diagnose → craft → verify → retro
    FIX (std/deep):    diagnose → sketch → blueprint → craft → verify → retro
    EXPLORE:           synthesize → persist research → done | transition
    REVIEW:            explore → code-review → persist review → done | transition
    ```

    See `references/explore-pipeline.md` for EXPLORE synthesis and transition rules.

19. For each phase: load the phase's SKILL.md via Skill tool, follow it,
    write artifacts to disk. Perform the handoff checkpoint (20) before
    loading the next phase.
20. **Phase handoff checkpoint (std/deep)** -- after each phase writes its
    artifact, present to user:
    - Phase complete: `<phase>` -> `wiki/<type>/<slug>.md`
    - 2-3 line summary of the artifact's content
    - Next phase: `<name>`
    - "Proceed, revise, or stop?"
      Wait for explicit user response. Do NOT auto-advance on silence, tool
      output, or related signals. The checkpoint exists so the user can adjust
      course between phases; without it the pipeline steamrolls and the
      orchestrator's context accumulates everything.
21. **Auto-advance opt-in** -- if the user said "run it all" / "auto-proceed"
    at dispatch, skip 20 for the session. Lightweight tier auto-advances by
    default, because skipping ceremony is its entire purpose.
22. Lightweight: all phases run inline in parent session. No subagents
    except diagnose extensions.

### Pass 7: Transitions

23. EXPLORE may transition to BUILD or FIX -- reuse explorer findings and
    research context without re-exploration.
24. REVIEW may transition to FIX -- reuse review findings and explorer context.
    "Found a bug during review, let's fix it."

Pipeline ends at retro (BUILD/FIX), research persistence (EXPLORE), or review
persistence (REVIEW). Don't suggest git operations after completion.

## REVIEW Pipeline

REVIEW composes existing pieces -- scope -> explore -> review -> persist ->
present. See `references/review-pipeline.md` for the full procedure, PR vs
module input patterns, and checkpoint behavior.

## Artifact Ecosystem

`wiki/` is a knowledge graph traversable via YAML frontmatter grep.
See `references/artifact-ecosystem.md` for the full directory mapping, frontmatter schema, and grep patterns.

## Output

- Dispatch summary (in-context) with type + tier classification
- Slug generated
- Pipeline completion through all routed phases

## References

- `references/agent-dispatch.md` -- how to compose Agent tool calls with framework agent files; `subagent_type` disambiguation
- `references/explore-pipeline.md` -- EXPLORE synthesis, citation rules, transition protocol
- `references/artifact-ecosystem.md` -- `wiki/` directory mapping, frontmatter schema, grep patterns
- `references/review-pipeline.md` -- REVIEW scope/explore/review/persist/present procedure
- `references/rationalization-red-flags.md` -- 8 router rationalizations and why each fails

## Gotchas

- **Classify after understanding.** Self-look first, classify second.
- **Lightweight is the exception.** 2+ files or 2+ concerns is standard.
- **Direct the explorers.** Specific search terms and file paths, not "look around."
- **Shortcuts exist.** Clear spec + urgency = fast-track.
- **Resume before restart.** Check `wiki/sketches/` for draft status before creating new slug.
- **REVIEW is not EXPLORE.** EXPLORE = understanding. REVIEW = evaluating and finding problems.
- **Umbrella projects need a full sweep.** Self-look must cover all repos, not just the one the user mentioned. Uncommitted changes in sibling repos cause surprise conflicts at push time.
- **Explorer naming matters.** `"Explore"` = fast built-in (grep/glob only). `"feature-dev:code-explorer"` = marketplace plugin. Framework explorers = `"general-purpose"` with agent .md loaded. Using the wrong type dispatches the wrong agent with the wrong tools.
- **Phase checkpoint is mandatory for std/deep.** Step 20 requires explicit user "proceed" between phases. Silence is not consent. The pause is what keeps orchestrator context from accumulating every phase's artifact through the whole pipeline.
- **Explorer findings persist first, then digest.** Raw findings (~2-5k tokens per explorer) do not belong in the orchestrator's active context -- write to `wiki/research/<slug>-exploration.md` immediately, keep only the digest + path.
- **Check rationalizations before skipping.** 8 specific router traps in `references/rationalization-red-flags.md` -- read when tempted to skip self-look or auto-advance through a checkpoint.
