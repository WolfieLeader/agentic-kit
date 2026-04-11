---
title: Agentic Kit Framework
date: 2026-04-11
status: draft
version: 0.1
---

# Agentic Kit Framework

A meta-framework for AI-assisted software development. One entry point, three workflows, knowledge that compounds over time.

**Core sources:** Compound Engineering (lifecycle, agents, artifacts), Superpowers (discipline, gates, TDD, verification), CC10X (confidence scoring, circuit breakers), Matt Pocock (TDD philosophy, deep modules, behavioral testing), ECC (agent design, file budgets, grep-first search).

**Design principles:**
- **Context window is gold — use the disk.** Every phase that produces output writes to disk. Handoff between phases is via persisted artifacts. Skills are session-independent — you can `/compact`, start a new conversation, or come back days later.
- **Trust the implementing agent.** Blueprints describe what to build, not how to type it.
- **Right-size ceremony to scope.** Lightweight changes get lightweight process. But every change gets something.

## Architecture

```
User input
  -> /agentic router forms assumption about the task
  -> Dispatches both explorers with directed context (sonnet 4.6, in parallel)
  -> Explorers return findings (stay in context, not persisted)
  -> Router: informed questioning + classify type + tier
  -> Dispatch to pipeline:

light BUILD/FIX:     (trace if FIX) -> craft -> polish -> retro
std/deep BUILD/FIX:  (trace if FIX) -> sketch -> blueprint -> craft -> polish -> retro
EXPLORE:             synthesize explorer findings -> persist research if external

Post-cycle (manual):
  /propose  -> aggregate retros -> draft change proposals
  /evolve   -> execute accepted proposals -> .docs/CHANGELOG.md
```

Pipeline ends at retro. Git workflow (commit, PR, merge) is the user's choice.

## Skills

### User-Invokable

| Skill | Purpose |
|---|---|
| `/agentic` | Universal entry point. Routes to BUILD, FIX, or EXPLORE. |
| `/propose` | Aggregate retros, identify patterns, draft change proposals. |
| `/evolve` | Execute accepted proposals, log to CHANGELOG.md. |

### Internal

| Skill | Purpose |
|---|---|
| `trace` | FIX gate. Reproduce, classify, assess severity, route. |
| `sketch` | Capture what/why via modified grill-me. Two modes: BUILD and FIX. |
| `blueprint` | Define how. Implementation units, durable decisions, test scenarios. |
| `craft` | Implement with TDD (guardrails). Inline (light) or subagent-per-task (std/deep). |
| `polish` | Single step, scales by tier. Evidence-based verification + conditional multi-persona review. |
| `retro` | Per-task reflection. Automatic at end of every BUILD/FIX. Living document during session. |

## Agents

### Explorer Agents (sonnet 4.6)

Dispatched by the router once it has formed an assumption about the task (may require 1-2 clarifying questions first). Both dispatched in parallel with directed context. Findings stay in session context, not persisted to disk.

**code-explorer:**
- First stop: MAP.md, then tree/ls, source code, git history
- Finds: relevant files, existing patterns, technical constraints, dependencies
- Scope: codebase only, excludes `.docs/`
- Budget: max 15 files per investigation
- Search procedure: grep-first narrowing, not broad reads

**docs-explorer:**
- Searches `.docs/` via YAML frontmatter grep (`module:`, `tags:`, `type:`)
- Finds: prior retros, sketches, blueprints, research on the topic
- Search order: `.docs/research/` (curated) first, then `.docs/work/*/retro.md` (work-specific)
- External escalation: if knowledge gap found on third-party topic -> Context7 MCP / official docs / GitHub
- Persists external research to `.docs/research/<topic>.md`
- Attributes findings to source (codebase find vs model knowledge vs external research)

**Both explorers return structured output:**
```
## Key Findings
...
## Relevant Files
...
## Open Questions
...
```

### Blueprint Review Agents (sonnet 4.6)

Dispatched during blueprint review gate for std/deep tiers. Validate the blueprint before implementation begins. Inspired by CE's 8 document-review agents (design-lens, security-lens, scope-guardian, coherence, feasibility, product-lens, adversarial).

| Agent | Focus |
|---|---|
| `coherence-reviewer` | Internal consistency — contradictions between sections, terminology drift, structural issues |
| `feasibility-reviewer` | Will the proposed approach survive contact with reality? Architecture conflicts, implementability |
| `scope-guardian` | Scope alignment — challenges unnecessary abstractions, premature frameworks, unjustified complexity |

**Blueprint review rules:**
- Same confidence gating as code review (suppress below 0.60, P0 at 0.50+)
- Findings feed back into blueprint revision (max 3 retries before escalating to user)
- Stack-agnostic: projects can add domain-specific blueprint reviewers (security-lens, product-lens, etc.)

