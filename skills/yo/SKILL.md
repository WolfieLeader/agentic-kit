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
3. **Umbrella detection:** if the project has multiple repos (monorepo workspaces,
   sibling repos in a parent directory, or CLAUDE.md lists multiple repos), run
   `git status -sb` across **all** repos. This surfaces uncommitted work, active
   branches, and pending changes you'd otherwise miss during commit phase.
4. Grep `.docs/sketches/` and `.docs/blueprints/` for matching module/tags/title --
   this is the resume check. If a slug matches with `status: draft`, hold for Pass 4.
5. Grep `.docs/research/` for prior research on the topic.
6. Scan likely files based on user input (file names, imports, key identifiers).
7. Check git context if user references recent changes (diff, log).

### Pass 2: Classify

Classify from user input + self-look context.

8. **Type** -- BUILD / FIX / EXPLORE / REVIEW.

   | Type    | Signal words                                                              |
   |---------|---------------------------------------------------------------------------|
   | BUILD   | "add", "create", "build", "implement", "new", "feature", "refactor", "migrate" |
   | FIX     | "fix", "bug", "broken", "error", "failing", "crash", "regression", "flaky"     |
   | EXPLORE | "why", "how does", "what would it take", "compare", "investigate", "research"  |
   | REVIEW  | "review", "check code", "audit code", "look at this PR", "code review"        |

   When ambiguous, lean toward more investigation: FIX over BUILD, EXPLORE over FIX.

9. **Provisional tier** (BUILD/FIX only) -- lightweight / standard / deep.
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
    - `Agent(subagent_type: "general-purpose")` with `agents/docs-explorer.md` instructions -- searches `.docs/` artifacts, research docs, external sources

    > **Disambiguation:** `subagent_type: "Explore"` is the built-in fast
    > codebase explorer (grep/glob only). `subagent_type: "feature-dev:code-explorer"`
    > is an unrelated marketplace plugin. Framework explorers use `"general-purpose"`
    > with the agent's instructions loaded as the prompt -- this gives them full
    > tool access (Bash, Read, Grep, etc.) that the fast explorer lacks.

14. If `.docs/extensions/router.md` exists, dispatch extension explorers defined there.
15. Wait for explorer findings (in-context, not persisted -- sketch absorbs
    what matters).
16. Confirm final classification with explorer context. Tier may shift.

### Pass 6: Pipeline Orchestration

17. Generate slug: `YYMMDD-NNN-kebab-topic`. To determine NNN: glob today's date
    prefix (`YYMMDD-*`) across `.docs/{sketches,diagnoses,reviews,retros}/`.
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
    write artifacts to disk, then load next.
20. Lightweight: all phases run inline in parent session. No subagents
    except diagnose extensions.

### Pass 7: Transitions

21. EXPLORE may transition to BUILD or FIX -- reuse explorer findings and
    research context without re-exploration.
22. REVIEW may transition to FIX -- reuse review findings and explorer context.
    "Found a bug during review, let's fix it."

Pipeline ends at retro (BUILD/FIX), research persistence (EXPLORE), or review
persistence (REVIEW). Don't suggest git operations after completion.

## REVIEW Pipeline

REVIEW composes existing pieces -- no new skill needed.

1. **Scope**: determine what to review (module path, PR number, file list).
2. **Explore**: dispatch framework explorers (see Pass 5 disambiguation) for context.
   For umbrella projects, include **inter-service communication paths** as an explicit
   exploration dimension -- HTTP clients, shared contracts, message queues between repos.
3. **Review**: dispatch code-reviewer agent with exploration findings + diff/scope.
4. **Persist**: write review artifact to `.docs/reviews/<slug>.md` with YAML frontmatter
   (module, tags, date, finding counts by severity).
5. **Present**: show findings to user. Offer transition to FIX if actionable bugs found.

For PR review: get diff via `gh pr diff <number>`, pass as input to code-reviewer.
For module review: explorers provide the context, code-reviewer reviews the code.

## Artifact Ecosystem

`.docs/` is a knowledge graph traversable via YAML frontmatter grep.
See `references/artifact-ecosystem.md` for the full directory mapping, frontmatter schema, and grep patterns.

## Output

- Dispatch summary (in-context) with type + tier classification
- Slug generated
- Pipeline completion through all routed phases

## References

- `references/agent-dispatch.md` -- how to compose Agent tool calls with framework agent files
- `references/explore-pipeline.md` -- EXPLORE synthesis, citation rules, transition protocol
- `references/artifact-ecosystem.md` -- `.docs/` directory mapping, frontmatter schema, grep patterns

## Gotchas

- **Classify after understanding.** Self-look first, classify second.
- **Lightweight is the exception.** 2+ files or 2+ concerns is standard.
- **Direct the explorers.** Specific search terms and file paths, not "look around."
- **Shortcuts exist.** Clear spec + urgency = fast-track.
- **Resume before restart.** Check `.docs/sketches/` for draft status before creating new slug.
- **REVIEW is not EXPLORE.** EXPLORE = understanding. REVIEW = evaluating and finding problems.
- **Umbrella projects need a full sweep.** Self-look must cover all repos, not just the one the user mentioned. Uncommitted changes in sibling repos cause surprise conflicts at push time.
- **Explorer naming matters.** `"Explore"` = fast built-in (grep/glob only). `"feature-dev:code-explorer"` = marketplace plugin. Framework explorers = `"general-purpose"` with agent .md loaded. Using the wrong type dispatches the wrong agent with the wrong tools.

## Rationalization Red Flags

If you catch yourself thinking any of these, STOP and follow the router procedure:

1. "I already know this codebase" — self-look catches changes since your last session. MAP.md and recent retros may have shifted the landscape.
2. "This is obviously BUILD/FIX" — classify after self-look, not before. Misclassification routes to the wrong pipeline.
3. "I can explore the code myself during craft" — explorers run in parallel and surface cross-module context you'd miss under implementation tunnel vision.
4. "This seems simple, lightweight is fine" — 2+ files or 2+ concerns = standard. Underclassification causes mid-implementation rework.
5. "Let me start fresh, the old sketch is stale" — ask the user. Their in-progress work may be more current than you think.
6. "The user wants me to just do it" — urgency is a shortcut trigger, not a skip-everything trigger. Fast-track still classifies and confirms.
