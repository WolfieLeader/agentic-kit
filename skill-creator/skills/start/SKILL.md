---
name: start
description: >
  Universal entry point for all development work. Routes to BUILD, FIX, or EXPLORE pipelines.
  Use whenever the user wants to build a feature, fix a bug, explore/research something, or
  continue prior work. The only user-invoked skill — orchestrates the full pipeline.
type: user-invokable
---

# /start — Router & Pipeline Orchestrator

Universal entry point. Classifies work, dispatches explorers, orchestrates phases.

## Context

**Receives:** user input
**Reads:** MAP.md, CLAUDE.md, .docs/extend/router.md
**Greps:** .docs/work/ and .docs/research/ YAML frontmatter (module, tags, title)
**Scans:** likely files (grep based on user input), git diff/log (when relevant)

## Procedure

### Phase 1: Self-Look

1. Read MAP.md for project structure. If missing, generate via `rtk tree` / `tree` / `ls` — write to `.docs/MAP.md`.
2. Read CLAUDE.md for project conventions and verification suite.
3. Grep `.docs/work/` frontmatter for matching module/tags/title — check for resume candidates.
4. Grep `.docs/research/` frontmatter for prior research on the topic.
5. Scan files likely to change (grep based on keywords from user input).
6. Check `git diff`/`git log` if user references recent changes.

### Phase 2: Resume Check

If matching work folder found in `.docs/work/`:
- Tell user what exists with brief preview: "Found existing work for [slug] — here's what's done: [summary]. Continue from here or start fresh?"
- User decides. If continue → identify last completed phase, resume from next.
- If start fresh → new slug, proceed normally.

### Phase 3: Classify

**Type** (from user input):
- **BUILD:** add, create, build, implement, new, feature, refactor, migrate
- **FIX:** fix, bug, broken, error, failing, crash, regression, flaky
- **EXPLORE:** why, how does, what would it take, audit, compare, investigate, research

**Provisional tier** (from self-look):
- **Lightweight:** single file/function, low ambiguity
- **Standard:** multi-file, some decisions
- **Deep:** multi-subsystem, high ambiguity

Question lightweight classification — most tasks touching 2+ files or 2+ concerns are standard.

### Phase 4: Dynamic Questioning

Scale questioning to user's clarity level:

| Clarity | Behavior |
|---|---|
| Intent + scope clear | Classify, confirm, dispatch. 1 checkpoint round. |
| Intent clear, scope unclear | 1-2 rounds to scope, then dispatch. |
| Intent unclear | Probe intent first, then scope. 2-3 rounds. |
| Both unclear | Iterative checkpoints until dispatch-ready. |

**Checkpoint summary pattern:** Present facts + assumptions from self-look + 0-2 genuine questions with recommended answers. User corrects/confirms. Questions are expensive — if the codebase can answer it, don't ask.

**Exit condition:** Stop questioning when you can write a clear one-paragraph dispatch summary.

**Shortcuts:** If user states urgency or provides clear spec, fast-track. Don't force questioning when clarity exists.

### Phase 5: Dispatch Explorers (std/deep only)

Lightweight skips this entirely.

1. Read `.docs/extend/router.md` for extension explorers.
2. Dispatch **code-explorer** and **docs-explorer** agents in parallel via Agent tool. Give each directed search terms from self-look. Include extension explorers if configured.
3. Explorer findings stay in session context — not persisted. Sketch absorbs what matters.
4. Confirm final tier classification after explorer findings available.

### Phase 6: Generate Slug

Format: `YYMMDD-kebab-case` (e.g., `260411-notification-system`).
Duplicate slug → resume flow (Phase 2).
Create `.docs/work/<slug>/` directory.

### Phase 7: Pipeline Dispatch

Route based on type + tier:

**EXPLORE:**
- Synthesize explorer findings into clear answer.
- Persist external research to `.docs/research/<topic>.md` if any.
- Offer transition: "Let's build it" → reclassify as BUILD. "Fix what we found" → FIX. "Just needed to know" → done.
- No retro for EXPLORE.

**BUILD/FIX — Lightweight:**
```
(trace if FIX) → craft → verify → retro
```
All inline in parent session. No subagents, no extensions.
- If FIX: invoke trace skill via Skill tool. If not a bug → done.
- Invoke craft skill (lightweight mode).
- Invoke verify skill (lightweight mode).
- Invoke retro skill.

**BUILD/FIX — Standard/Deep:**
```
(trace if FIX) → sketch → blueprint → craft → verify → retro
```
- If FIX: invoke trace skill. Route based on trace output.
- Invoke sketch skill → writes sketch.md
- Invoke blueprint skill → writes blueprint.md (includes review gate)
- Invoke craft skill (std/deep mode) → sequential subagents per unit
- Invoke verify skill (std/deep mode) → dispatches code reviewer
- Invoke retro skill → writes retro.md, updates MAP.md

**Phase transitions are explicit:** Finish one phase, load the next via Skill tool. Artifacts on disk are the handoff mechanism.

## Output

**Produces:**
- Dispatch summary (in-context)
- Type + tier classification
- Slug and work directory
- MAP.md (generated on first run if missing)

**Passes to:** trace (FIX) | sketch (BUILD/FIX std/deep) | craft (BUILD/FIX light) | EXPLORE synthesis

## Gotchas

- Classify after understanding, not before — rushed routing → wrong tier → wasted work
- Question lightweight classification — 2+ files or 2+ concerns is usually standard
- Dispatch explorers with specific search terms, not "look around"
- Don't force questioning when user already provides clear spec
- Explore transitions reuse explorer findings — no re-exploration needed