### Code Review Agents (sonnet 4.6)

Dispatched during polish for std/deep tiers only. Read-only, return structured findings.

**Always-on:**

| Agent | Focus |
|---|---|
| `correctness-reviewer` | Logic errors, edge cases, state bugs, error propagation |
| `testing-reviewer` | Coverage gaps, weak assertions, brittle tests |
| `maintainability-reviewer` | Coupling, complexity, naming, dead code |

**Conditional (based on what was touched):**

| Agent | Trigger |
|---|---|
| `security-reviewer` | Auth, permissions, user input, public endpoints |
| `performance-reviewer` | DB queries, caching, async, data transforms |
| `api-contract-reviewer` | Routes, schemas, type signatures, versioning |
| `data-migrations-reviewer` | Schema changes, backfills, migrations |

**Code review rules:**
- Confidence-gated: suppress findings below 0.60. P0 findings at 0.50+ survive.
- Severity scale: P0 (critical) -> P1 (high) -> P2 (moderate) -> P3 (low)
- Zero-finding halt: if nothing found, say so and stop. No inventing issues.
- Stack-agnostic: no language-specific reviewers in the framework. Projects add their own (CE has 53 agents including language-specific reviewers like Rails, Python, TypeScript — those are project-level, not framework-level).

### Craft Agents (opus 4.6)

Dispatched during craft for std/deep tiers. Fresh subagent per implementation unit.

**Receives:** blueprint file path, specific unit (goal, files, approach, test scenarios), explorer findings if relevant.
**Returns:** DONE / BLOCKED / NEEDS_CONTEXT.
**Discipline:** TDD (guardrails) mandatory, self-review before reporting done.

## Pipelines

### Type Classification

Inferred from user input, confirmed by router.

- **BUILD:** "add", "create", "build", "implement", "new", "feature", "refactor", "migrate"
- **FIX:** "fix", "bug", "broken", "error", "failing", "crash", "regression", "flaky"
- **EXPLORE:** "why", "how does", "what would it take", "audit", "compare", "investigate", "understand", "research"

### Tier Classification

Determined after explorer findings are available.

- **Lightweight:** single file/function, low ambiguity
- **Standard:** multi-file, some decisions
- **Deep:** multi-subsystem, high ambiguity

---

## Phase Details

### /agentic (Router)

The only user-facing entry point for work. Three jobs:

1. **Form assumption** about the task from user input (may ask 1-2 clarifying questions if input is too vague to direct explorers)
2. **Dispatch explorers** with directed context (both in parallel, sonnet 4.6)
3. **Classify** type (BUILD/FIX/EXPLORE) and tier (light/std/deep) using explorer findings + user input
4. **Ensure clarity** via dynamic questioning scaled to user's input clarity

**Dynamic questioning depth:**

| User clarity | Router behavior |
|---|---|
| Both intent and scope clear | Classify, confirm, dispatch. 1-2 exchanges. |
| Intent clear, scope unclear | 2-3 scoping questions, then dispatch. |
| Intent unclear | Probe intent first, then scope. 3-5 exchanges. |
| Both unclear | Full grill-me mode until dispatch-ready. 5+ exchanges. |

**Exit condition:** The router stops questioning when it can write a clear one-paragraph dispatch summary.

**Resume:** Router checks `.docs/work/` for existing artifacts. If a matching work folder exists, the router tells the user what's already there and provides a brief preview: "I found existing work for [slug] — here's what's done: [summary]. Want to continue from here or start fresh?" User decides.

**Shortcuts:** If the user explicitly states urgency or provides a clear spec, the router fast-tracks. It doesn't force questioning when clarity already exists.

**Gotchas:**
- Classify after understanding, not before — rushed routing leads to wrong tier, wrong pipeline, wasted work
- Question lightweight classification — most tasks touching 2+ files or 2+ concerns are standard
- Dispatch explorers with specific search terms, not "look around"

### Trace (FIX only)

Gate that determines if the issue is a real bug. No artifact produced — findings (reproduction result, hypothesis, severity) stay in session context and flow forward to sketch (std/deep) or directly to craft (lightweight).

1. **Reproduce** — confirm the issue exists (test-based / browser-based / manual)
2. **Classify** — real bug? environmental? user error? works as designed?
3. **Quick hypothesis** — directional, not committed ("looks like a race condition in the queue consumer")
4. **Assess severity** — blocking / degraded / cosmetic
5. **Route:**
   - Not a bug -> done
   - Lightweight bug -> craft (trace context flows in-session)
   - Std/deep bug -> sketch (trace context informs FIX mode sections)
6. **Upgrade heuristic** — if trace reveals the fix touches 3+ files or 2+ subsystems, or root cause is unclear after initial investigation, propose upgrade to std/deep. User confirms.

