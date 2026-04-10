# Workflow Design

> Architecture for the three core workflows and the router that dispatches them.
> Derived from Superpowers, CE, CC10X, Matt Pocock, and ECC — see [compare.md](compare.md) for the source analysis.

---

## Overview

The framework has one entry point (`/letsgo`) that routes to three workflows:

```
/letsgo (router)
    |
    Classify: type (BUILD / FIX / EXPLORE) + tier (lightweight / standard / deep)
    |
    +-- BUILD   --> /brainstorm --> /plan --> execute --> verify --> review --> retro
    +-- FIX     --> /fix (triage --> investigate --> TDD fix --> verify --> review --> retro)
    +-- EXPLORE --> /explore (scope --> research --> analyze --> retro --> transition?)
```

**Design choices:**
- `/letsgo` is **active but confirming** — infers type from the description, confirms with one question. Avoids Superpowers' passive routing (misses) and CC10X's fully automatic routing (misroutes).
- Each workflow is a **separate skill**. `/letsgo` doesn't handle the work, just classifies and routes.
- Users can bypass the router: `/brainstorm`, `/fix`, `/explore` are directly invocable.
- All three workflows share agents (`code-explorer`, `docs-explorer`) and infrastructure (TDD, review, retro) but combine them differently.

---

## /letsgo — Router

**~60 lines.** Classification + routing only.

### What it does

1. Receives the user's description
2. Checks for existing work (`.docs/work/*/brainstorm.md`, `.docs/work/*/retro.md`)
3. Classifies type + tier (infer from description, confirm with user)
4. Routes to the correct workflow skill with: description, type, tier, any existing work found

### What it doesn't do