**Gotchas:**
- Reproduce before hypothesizing — confirm the bug exists before explaining why
- Distinguish symptom from cause — "the API returns 500" is a symptom, not a root cause

### Sketch (BUILD and FIX, std/deep only)

Captures **what** and **why**. One skill, two modes. Produces `sketch.md`.

**Modified grill-me pattern:**
- Ask up to ~5 questions per round
- Write checkpoint summary: "Here's what I understand so far: [summary]. Any corrections or additions?"
- User corrects/confirms/adds
- Next round if needed, or proceed when mutual understanding is reached
- Never 50+ sequential questions. Always checkpoint.

**BUILD mode sections:**
- Problem/opportunity being addressed
- Why now, what's the motivation
- What exists today (from explorer findings)
- Affected systems and modules
- Approaches considered (2-3, all shown THEN recommend — anti-anchoring hard rule)
- Constraints and non-goals
- Success criteria
- Research context (prior retros, existing patterns, relevant files found by explorers)
- Blocking vs deferred open questions

**FIX mode sections:**
- Symptoms observed
- Reproduction steps (from trace)
- Root cause hypothesis (from trace, refined)
- Blast radius — what systems are affected
- Affected systems and modules
- Constraints
- Research context (prior retros on this module, similar past bugs)
- Blocking vs deferred open questions

**Gotchas:**
- Show all approaches before recommending one — anchoring on the first idea skips better alternatives
- Separate blocking questions from deferred ones — blocking questions must resolve before blueprint

### Blueprint (BUILD and FIX, std/deep only)

Defines **how**. Produces `blueprint.md`. Behavioral goals, not code.

**Implementation units:** vertical slices, each testable end-to-end.

Per unit:
- Goal (behavioral, what it should do)
- Dependencies (which units must complete first — DAG rule: no circular deps)
- Independent (yes/no — can this unit be worked in parallel with other independent units? Drives craft dispatch.)
- Confidence (GREEN / YELLOW / RED)
- Affected systems
- Approach (behavioral description, NOT code)
- Test scenarios (happy path, edge cases, error paths)
- Verification criteria

**Durable decisions:** top-level section for decisions that cross implementation units (e.g., API routes, database schema, shared types, auth boundaries, service boundaries, cross-platform impacts).

**Blueprint review gate (4 checks, fail-closed):**
1. Dependency coherence (inline) — no circular deps, no missing deps
2. Completeness (blueprint review agents) — `coherence-reviewer`, `feasibility-reviewer`, `scope-guardian` (see Blueprint Review Agents)
3. No placeholders (inline) — hard ban on TBD, TODO, etc.
4. Testability (inline) — every unit has test scenarios

Max 3 review retries before escalating to user.

**What blueprints do NOT contain:** implementation code, exact shell commands, file-level diffs. Blueprints describe what to build, not how to type it. Trust the crafting agent.

**Gotchas:**
- Describe behavior, not implementation — "validates email format" not `if (!email.match(/regex/))`
- Flag unit independence explicitly — units with shared state or sequential deps need dispatch guidance

### Craft

Implements with TDD (guardrails). Two modes based on tier.

**Lightweight (inline, same session):**
- No subagent. Main session implements directly.
- Works from router context (explorer findings + user input).
- Guardrails cycle: RED -> verify fail -> GREEN -> verify pass -> REFACTOR -> commit.
- No per-task review loop. Polish at the end covers it.

**Standard/Deep (dispatch based on task structure):**
- Blueprint provides implementation units with explicit independence flags.
- **Dispatch assessment** — check blueprint before dispatching:
  - Units marked independent, disjoint files, no shared state → parallel subagents (opus 4.6)
  - Units with sequential dependencies, shared state, or overlapping files → sequential inline execution
  - Default to sequential. Parallel is the optimization, not the default.
  - Subagents carry per-dispatch context overhead — prefer inline when units are coupled.
- **Parallel dispatch (independent units):**
  - Fresh opus 4.6 subagent per unit with: blueprint file, unit details, guardrails discipline.
  - One file, one owner — no two subagents touch the same file.
- **Sequential dispatch (dependent units):**
  - Inline execution in the main session, unit by unit.
  - Previous unit's output informs the next — no context loss from subagent boundaries.
- Per-unit review loop (lighter than full polish):
  - Tests pass for this unit
  - No stubs/placeholders
  - Matches the blueprint's implementation unit goal
  - Quick correctness scan
- Unit returns: DONE / BLOCKED / NEEDS_CONTEXT.
  - DONE → next unit
  - BLOCKED → surface to user
  - NEEDS_CONTEXT → provide and retry
- Incremental commits at unit boundaries.
- **Progress tracker:** Restate unit checklist at each unit boundary to counter attention drift in long contexts. `[x] Unit 1 done. [x] Unit 2 done. [ ] Unit 3 — current. [ ] Unit 4.`
- **Context health:** Between units, proactively compact if context is large. Do not wait for autocompact — with 1M context windows, autocompact triggers at ~835K tokens, but degradation starts much earlier. After compaction, restate the plan and unit checklist.

**System-wide test check (from CE, for std/deep):**
- What fires when this runs? (callbacks, middleware, observers)
- Do tests exercise the real chain? (not just mocked isolation)
- Can failure leave orphaned state?

**Gotchas:**
- Test behavior through public interfaces — tests that assert implementation details break on every refactor
- Verify the test fails for the right reason — a test that fails for the wrong reason proves nothing
- Write one test, then one implementation — not all tests then all code

### Guardrails (TDD) — The Iron Law

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

Non-negotiable at ALL tiers.

**The cycle:**
```
RED:      Write one failing test (behavioral, public interface, one behavior)
VERIFY:   Confirm it fails for the expected reason (MANDATORY)
GREEN:    Write minimum code to pass (simplest possible)
VERIFY:   Confirm it passes, no other tests broken (MANDATORY)
REFACTOR: Clean up, remove duplication, improve names (keep green)
COMMIT:   At phase transitions
```

**Principles:**
- Test behavior through public interfaces, not implementation details
- Vertical slices: one test -> one implementation (not all tests then all code)
- Boundary-only mocking: external APIs, DBs, caches, time, filesystem. Real code internally.
- Refactor only when GREEN
- Code written before test MUST be deleted entirely
- 80%+ coverage target (not 100%)
- Tests should survive internal refactors unchanged

**3-fix circuit breaker (universal, all tiers):**
- 3 failed fix attempts -> STOP
- Question the architecture, not the symptom
- Discuss with user before attempting more fixes
- This is NOT a failed hypothesis — this is a wrong architecture

**Per-agent iteration cap:**
- Separate from the 3-fix breaker — catches runaway agents that hit different errors each time
- No default number. Projects set their own cap via evolve when retros show runaway sessions.
- When hit: agent pauses with status report to user, does not silently continue

**12 rationalization red flags:**
"I'll write test after", "too simple to test", "just manually verify", "obvious test", "need to see implementation first", "get it working then test", "just a refactor", "existing tests cover this", "tests in follow-up", "prototype/POC", "too hard to write", "watch mode shows passing"

### Polish

Single step, scales by tier.

**Lightweight:**
- Tests pass (run command, read output, evidence before claims)
- Build clean
- No stubs/placeholders (hard ban: TBD, TODO, etc.)
- Quick scan of the diff — does it match what was asked?
- One pass, inline, no subagent

**Standard/Deep — Verification (structural, automated):**
- Full test suite passes
- Build clean
- Stub/placeholder scan (hard ban)
- Wiring check — are new components actually connected?
- Sketch/blueprint compliance — does the implementation match what was specified?

**Standard/Deep — Review (multi-persona, subagent):**
- Dispatch always-on + conditional code review agents (see Agents section)
- Confidence-gated findings
- Severity-ordered results
- Findings acted on by priority:
  - P0 (critical): fix immediately
  - P1 (high): fix before proceeding
  - P2 (moderate): fix if straightforward
  - P3 (low): user's discretion

**Receiving review feedback:**
- Verify each finding against actual code before acting
- Push back if technically wrong (with reasoning)
- Clarify ALL unclear items before implementing any
- No performative agreement ("You're absolutely right!", "Great point!")
- No sycophancy. Technical correctness over social comfort.

**Iron law of verification (from Superpowers):**
```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```
Run the command. Read the output. Count failures. THEN claim the result. No "should pass", no "looks correct". Only evidence.

**Gotchas:**
- Run verification commands and read output — "tests should pass" is not evidence
- Check wiring — new components that aren't connected to anything pass all tests and do nothing
- Verify against sketch/blueprint, not just "does it compile"

### Retro (automatic, end of every BUILD/FIX)