- Research (agents are dispatched by workflow skills, not the router)
- Design dialogue (that's `/brainstorm`)
- Any actual work

### Type Classification

Inferred from signal words, then confirmed:

| Signals | Type |
|---------|------|
| "add", "create", "build", "implement", "new", "feature", "support", "enable", "refactor", "migrate" | BUILD |
| "fix", "bug", "broken", "error", "500", "failing", "crash", "doesn't work", "regression", "flaky" | FIX |
| "why", "how does", "what would it take", "audit", "compare", "investigate", "understand", "impact", "explore", "research" | EXPLORE |

Ambiguous cases get one confirmation question:

> Based on your description, this looks like a **[BUILD]** task — new functionality to add.
> Scope: **[standard]** — multi-file, a few decisions to make.
>
> Does that match? Or is this more of a:
> (a) Fix — something is broken that needs debugging
> (b) Exploration — you need to understand something before deciding what to do

### Tier Classification

Same as current `/letsgo` Phase 2, applied across all three types:

| Tier | Criteria |
|------|----------|
| **Lightweight** | Single file/function, low ambiguity (~30 min) |
| **Standard** | Multi-file, some decisions (hours) |
| **Deep** | Multi-subsystem, high ambiguity (days) |

### The 2D Matrix

| | Lightweight | Standard | Deep |
|---|---|---|---|
| **BUILD** | Abbreviated brainstorm, inline execution, TDD | Full brainstorm, plan, sequential subagents, TDD | Full brainstorm + research, plan + risk, subagents, TDD |
| **FIX** | Triage, direct TDD fix | Triage, investigate (root cause + variants), TDD fix | Triage, investigate, blast radius, plan if architectural, TDD fix |
| **EXPLORE** | Quick lookup, direct answer | Research agents, synthesize, report | Parallel research, structured report, retro to .docs/work/<slug>/ |

---

## Workflow 1: BUILD

**Covers:** new features, enhancements, refactors, migrations — anything that produces new or changed code as the primary output.

**Source blend:** CE's scope routing + Superpowers' hard brainstorm gate + two-stage review per task + CE's conditional reviewer personas + CE's compound knowledge capture.

### Phases

```
/brainstorm ---- HARD GATE, never skipped
    |
    +-- lightweight --> abbreviated brainstorm (no research agents dispatched)
    +-- standard ----> full brainstorm (code-explorer + docs-explorer)
    +-- deep --------> full brainstorm + external research + risk section
    |
    v
/plan ---- depth matches brainstorm tier
    |
    +-- lightweight --> task list only, no plan file, inline execution
    +-- standard ----> plan file with behavioral contracts, worktree
    +-- deep --------> plan file + risk assessment + durable decisions, worktree
    |
    v
EXECUTE ---- TDD mandatory at all tiers
    |
    +-- lightweight --> inline (same session, no subagent)
    +-- standard ----> sequential subagent per task
    +-- deep --------> sequential subagent per task (parallel across features via worktrees)
    |
    |   Per task:  Implement (RED --> GREEN --> REFACTOR --> commit)
    |                  |
    |              Spec Review (matches plan?)
    |                  |
    |              Quality Review (well-built?)
    |                  |
    |              pass --> next task  /  fail --> re-implement (max 3)
    |
    v
FINAL VERIFICATION
    |
    v
REVIEW ---- conditional reviewer personas
    |
    +-- always: correctness + testing + maintainability
    +-- conditional: security (auth changes), performance (DB/queries),
        API-contract (routes), data-migrations (schema changes)
    |
    v
RETRO ---- technical knowledge + process reflection to .docs/work/<slug>/retro.md
```

### /brainstorm Skill

The current `/letsgo` phases 1-6, extracted as its own skill. No changes to the brainstorming logic — it just lives in `skills/brainstorm/` instead of being embedded in the router.

Files:
- `skills/brainstorm/SKILL.md` (~150 lines, phases 1-6 from current /letsgo)
- `skills/brainstorm/references/section-guide.md` (moves from letsgo/references/)
- `skills/brainstorm/references/brainstorm-template.md` (moves from letsgo/references/)
- `skills/brainstorm/references/failure-modes.md` (moves from letsgo/references/)

---

## Workflow 2: FIX

**Covers:** bugs, errors, regressions, performance issues, flaky tests — anything where existing behavior is wrong.

**Source blend:** CE's triage classification + CC10X's rigorous 12-step investigation (simplified) + Superpowers' TDD + CC10X's variant scan and blast radius.

### Phases

```
TRIAGE ---- classify before touching code
    |
    +-- not a bug ----------> explain to user, done
    +-- environmental -------> document env fix, done
    +-- cannot reproduce ----> gather more info, ask user
    +-- confirmed bug -------> continue
    |
    v
INVESTIGATE ---- depth depends on clarity and tier
    |
    +-- obvious (lightweight) --> skip to TDD FIX
    |
    +-- unclear (standard/deep)
          |
          1. Understand symptoms (reproduce, isolate)
          2. Git history (what changed recently?)
          3. Form 2-3 hypotheses ranked by likelihood
          4. Test hypotheses (read code, add logging, trace)
          5. Variant scan (does this bug exist under other inputs?)
          |   Check: locale, config, roles, platform, data shape,
          |   concurrency, edge cases
          6. Blast radius scan (does the same pattern exist elsewhere?)
             Same-file + adjacent files + similar modules
    |
    v
TDD FIX ---- always test-first
    |
    RED:   regression test reproducing the bug (must cover >=1 variant)
    GREEN: minimal fix to pass
    REFACTOR: clean up
    |
    3 failed fixes --> STOP, treat as architectural problem --> transition to BUILD
    |
    v
VERIFICATION ---- per-task + final (same as BUILD)
    |
    v
REVIEW ---- lightweight (single reviewer, focused on the fix)
    |
    v
RETRO ---- root cause + fix + what didn't work + process reflection
```

### Key Differences from BUILD

- No brainstorm artifact — the investigation IS the analysis
- Triage before any work — determines if it's even a bug
- Variant scan + blast radius are FIX-specific (BUILD doesn't need them)
- 3-fix circuit breaker — escalates to BUILD if the fix keeps failing
- Retro captures negative knowledge (what didn't work) alongside process reflection

---

## Workflow 3: EXPLORE

**Covers:** research, audits, profiling, "what would it take to...", impact analysis, understanding how something works, comparing approaches — anything where the output is understanding, not code.

**Source blend:** Custom. Neither Superpowers nor CE has a dedicated research workflow. This fills the gap.

### Phases

```
SCOPE THE QUESTION ---- what are we trying to learn?
    |
    +-- targeted (single question, bounded)
    +-- broad (survey, audit, comparison)
    |
    v
RESEARCH ---- parallel agents based on scope
    |
    +-- code-explorer ---- source code, git history, patterns
    +-- docs-explorer ---- existing decisions, ADRs, external docs
    +-- (broad only) additional targeted research
    |
    v
ANALYZE ---- synthesize findings
    |
    +-- targeted --> direct answer with evidence
    +-- broad ----> structured report:
          Current state, Findings, Options + trade-offs,
          Recommendation (if asked), Unknowns
    |
    v
RETRO ---- persist findings to .docs/work/<slug>/retro.md (with YAML tags for discoverability)
    |
    v
TRANSITION (optional) ---- user decides
    |
    +-- "Let's build it"     --> BUILD with research as input
    +-- "Fix what we found"  --> FIX with findings
    +-- "Just needed to know" --> done
```

### Key Differences from BUILD and FIX

- Uses `brainstorm.md` to scope the question, `retro.md` for findings — no `plan.md`
- Research agents are the main event, not a support phase
- Output is a research report (in `retro.md`), not an implementation
- Clean transition points to BUILD or FIX if the user decides to act

---

## Shared Infrastructure

### Execution (inside BUILD and FIX)

Three modes based on tier:

| Mode | When | How |
|------|------|-----|
| **Inline** | Lightweight tier | Same session, no subagent. Main agent implements directly. TDD still mandatory. |
| **Sequential subagents** | Standard tier | Fresh subagent per task. Gets: task description + durable decisions + relevant file paths. Returns: DONE / BLOCKED / NEEDS_CONTEXT. |
| **Sequential subagents + worktree** | Deep tier | Same as standard but runs in a worktree. Durable decisions from plan passed to every subagent. |

Tasks within a single plan are **always sequential** (prevents context pollution and merge conflicts within the same branch). Parallelism happens at the feature level via worktrees.

#### What the implementer subagent receives

- The specific task description with behavioral contract
- Durable decisions that apply to ALL tasks
- Relevant file paths and context
- Rules: TDD mandatory, don't modify files outside task scope, return NEEDS_CONTEXT if something is missing

The subagent does NOT see: full plan, previous task outputs, conversation history.

### Verification (inside BUILD and FIX)

Two checkpoints:

#### Checkpoint 1: Per-Task (after each task completes)

Lightweight, runs inline in the implementing subagent:

1. Tests pass? (the specific tests written/changed)
2. Build clean? (no compile/type errors)
3. No stubs? (scan for TODO, FIXME, placeholder, empty returns)
4. Matches plan unit? (does this task do what the plan said?)

All pass --> DONE, next task. Any fail --> fix and re-verify (max 3 --> BLOCKED).

#### Checkpoint 2: Final Verification (after ALL tasks, before claiming done)

Heavyweight, runs in the main session with fresh eyes:

1. **IDENTIFY** — read brainstorm + plan, list every promised behavior
2. **RUN** — execute full test suite (not just your tests — ALL tests)
3. **CHECK** — structural integrity:
   - Stub scan: TODO, FIXME, placeholder, empty bodies, suspiciously short implementations
   - Wiring check: is the new code reachable? Route registered? Component rendered? Handler mounted?
   - Build check: clean compile, no new warnings
4. **VERIFY** — for each promised behavior, is there a test that proves it?
5. **CLAIM** — only now say "done" (if any step failed: fix, re-run from step 2; max 2 full cycles --> surface to user)

Anti-rationalization rules: "Tests pass" requires RUN evidence, not assumption. "Should work" is not evidence. "Verified earlier" requires re-verification. "Minor change" still gets verified.

### Review (inside BUILD and FIX)

**BUILD uses conditional reviewer personas:**
- Always: correctness + testing + maintainability
- Conditional: security (auth changes), performance (DB/queries), API-contract (routes), data-migrations (schema)

**FIX uses lightweight single review** focused on the fix itself.

### Retro (last phase of all workflows)

Not optional. Last phase of BUILD, FIX, and EXPLORE. Combines CE's compound (technical knowledge capture) with process reflection in ONE file: `.docs/work/<slug>/retro.md`. Like CE, the primary output is one file — we just co-locate it with the brainstorm and plan that produced it.

#### YAML Frontmatter (all retros)

```yaml
---
title: Payment Webhook Handling
date_completed: 2025-04-12
source_brainstorm: 250410-payment-webhooks    # omit for adhoc retros
type: build                          # build | fix | explore | adhoc
outcome: success                     # success | partial | failed
module: payments
tags: [payments, webhooks, idempotency, stripe]
---
```

Every retro has `module` and `tags` for grep-first retrieval. Agents discover past knowledge by grepping across `.docs/work/*/retro.md`.

#### BUILD Retro — Example

```markdown
---
title: Payment Webhook Handling
date_completed: 2025-04-12
source_brainstorm: 250410-payment-webhooks
type: build
outcome: success
module: payments
tags: [payments, webhooks, idempotency, stripe]
---

## Result
Shipped as planned. 5 implementation units, all GREEN.

## What We Learned
- Webhook handlers must be idempotent — Stripe sends duplicate events
  under network instability. Used event ID as deduplication key.
- Existing payment infrastructure in `payments/` was extensible —
  didn't need new module, extended existing webhook base class.

## What Went Well
- Plan's vertical slicing worked — each unit independently testable
- TDD caught duplicate webhook delivery edge case early (unit 3)
- code-explorer found existing webhook infrastructure, saved design time

## What Went Wrong
- [x] Stale or bad research files
  - `docs-explorer` surfaced a prior research about the payment provider
    that referenced the v2 API. Provider had migrated to v3 — spent 40 min
    debugging signature verification before realizing the doc was stale.

## Action Items
- [x] Update payment-provider research retro with v3 info  →  target: docs
- [ ] Add freshness dates to research retros about external APIs  →  target: team-process

## Prevention
- When integrating external APIs, verify SDK/API version matches the
  current provider docs before implementing. Don't trust cached research.
```

#### FIX Retro — Example

```markdown
---
title: Webhook Callback Returns 500 on Duplicate Events
date_completed: 2025-04-15
source_brainstorm: 250415-webhook-500-fix
type: fix
outcome: success
module: payments
tags: [payments, webhooks, 500-error, idempotency, duplicate-events]
severity: high
root_cause: missing_validation
---

## Result
Fixed. Regression test added. No blast radius found.

## Root Cause
Webhook handler processed events without checking for duplicates. Stripe
retries on timeout, causing the same event to be processed twice. Second
processing hit a unique constraint → 500.

## What Didn't Work
- Adding a database index (wrong bottleneck — issue was missing dedup logic,
  not query performance)
- Catching the unique constraint exception (masked the real problem — handler
  should never reach the insert twice)

## Fix
Added idempotency check as first step: query by event ID, return 200 if
already processed. Wrapped in transaction to prevent race conditions.

## What Went Well
- TDD caught edge case: concurrent duplicate events (race condition)
- Blast radius scan found no other handlers with same pattern

## What Went Wrong
- [x] Poor test coverage (pre-existing)
  - No test existed for duplicate webhook delivery. Original implementation
    assumed Stripe sends each event exactly once.

## Action Items
- [ ] Add idempotency tests to all existing webhook handlers  →  target: codebase
- [ ] Add "duplicate delivery" to webhook handler checklist  →  target: docs

## Prevention
Every webhook handler must check for duplicate events before processing.
Use the event ID as idempotency key. Test with duplicate delivery scenario.
```

#### EXPLORE Retro — Example

```markdown
---
title: Stripe vs Adyen — Payment Provider Comparison
date_completed: 2025-04-10
source_brainstorm: 250408-payment-provider-comparison
type: explore
outcome: success
module: payments
tags: [payments, stripe, adyen, provider-comparison, evaluation]
---

## Question
Which payment provider should we use for the EU market expansion?

## Findings
- Stripe: better DX, broader API, higher fees in EU (2.9% + €0.25)
- Adyen: lower EU fees (interchange++), more complex integration, better
  local payment methods (iDEAL, Bancontact, SEPA)
- Both support webhooks, recurring billing, and PCI DSS Level 1

## Sources
- Stripe pricing page (2025-04-09)
- Adyen pricing calculator (2025-04-09)
- Internal: existing Stripe integration in `payments/` module

## Recommendation
Adyen for EU market, keep Stripe for US. Multi-provider abstraction
layer needed — see approach D1 in brainstorm.

## Open Questions
- Does Adyen support our current webhook signing scheme?
- What's the migration path for existing EU subscribers on Stripe?
```

#### Root Cause Categories

When something goes wrong, categorize it. These categories exist so patterns can be detected over time:

| Category | What it means | Example |
|----------|---------------|---------|
| **Poor user description** | Ambiguous, incomplete, or misleading request | "Make payments work" without specifying which flow |
| **Incorrect scope/tier** | Router misclassified lightweight/standard/deep | Deep feature classified as lightweight, rushed |
| **Poor brainstorm decisions** | Wrong approach chosen, missed constraints | Chose REST when GraphQL was needed for the consumers |
| **Stale or bad research** | Research docs contain outdated information | v2 API reference when provider migrated to v3 |
| **Poor CLAUDE.md** | Project instructions missing or misleading | No mention of required auth middleware |
| **Poor code patterns** | Codebase structure caused confusion or bugs | Inconsistent error handling across modules |
| **Stale or bad docs** | Other docs (not research) are outdated | MAP.md doesn't reflect recent restructure |
| **Poor test coverage** | Pre-existing gap in tests | No test for duplicate webhook delivery |
| **Poor enforcement** | Verification didn't catch a problem | Stub scan missed a placeholder |
| **Poor skill behavior** | agentic-kit bug → create GitHub issue | Brainstorm skipped research phase |

#### How Retros Work

1. After execution + review completes, the framework asks the user: "How did this go?"
2. User provides feedback (can be brief — "went great" or detailed)
3. Framework fills the retro from user feedback + its own observations (verification failures, blocked tasks, re-implementations, what was learned)
4. User confirms or edits the retro
5. Retro is written to `.docs/work/<slug>/retro.md`

#### The Feedback Loop

Retros accumulate over time. The team scans them to find patterns:

- "Most failures from poor CLAUDE.md" → invest in project instructions
- "Most failures from stale research" → add freshness dates to external-API research
- "Most failures from incorrect scope" → improve router classification heuristics
- "Most failures from poor skill behavior" → create GitHub issue on agentic-kit
- "Most successes mention TDD catching edge cases" → TDD discipline is working, keep it

**Key principle:** Bad user input or a bad AI result doesn't trigger framework changes unilaterally. The team reviews retros and decides what needs fixing and where the fix belongs. This prevents knee-jerk over-engineering — not every failure means the framework is broken.

#### Surfacing Past Knowledge

Agents discover past knowledge by grepping YAML frontmatter across retros:

```bash
grep -rl "module: payments" .docs/work/*/retro.md    # everything about payments
grep -rl "type: fix" .docs/work/*/retro.md            # all past bug fixes
grep -rl "tags:.*stripe" .docs/work/*/retro.md        # anything tagged stripe
```

The `docs-explorer` agent uses this pattern: extract keywords → grep frontmatter → read frontmatter of matches → score relevance → full-read top hits. CLAUDE.md instructs agents to check `.docs/work/` before designing new approaches.

#### Staleness

Opportunistic. When `docs-explorer` finds a retro during research, it checks whether referenced files have changed significantly since the retro was written. If so, it flags:

> "Prior retro may contain stale info — [file] has been heavily modified since this was documented. Verify before relying on it."

---

## Git Worktrees

Worktree isolation is orthogonal to workflow type. All three workflows run the same inside or outside a worktree.

### Single task

Use `claude -w <name>`. Claude Code handles the worktree lifecycle. The framework runs inside it.

### Batch (multiple independent tasks)

From a single session on main, dispatch parallel worktree agents:

```
/batch ---- list of tasks
    |
    v
ANALYZE DEPENDENCIES
    |
    +-- independent tasks --> parallel worktree subagents
    +-- dependent tasks ----> sequenced (wait for dependency to complete)
    |
    v
DISPATCH (one subagent per worktree, each runs BUILD or FIX)
    |
    v
RESULTS (each returns branch + summary)
    |
    v
REVIEW + MERGE
```

### Worktree infrastructure (via SessionStart hook)

- Auto-copy `.env*` files into worktree (CE pattern)
- Auto-detect and run project setup (`npm install`, `go mod download`, etc.)
- Baseline test verification before any changes

---

## Skill Inventory

### User-invocable skills

| Skill | Purpose | Status |
|-------|---------|--------|
| `/letsgo` | Router — classifies type + tier, routes to workflow | Refactor needed (extract brainstorm) |
| `/brainstorm` | BUILD workflow entry — design & brainstorm | Extract from current /letsgo |
| `/plan` | Planning — turns brainstorm into executable tasks | Not built |
| `/fix` | FIX workflow — triage, investigate, TDD fix | Not built |
| `/explore` | EXPLORE workflow — research, analyze, report | Not built |
| `/batch` | Orchestrate multiple tasks across worktrees | Not built |

### Internal skills (not user-invocable)

| Skill | Purpose | Status |
|-------|---------|--------|
| TDD | RED --> GREEN --> REFACTOR discipline | Not built |
| Verification | Per-task + final verification checkpoints | Not built |
| Retro | Post-work capture: CE compound + process reflection in one file | Not built |

### Agents

| Agent | Purpose | Status |
|-------|---------|--------|
| `code-explorer` | Scans source code, patterns, git history | Built |
| `docs-explorer` | Scans .docs/, project docs, external sources | Built |
| `brainstorm-reviewer` | Reviews brainstorm artifacts for quality | Built |

---

## What's Next

Build order (each depends on the previous):

1. **Refactor /letsgo** — extract brainstorm into `/brainstorm`, make `/letsgo` the router
2. **Build /plan** — spec in [skill-specs.md](skill-specs.md) section 2
3. **Build TDD** (internal) — spec in [skill-specs.md](skill-specs.md) section 3
4. **Build /fix** — triage + investigation + TDD integration
5. **Build /explore** — research + report workflow
6. **Build verification** (internal) — per-task + final checkpoints
7. **Build retro** (internal) — CE compound + process reflection in one file
8. **Build review** (internal) — conditional reviewer personas
9. **Build /batch** — worktree orchestration
10. **Write CLAUDE.md** — requirements in [claude-md-requirements.md](claude-md-requirements.md)