Writes to `.docs/work/<slug>/retro.md`. Lightweight retros are more descriptive about what was done (since there's no sketch.md).

**Retro is a living document during its session:**
1. Agent writes initial retro from session context (git diff, test results, what happened)
2. User tests the feature/fix (may happen during polish or after)
3. User provides feedback — failures, style issues, things the agent missed
4. Agent resolves the issues found
5. Retro gets updated with the full picture — including what the user found and how it was resolved

This makes retros valuable for propose/evolve because they capture real-world results, not just agent self-assessment.

**BUILD retro sections:**
- Result — what was delivered
- What We Learned — technical insights
- What Went Well — what to repeat
- What Went Wrong — categorized by root cause
- Action Items — immediate follow-ups

**FIX retro sections:**
- Result — what was fixed
- Root Cause — technical explanation
- What Didn't Work — investigation dead ends and why
- Fix — the actual solution
- What Went Well / What Went Wrong — same categories
- Prevention — how to avoid recurrence

**Root cause for "What Went Wrong":** Free-text explanation first. Then tag with a category if one fits — categories help `/propose` detect patterns and help agents think more specifically about what kind of thing went wrong.

| Category | Meaning |
|---|---|
| Poor user description | Ambiguous, incomplete, or misleading request |
| Incorrect scope/tier | Router misclassified lightweight/standard/deep |
| Poor sketch decisions | Wrong approach chosen, missed constraints |
| Stale research/docs | Research or docs contain outdated information |
| Poor CLAUDE.md | Project instructions missing or misleading |
| Poor code patterns/structure | Codebase structure caused confusion or bugs |
| Poor test coverage | Pre-existing gap in tests |
| Poor enforcement | Verification didn't catch a problem |
| Poor skill behavior | Framework bug → create GitHub issue |
| External/environmental | Third-party service, CI, environment issue |

**MAP.md maintenance:** Retros that touch new modules or paths incrementally update MAP.md.

**Gotchas:**
- Write specific technical findings, not generic summaries — "auth middleware doesn't validate token expiry" not "there were some issues"
- Include what went wrong with root cause, not just what went right

### EXPLORE

Lightweight by nature. Dispatches explorers, synthesizes, done. No retro produced.

1. Explorers return findings (already dispatched by router)
2. Synthesize findings into a clear answer
3. If external research was done, persist to `.docs/research/<topic>.md` (only artifact)
4. **Transition (optional):** "Let's build it" -> BUILD with research context. "Fix what we found" -> FIX. "Just needed to know" -> done.

**Gotchas:**
- Cite sources for every finding — distinguish codebase evidence from model knowledge from external research
- Persist external research to `.docs/research/` — session context dies, files survive

---

## Post-Cycle: Propose & Evolve

### /propose (manual)

Aggregates retros, identifies patterns, drafts change proposals.

1. **Scope** — which retros to analyze (all since last evolve, or filtered by module/tag/date)
2. **Pattern detection** — repeated root cause categories, recurring "what went wrong" themes, clusters
3. **Overlap check** — grep prior proposals to avoid duplicates
4. **Draft proposals** — each categorized by target:

| Target | Example |
|---|---|
| `skill-change` | "Sketch should ask about cross-platform impact" |
| `claude-md-change` | "Add convention about error handling in API layer" |
| `code-pattern` | "Extract shared validation into middleware" |
| `test-gap` | "Add integration tests for queue consumer" |
| `docs-gap` | "Document the deployment pipeline" |
| `research-update` | "React docs are stale, need refresh" |
| `process-change` | "Lightweight FIX still needs sketch for auth-related bugs" |

5. **Write** to `.docs/evolve/NNN-proposals.md`

**Per-proposal format inside the file:**

```markdown
### Proposal 1: [title]
- **Target:** skill-change | claude-md-change | code-pattern | test-gap | docs-gap | research-update | process-change
- **Evidence:** [which retros, what pattern was detected]
- **Description:** [what to change and why]
- **Acceptance criteria:** [how to know it's done]
- **Status:** proposed | accepted | rejected | deferred
```

### /evolve (manual)

Executes accepted proposals after team review.

1. **Read** the proposals file, identify accepted items
2. **Execute** each accepted proposal (edit skills, CLAUDE.md, research docs, code, tests)
3. **Staleness handling** for research docs:
   - Keep — still accurate
   - Update — core correct, references drifted
   - Replace — misleading, better replacement exists
   - Delete — no longer useful (git preserves history)
4. **Write** to `.docs/evolve/NNN-evolve.md` logging what changed
5. **Append** to `.docs/CHANGELOG.md`

---

## Artifacts & Directory Structure

```
.docs/
  work/<YYMMDD-slug>/
    sketch.md              # what/why (std/deep only)
    blueprint.md           # how (std/deep only)
    retro.md             # reflection (all tiers)
  research/<topic>.md      # living docs from external research
  evolve/
    <NNN>-proposals.md     # aggregated retro analysis
    <NNN>-evolve.md        # executed changes log
  MAP.md                   # project navigation index
  CHANGELOG.md             # append-only log of evolve changes
  FRAMEWORK.md             # this document
```

**Design principle:** All artifacts live in `.docs/` (dotdir). `rg` and `grep` skip dotdirs by default, preventing pollution of codebase searches.

**MAP.md:** Essential infrastructure. Agent-friendly project navigation index (not `.docs/`, the project codebase). Generated via `rtk tree` / `tree` / `ls` (whichever is available), maintained incrementally via retros. Evolve cleans up stale entries. Format rules:
- Tree structure with annotations, not markdown formatting
- Collapsed platform notation: document the boilerplate path pattern once at top, then show meaningful logical structure
- `[README]` markers on directories that have a README
- Comments only when not self-explanatory
- Deep modules philosophy: show logical structure, not every file

```
# MAP.md
Platform pattern: apps/<platform>/src/...

- apps/
  - backend/
    - payment — Stripe payment processing [README]
    - auth — JWT authentication, RBAC
  - frontend/
    - dashboard — Admin dashboard (React) [README]
- packages/
  - shared — Shared types and utilities
```

## YAML Frontmatter Schemas

All artifacts use YAML frontmatter for grep-first retrieval.

### sketch.md

```yaml
---
title: Add notification system
date: 2026-04-11
type: build           # build | fix
tier: standard        # lightweight | standard | deep
status: draft         # draft | complete
module: notifications
tags: [email, queue, workers]
affected_systems: [api, worker, database]
---
```

### blueprint.md

```yaml
---
title: Add notification system
date: 2026-04-11
source_sketch: 260411-notifications
tier: standard
status: draft         # draft | complete | blocked
overall_confidence: GREEN  # GREEN | YELLOW | RED
module: notifications
tags: [email, queue, workers]
unit_count: 4
---
```

### retro.md

```yaml
---
title: Add notification system
date_completed: 2026-04-11
source_sketch: 260411-notifications  # omitted for lightweight (no sketch)
type: build           # build | fix
tier: lightweight     # lightweight | standard | deep
outcome: success      # success | partial | failed
module: notifications
tags: [email, queue, workers]
# FIX only:
severity: high        # critical | high | medium | low
root_cause: poor-test-coverage  # enumerated category
---
```

### research/<topic>.md

```yaml
---
title: React Server Components
date_created: 2026-04-10
date_updated: 2026-04-11
module: frontend
tags: [react, ssr, performance]
---
```

### evolve/NNN-proposals.md

```yaml
---
title: Evolve Proposals Round 3
date: 2026-04-15
retros_analyzed: [260411-notifications, 260412-auth-fix, 260413-api-refactor]
status: draft         # draft | reviewed | accepted
---
```

### evolve/NNN-evolve.md

```yaml
---
title: Evolve Execution Round 3
date: 2026-04-15
source_proposals: 003
changes_made:
  - target: skill-change
    description: Added cross-platform impact question to sketch
    files: [skills/agentic/references/sketch-template.md]
  - target: claude-md-change
    description: Added API error handling convention
    files: [CLAUDE.md]
---
```

### CHANGELOG.md

```yaml
---
title: Evolve Changes Log
---
```

Append-only. Each evolve session appends an entry:

```markdown
## Evolve #3 — 2026-04-15
Source: proposals #3
Retros analyzed: 260411-notifications, 260412-auth-fix

Changes:
- [skill-change] Added cross-platform impact question to sketch
- [claude-md-change] Added API error handling convention
```

## Hooks

### v1 (essential)

**SessionStart:**
- Inject framework context: .docs/ location, MAP.md path, available skills
- Ensure agents know to look in .docs/ for prior work

**PreCompact:**
- Persist in-progress work artifacts before context compression
- Ensures sketch/blueprint drafts survive `/compact`

**PostCompact:**
- Re-inject critical hard gates after compaction (compaction may summarize away rules, dropping compliance)
- Minimum re-inject: TEST-THEN-CODE, EVIDENCE-BEFORE-CLAIMS, ARTIFACT-BEFORE-HANDOFF
- Re-inject project verification suite definition from CLAUDE.md

**Stop:**
- Persist in-progress work when session ends (same concern as PreCompact, different trigger)
- User may close terminal mid-work — drafts must survive

### Project-level (verification)

The framework defines the pattern: **verify before claiming done**. The project defines what verification means.

Projects configure PostToolUse hooks for their verification suite — any combination of: tests, linter, formatter, type checker, build, dead code detection (knip), etc. The framework does not prescribe which tools — projects vary.

Document the project's verification suite in CLAUDE.md (see Project CLAUDE.md Requirements).

### Hook Security

- Hooks run with user's system permissions — treat hook inputs as untrusted
- Quote all shell variables
- Use absolute script paths or documented project variables
- Keep failure output concise and actionable — verbose errors waste context

### Deferred

- PreToolUse guards (protect .docs/ artifacts from accidental overwrites)
- SubagentStop (validate agent contract/outputs)

## Models

| Role | Model | Reasoning |
|---|---|---|
| Router / orchestration | Parent session model | Strongest reasoning for classification and questioning |
| Explorer agents | Sonnet 4.6 | Fast, cheap, focused search and retrieval |
| Craft agents | Opus 4.6 | Code quality matters most here |
| Review agents | Sonnet 4.6 | Focused review, scoped analysis |
| Bounded checks | Haiku 4.5 | Deterministic, low-ambiguity, clear pass/fail. 3x cheaper than Sonnet. |

Haiku candidates: placeholder/stub scanning, YAML frontmatter validation, lint-style checks, doc updates, MAP.md maintenance in retro (compare git diff paths against MAP.md, add missing entries). Pattern from Compound Engineering (lint agent, coherence-reviewer) and Everything Claude Code (doc-updater): high-volume pass/fail work where judgment is not needed.

## Tool Preference

Prefer the lowest-overhead tool that reliably solves the task.

| Preference | When |
|---|---|
| **CLI first** (`gh`, `git`, `rg`, `tree`) | Mature external tools. 10-32x more token-efficient than MCP equivalents. |
| **MCP when it wins** (e.g., Context7) | Structured, pre-indexed data that CLI would require multiple steps to assemble. Documentation lookup via Context7 is cheaper than web crawling or reading entire repos. |
| **Web as fallback** | When CLI and MCP cannot provide the data. Multiple tool calls, parsing overhead. |

Principle: measure by total token cost per answer, not by tool type. CLI usually wins, but MCP wins when it returns focused data in one call.

## Skill & Agent File Budgets

| Target | Budget | Why |
|---|---|---|
| SKILL.md | < 200 lines | Loaded on every invocation — competes with codebase context |
| Agent files | < 120 lines | Agents have their own context windows — every instruction line competes with files they need to read |
| References | On-demand via Read | Use `references/` folder for phase-specific detail, loaded only when needed |

**Placeholder two-tier system:**
- **Hard ban** (auto-reject): "TBD", "TODO", "etc.", "similar", "and so on", "as needed"
- **Soft ban** (flag + replace): "appropriate", "relevant", "necessary", "proper", "handle accordingly", "standard", "as described above"
- Principle: if an implementing agent reading the phrase would need to make a judgment call, it's a placeholder

## Agent Voice

All agents inherit a unified voice: competent identity with compressed output. These are independent levers — concise output does not require a dumbed-down identity.

**Persona pattern:** `"[Role]. Expert, direct, no filler. [domain-specific trait]."`

Examples:
- "Correctness reviewer. Expert, direct, no filler. Skeptical, evidence-only."
- "Code explorer. Expert, direct, no filler. Grep-first, codebase-only."
- "Craft agent. Expert, direct, no filler. TDD-disciplined, behavioral focus."

**Output format:**

Drop: articles (a/an/the), filler (just/really/basically/actually/simply), pleasantries (sure/certainly/of course/happy to), hedging (might/perhaps/I think/it seems). Fragments OK. Short synonyms (big not extensive, fix not "implement a solution for"). Technical terms exact. Code blocks unchanged. Errors quoted exact.

Pattern: `[thing] [action] [reason]. [next step].`

Not: "Sure! I've identified that the issue is likely caused by a race condition in the authentication middleware."
Yes: "Race condition in auth middleware. Token expiry check uses `<` not `<=`. Fix:"

**Token budgets (guidelines, not hard caps):**

| Agent output | Budget |
|---|---|
| Explorer findings | < 500 tokens |
| Review findings | < 200 tokens per issue |
| Craft status | < 100 tokens |
| Retro sections | < 300 tokens per section |

**Auto-clarity:** Drop compressed voice for security warnings, irreversible action confirmations, and multi-step sequences where fragments risk misread. Resume after.

## Project CLAUDE.md Requirements

The project's `CLAUDE.md` must include so agents have the right context:

1. **Workflow artifacts directory** — `.docs/` location, structure, YAML frontmatter convention
2. **Available CLI tools** — what's installed (`tree`, `rtk`, etc.) so agents use the right commands
3. **Tech stack** — languages, frameworks, test runners per platform
4. **Conventions** — error handling, naming, patterns specific to this project
5. **Verification suite** — which checks to run before completion claims (test, lint, typecheck, format, build, knip, etc.) and exact commands for each

## Hard Gates

Non-negotiable rules enforced across the framework. Instruction-based compliance is ~60-70%. Gates 3, 5, 7 are re-injected via PostCompact hook to survive compaction. Project-level verification hooks enforce evidence requirements (see Hooks section).

1. **DESIGN-THEN-CODE** — Sketch (std/deep) or router classification (light) before implementation
2. **OPTIONS-THEN-RECOMMEND** — Present ALL approaches before recommending (anti-anchoring)
3. **ARTIFACT-BEFORE-HANDOFF** — Persist artifact to disk before transitioning to next phase
4. **AGENT-DISPATCH-MANDATORY** — Explorers must run before classification (dispatched once router has a directed assumption)
5. **EVIDENCE-BEFORE-CLAIMS** — Run verification, read output, then claim result
6. **INVESTIGATE-THEN-FIX** — Reproduce, hypothesize, confirm root cause, then fix
7. **TEST-THEN-CODE** — Write failing test first, then implementation (guardrails iron law, all tiers)

## Rationalization Prevention

| Thought | Reality |
|---|---|
| "This is just a simple change" | Simple changes have root causes and test requirements too |
| "I'll write the test after" | Tests-after prove nothing. Tests-first discover edge cases. |
| "Let me skip the sketch, I know what to do" | Sketch captures shared understanding, not just your understanding |
| "The explorers won't find anything" | They inform routing. Run them. |
| "Polish is overkill for this" | Polish scales by tier. Lightweight polish IS lightweight. |
| "I'm confident it works" | Confidence != evidence. Run the verification. |
| "Just one more fix attempt" | 3 failed fixes = wrong architecture. Stop. |

## Interaction Principles

- **One section per message** — wait for response before advancing (prevents rubber-stamping)
- **Checkpoint summary pattern** — cap at ~5 questions per round, then write: "Here's what I understand so far: [summary with assumptions]. Any thoughts?" User corrects/confirms, next round or proceed. Repeat until mutual understanding. Used by both the router and the sketch.
- **Ask user's thinking BEFORE presenting AI findings** — prevents anchoring
- **Hold well-reasoned positions** when user disagrees — explain why, don't cave
- **No sycophancy** — technical correctness over social comfort
- **Dynamic depth** — match questioning intensity to user's clarity level

---

## Resolved Decisions

Decisions made during framework design, preserved for context.

1. **Sketch template** — sections are present but not rigidly mandatory. Checkpoint summary pattern naturally surfaces gaps. `status: complete` means mutual understanding achieved, not all fields populated.
2. **Blueprint template** — per-unit structure + durable decisions is concrete enough. Blueprint review gate enforces quality, not template rigidity.
3. **Retro lifecycle** — agent-written, user-testable, living document during session. Captures both agent work and user-discovered findings.
4. **Trace upgrade heuristic** — 3+ files or 2+ subsystems touched, or unclear root cause → propose upgrade to std/deep. User confirms.
5. **Propose pattern detection** — group by root cause category, flag 3+ occurrences. Same module in multiple retros. Minimum 3 retros. Agent judgment, no algorithm.
6. **CHANGELOG format** — simple append-only entries (evolve #, date, source proposals, change list). No YAML body.
7. **MAP.md format** — agent-friendly tree structure, collapsed platform notation, `[README]` markers, comments only when not self-explanatory. Deep modules philosophy.
8. **EXPLORE artifacts** — produces research only (`.docs/research/<topic>.md`), no retro.
9. **Cross-platform** — deferred to project-level. Handled by MAP.md modules, durable decisions in blueprints, project CLAUDE.md.
10. **Scope upgrade/downgrade** — agent proposes with reasoning, user confirms. Upgrading: current session context becomes starting point for sketch, no restart. Downgrading: drop extra ceremony, keep what's captured.
11. **Non-software tasks** — naturally supported. BUILD covers docs/design, EXPLORE covers research. Different verification criteria (no tests, but polish still applies).
12. **Visual communication** — deferred. Project-specific (Figma, ASCII, etc). Framework accommodates visuals as context, doesn't prescribe format.
13. **Hook implementation** — v1: SessionStart + PreCompact + Stop. Exact scripts are implementation details, resolved when building hooks (build order item 11).

## Open Questions

Items to revisit as skills are built.

1. **Sketch section ordering** — does BUILD mode benefit from a specific question sequence, or is the checkpoint pattern sufficient to cover sections in any order?
2. **Conditional reviewer triggers** — how does the framework detect what was touched? File-path patterns, content analysis, or explicit tagging in the blueprint?
3. **Propose minimum retro count** — is 3 retros the right threshold, or should it adapt to project velocity?
4. **Hook scripts** — exact shell scripts for SessionStart, PreCompact, Stop. Build when implementing hooks.

## Build Order

Recommended sequence for implementing this framework as skills:

1. `/agentic` — router with explorer dispatch and classification
2. `sketch` — internal skill, BUILD and FIX modes, checkpoint summary pattern
3. `blueprint` — internal skill, implementation units, durable decisions, review gate
4. `craft` — internal skill, TDD (guardrails) discipline, inline and subagent modes
5. `polish` — internal skill, tier-scaled, multi-persona for std/deep
6. `trace` — internal skill, FIX gate
7. `retro` — internal skill, automatic, two formats (BUILD/FIX), living document
8. `/propose` — user-invokable, retro aggregation and pattern detection
9. `/evolve` — user-invokable, execute accepted proposals
10. Agents — code-explorer, docs-explorer, blueprint reviewers, code reviewers
11. Hooks — SessionStart, PreCompact, Stop
12. CLAUDE.md — project instructions that make the framework discoverable
