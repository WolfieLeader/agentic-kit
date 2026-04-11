---
title: Agentic Kit Framework
date: 2026-04-11
status: draft
version: 0.1
---

# Agentic Kit Framework

A meta-framework for AI-assisted software development. One entry point, three workflows, knowledge that compounds over time.

**Core sources:** Compound Engineering (lifecycle, agents, artifacts), Superpowers (discipline, gates, TDD, verification), CC10X (circuit breakers, routing), Matt Pocock (TDD philosophy, deep modules, behavioral testing), ECC (agent design, file budgets, grep-first search).

**Design principles:**
- **Context window is gold — use the disk.** Every phase that produces output writes to disk. Handoff between phases is via persisted artifacts. Skills are session-independent — you can `/compact`, start a new conversation, or come back days later.
- **Trust the implementing agent.** Blueprints describe what to build, not how to type it.
- **Right-size ceremony to scope.** Lightweight changes get lightweight process. But every change gets something.

## Architecture

```
User input
  -> /agentic router self-look (MAP.md, CLAUDE.md, grep .docs/ frontmatter, scan likely files)
  -> Classify type + provisional tier from user input + self-look
  -> Dynamic questioning scaled to clarity level
  -> Lightweight: no explorer dispatch
  -> Std/deep: dispatch sonnet explorers with directed context (in parallel)
  -> Explorers return findings (stay in context, not persisted — sketch absorbs what matters)
  -> Final classification confirmed
  -> Dispatch to pipeline:

light BUILD/FIX:     (trace if FIX) -> craft -> verify -> retro
std/deep BUILD/FIX:  (trace if FIX) -> sketch -> blueprint -> craft -> verify -> retro
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
| `/extend` | Add agents/skills to framework phases. Inspects fit, suggests modifications, updates `.docs/extend/`. |
| `/propose` | Aggregate retros, identify patterns, draft change proposals. |
| `/evolve` | Execute accepted proposals, log to CHANGELOG.md. |

### Internal

| Skill | Purpose |
|---|---|
| `trace` | FIX gate. Reproduce, classify, assess severity, route. |
| `sketch` | Capture what/why via checkpoint summary pattern. Two modes: BUILD and FIX. |
| `blueprint` | Define how. Implementation units, durable decisions, test scenarios. |
| `craft` | Implement with TDD (guardrails + exception protocol). Inline (light) or sequential subagent-per-unit (std/deep). |
| `verify` | Single step, scales by tier. Evidence-based verification + multi-persona review (std/deep). |
| `retro` | Per-task reflection. Automatic at end of every BUILD/FIX. Living document during session. |

## Agents

### Explorer Agents (sonnet)

Dispatched by the router for std/deep tiers only (lightweight skips explorers). Both dispatched in parallel with directed context informed by router's self-look. Findings stay in session context, not persisted — sketch absorbs what matters.

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
- External escalation: best-effort if knowledge gap found on third-party topic -> Context7 MCP / official docs / GitHub. If external tools unavailable, flags gap in findings for orchestrator.
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

### Blueprint Reviewer (sonnet)

Single agent dispatched during blueprint review gate for std/deep tiers. Validates the blueprint before implementation begins. Checks coherence (internal consistency, contradictions, terminology drift), feasibility (will this survive contact with reality?), and scope (challenges unnecessary abstractions, unjustified complexity).

**Blueprint review rules:**
- Evidence-based findings: file/line, observed issue, expected, why it's a problem. Findings without specifics suppressed.
- Findings feed back into blueprint revision (max 3 retries before escalating to user)
- Blueprint is not extendable — framework-defined reviewer only

### Code Review Agents (opus)

Dispatched during verify for std/deep tiers only. Read-only, return structured findings. Last line of defense before shipping — opus for review quality.

**Framework always-on:**

| Agent | Focus |
|---|---|
| `correctness-reviewer` | Logic errors, edge cases, state bugs, error propagation |
| `testing-reviewer` | Coverage gaps, weak assertions, brittle tests |
| `maintainability-reviewer` | Coupling, complexity, naming, dead code |

Domain-specific reviewers (security, performance, api-contract, data-migrations) are project-level — add via `/extend` verify extensions.

**Code review rules:**
- Evidence-based findings: file/line, observed behavior, expected behavior, why it's a problem. Findings without file/line suppressed.
- Severity scale: P0 (critical) -> P1 (high) -> P2 (moderate) -> P3 (low)
- Zero-finding halt: if nothing found, say so and stop. No inventing issues.
- Stack-agnostic: no language-specific reviewers in the framework. Projects add their own via `/extend`.

**Finding format (plain markdown, in-context):**
```
### [short title]
- **Severity:** P0 | P1 | P2 | P3
- **File/line:** path:line
- **Observed:** [what the code does]
- **Expected:** [what it should do]
- **Why:** [why this is a problem]
```

### Craft Agents (opus, sonnet for mechanical)

Dispatched during craft for std/deep tiers. Fresh subagent per implementation unit, dispatched sequentially. Opus by default — optimize for first-pass success, not per-token cost. Sonnet only for trivially mechanical tasks (color change, comment edit, single-line config).

**Receives:** self-contained context constructed by orchestrator — unit details (goal, files, approach, test scenarios), relevant durable decisions, relevant explorer findings, project conventions. No file path reading assignments.
**Returns:** DONE / BLOCKED / NEEDS_CONTEXT.
**Discipline:** TDD (guardrails) mandatory with exception protocol, self-review before reporting done.

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

```
Receives: user input
Reads:    MAP.md, CLAUDE.md, .docs/extend/router.md
Greps:    .docs/work/ (YAML frontmatter: module, tags, title — resume check)
          .docs/research/ (YAML frontmatter: module, tags, title — prior research)
Scans:    files likely to change (light grepping based on user input)
          git diff/log (when user references recent changes)
Produces: dispatch summary (in-context), type classification, tier classification
          Generates MAP.md on first run if missing
          Generates slug (YYMMDD-kebab-case) — duplicate triggers resume flow
Dispatches: explorer agents (std/deep) + extension explorers from .docs/extend/router.md
Passes:   → trace (FIX) | sketch (BUILD/FIX std/deep) | craft (BUILD/FIX light) | EXPLORE
          Forwards: dispatch summary, explorer findings (std/deep), user input
```

The only user-facing entry point for work. Two-pass routing:

1. **Self-look** — read MAP.md + CLAUDE.md, grep `.docs/` frontmatter, scan likely files, check git context if relevant. Enough to classify most tasks without dispatching agents.
2. **Classify** type (BUILD/FIX/EXPLORE) and provisional tier (light/std/deep) from user input + self-look.
3. **Dispatch explorers** (std/deep only) with directed context informed by self-look. Lightweight skips explorers.
4. **Ensure clarity** via dynamic questioning scaled to user's input clarity.

**Checkpoint summaries include agent assumptions** — not just "here's what you told me" but "here's what you told me + here's what I'm assuming based on MAP.md, CLAUDE.md, and codebase context." User corrects wrong assumptions, confirms correct ones. Accelerates convergence to shared understanding.

**Dynamic questioning depth:**

| User clarity | Router behavior |
|---|---|
| Both intent and scope clear | Classify, confirm, dispatch. 1-2 exchanges. |
| Intent clear, scope unclear | 2-3 scoping questions, then dispatch. |
| Intent unclear | Probe intent first, then scope. 3-5 exchanges. |
| Both unclear | Iterative questioning until dispatch-ready. 5+ exchanges. |

**Exit condition:** The router stops questioning when it can write a clear one-paragraph dispatch summary.

**Resume:** Router greps `.docs/work/` YAML frontmatter for matching module/tags/title. If a matching work folder exists, the router tells the user what's already there and provides a brief preview: "I found existing work for [slug] — here's what's done: [summary]. Want to continue from here or start fresh?" User decides.

**Shortcuts:** If the user explicitly states urgency or provides a clear spec, the router fast-tracks. It doesn't force questioning when clarity already exists.

**Gotchas:**
- Classify after understanding, not before — rushed routing leads to wrong tier, wrong pipeline, wasted work
- Question lightweight classification — most tasks touching 2+ files or 2+ concerns are standard
- Dispatch explorers with specific search terms, not "look around"

### Trace (FIX only)

```
Receives: dispatch summary, explorer findings (if std/deep), user input
Reads:    source code, test output, browser/logs as needed, .docs/extend/trace.md (investigation specialists)
Dispatches: extension investigation agents from .docs/extend/trace.md
Produces: reproduction result, hypothesis, severity (all in-context, no artifact)
Passes:   → done (not a bug)
          → craft (lightweight: trace context flows in-session)
          → sketch (std/deep: trace context informs FIX mode sections)
          Forwards: reproduction result, hypothesis, severity, affected files
```

Gate that determines if the issue is a real bug. No artifact produced — findings stay in session context.

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

```
Receives: dispatch summary, explorer findings, user input, trace context (FIX only)
Reads:    source referenced by explorers, .docs/research/ if relevant
Produces: .docs/work/<slug>/sketch.md
Passes:   → blueprint
          Forwards: sketch.md path, explorer findings
```

Captures **what** and **why**. One skill, two modes. Produces `sketch.md`.

**Checkpoint summary pattern:**
- Ask up to ~5 questions per round
- Write checkpoint summary including agent assumptions from explorer findings, MAP.md, and codebase context: "Here's what I understand so far: [summary + assumptions]. Any corrections?"
- User only corrects wrong assumptions, confirms correct ones — accelerates convergence
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

```
Receives: sketch.md path, explorer findings
Reads:    sketch.md, source code as needed for feasibility
Produces: .docs/work/<slug>/blueprint.md
Gate:     dependency coherence, completeness (blueprint reviewer), no placeholders, testability
Passes:   → craft
          Forwards: blueprint.md path, explorer findings
```

Defines **how**. Produces `blueprint.md`. Behavioral goals, not code.

**Implementation units:** vertical slices, each testable end-to-end.

Per unit:
- Goal (behavioral, what it should do)
- Dependencies (which units must complete first — DAG rule: no circular deps)
- Confidence (GREEN / YELLOW / RED)
- Affected systems
- Approach (behavioral description, NOT code)
- Test scenarios (happy path, edge cases, error paths)
- Verification criteria

**Durable decisions:** top-level section for decisions that cross implementation units (e.g., API routes, database schema, shared types, auth boundaries, service boundaries, cross-platform impacts).

**Blueprint review gate (4 checks, fail-closed):**
1. Dependency coherence (inline) — no circular deps, no missing deps
2. Completeness (single blueprint reviewer) — checks coherence, feasibility, scope (see Blueprint Reviewer)
3. No placeholders (inline) — hard ban on TBD, TODO, etc.
4. Testability (inline) — every unit has test scenarios

Max 3 review retries before escalating to user. Downgrade to lightweight possible here if blueprint reveals simpler scope than expected — user confirms.

**What blueprints do NOT contain:** implementation code, exact shell commands, file-level diffs. Blueprints describe what to build, not how to type it. Trust the crafting agent.

**Gotchas:**
- Describe behavior, not implementation — "validates email format" not `if (!email.match(/regex/))`

### Craft

Implements with TDD (guardrails). Two modes based on tier.

**Lightweight:**
```
Receives: dispatch summary, user input (from router context)
Produces: code changes, tests
Passes:   → verify
```
- No subagent. Main session implements directly.
- Works from router context (self-look + user input).
- Guardrails cycle: RED -> verify fail -> GREEN -> verify pass -> REFACTOR.
- No per-task review loop. Verify at the end covers it.
- No extensions — lightweight skips `.docs/extend/craft.md`.

**Standard/Deep:**
```
Receives: blueprint.md path, explorer findings
Reads:    blueprint.md (extracts units), .docs/extend/craft.md (between-unit checks)
Per-unit subagent receives: self-contained context (unit details, relevant durable decisions, relevant explorer findings, project conventions)
Per-unit subagent returns: DONE | BLOCKED | NEEDS_CONTEXT
Produces: code changes, tests
Passes:   → verify
```
- Orchestrator reads blueprint once, extracts per-unit context.
- Fresh opus subagent per unit, dispatched **sequentially**. Context isolation, not filesystem isolation. No parallel dispatch in v1.
- Orchestrator constructs self-contained context per subagent — no file path reading assignments. Subagent gets everything it needs upfront.
- **Per-unit review (inline, by orchestrator):**
  - Tests pass for this unit
  - No stubs/placeholders
  - Matches the blueprint's implementation unit goal
  - Quick correctness scan
- **Between-unit extension checks** from `.docs/extend/craft.md` (if configured).
- Unit status handling:
  - DONE → next unit
  - BLOCKED → assess: context problem → re-dispatch with more context. Too large → break down, re-dispatch. Genuine blocker → escalate to user.
  - NEEDS_CONTEXT → provide and retry
- **No automatic commits.** Git workflow (commit, PR, merge) is the user's choice.
- **Progress tracker:** Restate unit checklist at each unit boundary. `[x] Unit 1 done. [x] Unit 2 done. [ ] Unit 3 — current. [ ] Unit 4.`
- Sonnet for trivially mechanical units only (color change, comment edit, single-line config). Opus is the default.

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

Strong default at ALL tiers, with exception protocol.

**The cycle:**
```
RED:      Write one failing test (behavioral, public interface, one behavior)
VERIFY:   Confirm it fails for the expected reason (MANDATORY)
GREEN:    Write minimum code to pass (simplest possible)
VERIFY:   Confirm it passes, no other tests broken (MANDATORY)
REFACTOR: Clean up, remove duplication, improve names (keep green)
```

**Exception protocol:** When test-first doesn't apply (CSS/styling, config, migrations, infra scripts, docs/design tasks, legacy code with no test harness):
1. State why test-first doesn't apply
2. Specify alternate verification from the project's suite (lint, typecheck, format, build, knip, LSP diagnostics, visual check, migration dry-run, etc.)
3. Retro tags the exception so `/propose` can track frequency

The project's CLAUDE.md defines what verification tools are available. The iron law is "no unverified code" — TDD is the preferred method, not the only method.

**Principles:**
- Test behavior through public interfaces, not implementation details
- Vertical slices: one test -> one implementation (not all tests then all code)
- Boundary-only mocking: external APIs, DBs, caches, time, filesystem. Real code internally.
- Refactor only when GREEN
- Code written before test MUST be deleted entirely
- 80%+ coverage target (not 100%)
- Tests should survive internal refactors unchanged

**4-fix circuit breaker (universal, all tiers):**
- A **fix attempt** = code change with intent to resolve + verification showing it didn't work. Investigation (logging, reading code, reproducing, narrowing down) does NOT count.
- 4 failed fix attempts → STOP
- Question the approach, not just the symptom
- Discuss with user before attempting more fixes
- User can authorize more attempts after discussion

**Per-agent iteration cap:**
- Separate from the 4-fix breaker — catches runaway agents that hit different errors each time
- No default number. Projects set their own cap via evolve when retros show runaway sessions.
- When hit: agent pauses with status report to user, does not silently continue

**12 rationalization red flags:**
"I'll write test after", "too simple to test", "just manually verify", "obvious test", "need to see implementation first", "get it working then test", "just a refactor", "existing tests cover this", "tests in follow-up", "prototype/POC", "too hard to write", "watch mode shows passing"

### Verify

Single step, scales by tier.

**Lightweight:**
```
Receives: diff, user's original request
Reads:    test output, build output
Produces: verification evidence (in-context)
Passes:   → retro
```
- Tests pass (run command, read output, evidence before claims)
- Build clean
- No stubs/placeholders (hard ban: TBD, TODO, etc.)
- Quick scan of the diff — does it match what was asked?
- One pass, inline, no subagent

**Standard/Deep — Verification (structural, automated, by orchestrator inline):**
- Full test suite passes
- Build clean
- Stub/placeholder scan (hard ban)
- Wiring check — are new components actually connected?
- Sketch/blueprint compliance — does the implementation match what was specified?

**Standard/Deep — Review (multi-persona, subagent):**
```
Receives: diff, sketch.md path, blueprint.md path
Reads:    test output, build output, sketch.md, blueprint.md, .docs/extend/verify.md (additional reviewers)
Dispatches: 3 always-on framework reviewers (correctness, testing, maintainability) + extension reviewers from .docs/extend/verify.md
Produces: verification evidence, review findings (structured per-finding)
Passes:   → retro (after P0/P1 findings resolved)
```
- Orchestrator runs verification suite inline. Review agents are read-only code analysis only.
- Evidence-based findings (see Code Review Agents finding format)
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

```
Receives: session context (what happened), sketch.md path (std/deep, omitted for light)
Reads:    git diff, test results
Produces: .docs/work/<slug>/retro.md
Updates:  MAP.md (if new modules/paths touched)
Passes:   → done (pipeline ends, git workflow is user's choice)
```

Writes to `.docs/work/<slug>/retro.md`.

**Retro is a living document during its session:**
1. Agent writes initial retro from session context (git diff, test results, what happened)
2. User tests the feature/fix (may happen during verify or after)
3. User provides feedback — failures, style issues, things the agent missed
4. Agent resolves the issues found
5. Retro gets updated with the full picture — including what the user found and how it was resolved

This makes retros valuable for propose/evolve because they capture real-world results, not just agent self-assessment.

**Lightweight retro** adds a brief **Context** section at the top — what was asked, what was found, what approach was taken. Two to three sentences. Replaces the sketch that doesn't exist for lightweight tasks.

**BUILD retro sections:**
- Context (lightweight only) — what was asked, found, approach taken
- Result — what was delivered
- What We Learned — technical insights
- What Went Well — what to repeat
- What Went Wrong — categorized by root cause
- Action Items — immediate follow-ups

**FIX retro sections:**
- Context (lightweight only) — what was asked, found, approach taken
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
| Poor skill behavior | Framework bug → report upstream for meta-framework improvement + local adaptation via `/evolve` if needed |
| External/environmental | Third-party service, CI, environment issue |

**MAP.md maintenance:** Retros that touch new modules or paths incrementally update MAP.md.

**Gotchas:**
- Write specific technical findings, not generic summaries — "auth middleware doesn't validate token expiry" not "there were some issues"
- Include what went wrong with root cause, not just what went right

### EXPLORE

```
Receives: dispatch summary, explorer findings
Produces: synthesized answer (in-context)
          .docs/research/<topic>.md (only if external research was done)
Passes:   → done | in-session transition to BUILD or FIX with research context
```

Lightweight by nature. Dispatches explorers, synthesizes, done. No retro produced.

1. Explorers return findings (already dispatched by router)
2. Synthesize findings into a clear answer
3. If external research was done, persist to `.docs/research/<topic>.md` (only artifact)
4. **Transition (optional, in-session):** "Let's build it" → router reclassifies as BUILD, reuses explorer findings and research context. "Fix what we found" → FIX. "Just needed to know" → done. No re-exploration needed.

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
3. **Staleness handling** for research docs (triggered when retros tag "stale research/docs" as root cause):
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
  extend/
    router.md            # additional explorers
    trace.md             # investigation specialists
    craft.md             # between-unit checks
    verify.md            # additional review agents
  MAP.md                   # project navigation index
  CHANGELOG.md             # append-only log of evolve changes
  FRAMEWORK.md             # this document
```

**Design principle:** All artifacts live in `.docs/` (dotdir). `rg` and `grep` skip dotdirs by default, preventing pollution of codebase searches.

**MAP.md:** Agent-friendly project navigation index (not `.docs/`, the project codebase). Router generates on first run if missing (one-time onboarding). Generated via `rtk tree` / `tree` / `ls` (whichever is available), maintained incrementally via retros. Evolve cleans up stale entries. Primary purpose: router self-look for classification and scope assessment. Format rules:
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

## Phase Extensions

Projects add agents/skills to framework phases via `/extend`. Each extendable phase has its own file in `.docs/extend/`, loaded by the phase skill at entry. Non-extendable phases (sketch, blueprint, retro, explore) are single-agent or conversational — no dispatch point for extensions.

**Agent sources:**
- **Project** — `.claude/agents/`, project-specific, committed to repo
- **User** — `~/.claude/agents/`, personal, cross-project (e.g., code-simplifier)

### Extendable Phases

**Router** (`.docs/extend/router.md`) — additional explorers dispatched in parallel alongside code-explorer and docs-explorer. Extensions gather domain-specific context before classification. Explorers return structured findings (Key Findings, Relevant Files, Open Questions) consumed by the router for classification.

Example: `compliance-explorer` checks regulatory docs, `design-system-explorer` checks Figma/design tokens, `infrastructure-explorer` checks Terraform/cloud config.

**Trace** (`.docs/extend/trace.md`) — investigation specialists dispatched to help diagnose the issue. Extensions provide domain-specific lenses on the problem. Findings inform the hypothesis and severity assessment.

Example: `design-reviewer` assesses if the issue is a design flaw vs implementation bug, `performance-profiler` analyzes performance regressions, `security-assessor` evaluates security implications.

**Craft** (`.docs/extend/craft.md`) — between-unit checks that run after each unit's mini-review loop completes (std/deep only, lightweight skips extensions). Extensions catch issues early before they compound across units. Must be fast — they run between every unit.

Example: `lint-enforcer` runs project linter, `style-checker` enforces code patterns, `doc-generator` generates docs alongside code.

**Verify** (`.docs/extend/verify.md`) — additional review agents dispatched alongside framework reviewers (correctness, testing, maintainability). Extensions provide project-specific or domain-specific code review. Most natural and common extension point.

Example: `security-reviewer` for auth-heavy projects, `rails-reviewer` for Rails conventions, `hipaa-reviewer` for healthcare compliance, `code-simplifier` for code quality.

### Per-phase file format

```yaml
---
phase: verify
date_updated: 2026-04-11
---

agents:
  - name: security-reviewer
    source: project
  - name: hipaa-reviewer
    source: project
  - name: code-simplifier
    source: user
```

**Rules:**
- All extensions are always-on — runs every time the phase executes
- Agent files follow the same format as framework agents (role, inputs, output format, file budget)
- Extensions use the same evidence-based finding format and severity scale as framework agents

### /extend

Invokable skill for managing phase extensions.

1. Accept agent/skill name and target phase
2. Reject non-extendable phases (sketch, blueprint, retro, explore) with explanation
3. Locate agent file (`.claude/agents/` or `~/.claude/agents/`)
4. Assess fit — does the agent's role and output format match the phase's expectations?
5. Suggest modifications if the agent needs adaptation (e.g., missing evidence-based finding format for verify, missing structured output for router explorers)
6. Create or update `.docs/extend/<phase>.md` with entry

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

### v1

**PostCompact:**
- Re-inject all hard gates + TDD exception protocol as a compact block after compaction (compaction may summarize away rules, dropping compliance)
- Exact re-injection text is a hook implementation detail, not framework spec

Router handles all framework discovery (MAP.md, CLAUDE.md, .docs/). SessionStart, PreCompact, and Stop hooks dropped for v1 — artifacts persist at phase boundaries, no emergency persistence needed.

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

| Role | Default | Reasoning |
|---|---|---|
| Router / orchestration | Parent session | Strongest reasoning for classification and questioning |
| Explorer agents | Sonnet | Fast, research-capable (Context7, external docs, GitHub) |
| Craft subagents | Opus (sonnet for mechanical) | First-pass success > per-token cost. Sonnet only for trivially mechanical tasks. |
| Code review agents | Opus | Last line of defense before shipping — review quality matters most |
| Blueprint reviewer | Sonnet | Structured document, focused checks, downstream safety nets |
| Docs updater | Sonnet | Structured updates, moderate judgment (MAP.md, research docs) |
| Bounded checks | Haiku | YAML frontmatter validation, strict pass/fail. Narrow slot. |

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

**Token budgets (provisional guidelines, calibrated through retros):**

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

Non-negotiable rules enforced across the framework. Instruction-based, re-injected via PostCompact hook to survive compaction.

1. **DESIGN-THEN-CODE** — Sketch (std/deep) or router classification (light) before implementation
2. **OPTIONS-THEN-RECOMMEND** — Present ALL approaches before recommending (anti-anchoring)
3. **ARTIFACT-BEFORE-HANDOFF** — Persist artifact to disk before transitioning to next phase
4. **EXPLORE-BEFORE-IMPLEMENT** — Router self-look always; explorer dispatch for std/deep before implementation begins
5. **EVIDENCE-BEFORE-CLAIMS** — Run verification, read output, then claim result
6. **INVESTIGATE-THEN-FIX** — Reproduce, hypothesize, confirm root cause, then fix
7. **TEST-THEN-CODE** — Write failing test first, then implementation (guardrails iron law, with exception protocol for non-testable changes)

## Rationalization Prevention

| Thought | Reality |
|---|---|
| "This is just a simple change" | Simple changes have root causes and test requirements too |
| "I'll write the test after" | Tests-after prove nothing. Tests-first discover edge cases. |
| "Let me skip the sketch, I know what to do" | Sketch captures shared understanding, not just your understanding |
| "The explorers won't find anything" | They inform routing for std/deep. Self-look informs lightweight. |
| "Verify is overkill for this" | Verify scales by tier. Lightweight verify IS lightweight. |
| "I'm confident it works" | Confidence != evidence. Run the verification. |
| "Just one more fix attempt" | 4 failed fixes = wrong approach. Stop and reassess. |

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
5. **Propose pattern detection** — group by root cause category, flag 3+ occurrences. Same module in multiple retros. No minimum retro count — user invokes `/propose` when ready. Agent judgment, no algorithm.
6. **CHANGELOG format** — simple append-only entries (evolve #, date, source proposals, change list). No YAML body.
7. **MAP.md format** — agent-friendly tree structure, collapsed platform notation, `[README]` markers, comments only when not self-explanatory. Deep modules philosophy.
8. **EXPLORE artifacts** — produces research only (`.docs/research/<topic>.md`), no retro.
9. **Cross-platform** — deferred to project-level. Handled by MAP.md modules, durable decisions in blueprints, project CLAUDE.md.
10. **Scope upgrade/downgrade** — agent proposes with reasoning, user confirms. Upgrading: can happen during trace or craft, current context carries forward to sketch. Downgrading: can happen during sketch or blueprint, skip remaining ceremony, go to craft with existing artifacts. Nothing gets discarded.
11. **Non-software tasks** — naturally supported. BUILD covers docs/design, EXPLORE covers research. Different verification criteria (no tests, but verify still applies).
12. **Visual communication** — deferred. Project-specific (Figma, ASCII, etc). Framework accommodates visuals as context, doesn't prescribe format.
13. **Hook implementation** — v1: PostCompact only (re-injects hard gates + TDD exception protocol). SessionStart, PreCompact, Stop dropped — router handles discovery, artifacts persist at phase boundaries. Project-level verification hooks configured per project.
14. **Two-pass routing** — router self-look (MAP.md, CLAUDE.md, grep .docs/ frontmatter, scan likely files, git context) for classification. Explorer dispatch for std/deep only. Lightweight skips explorers.
15. **Evidence-based review findings** — drop numeric confidence scores. Findings require file/line, observed behavior, expected behavior, why it's a problem. Findings without file/line suppressed.
16. **Sequential craft** — fresh opus subagent per unit, dispatched sequentially. Context isolation, not filesystem isolation. No parallel dispatch in v1.
17. **TDD exception protocol** — when test-first doesn't apply, state why, specify alternate verification, retro tags exception.
18. **4-fix circuit breaker** — fix attempt = code change + verification failure. Investigation doesn't count. After 4: stop, summarize, escalate.
19. **Single blueprint reviewer** — one sonnet agent checks coherence, feasibility, scope. Replaces three separate agents.
20. **No automatic commits** — git workflow (commit, PR, merge) is entirely the user's choice.
21. **Slug format** — YYMMDD-kebab-case, generated by router at classification time. Duplicate triggers resume flow.
22. **EXPLORE transitions** — in-session transition to BUILD/FIX, reuses explorer findings and research context.
23. **Extension simplification** — all extensions always-on, no conditional triggers. Lightweight craft skips extensions.
24. **Staleness handling** — purely retro-surfaced, acted on through manual propose → evolve cycle.
25. **Craft subagent context** — orchestrator constructs self-contained context per subagent. No file path reading assignments.
26. **Framework code reviewers** — 3 always-on (correctness, testing, maintainability). Domain-specific reviewers (security, performance, etc.) are project extensions.
27. **Agent voice** — framework default, projects can override. Token budgets provisional, calibrated through retros.

## Open Questions

Items to revisit as skills are built.

1. **Sketch section ordering** — does BUILD mode benefit from a specific question sequence, or is the checkpoint pattern sufficient to cover sections in any order?
2. **MAP.md usefulness** — ETH Zurich found LLM-generated navigation files don't help agents find files faster. MAP.md's primary purpose is router self-look for classification, not agent file discovery. Validate empirically from retros.
3. **KV-cache prompt structure** — learn empirically how to structure prompts for cache hit rates.
4. **Few-shot variation patterns** — learn from practice which tasks benefit from examples in prompts.
5. **Token budgets** — provisional numbers for agent output (explorer < 500, review < 200 per issue, craft status < 100, retro < 300 per section). Calibrate through retros.
6. **Parallel craft** — sequential-only in v1. If retros show sequential execution is a bottleneck for deep tasks with many independent units, revisit with worktree-based parallel dispatch.
7. **Subagent MCP access** — can subagents call MCP tools (Context7)? Affects docs-explorer external research path. Currently best-effort with gap flagging fallback.

## Build Order

Recommended sequence for implementing this framework as skills:

1. Directory structure + YAML schemas + MAP.md template
2. `retro` — capture learnings from day one while building the rest
3. `craft` + `verify` (lightweight only) — the core build loop
4. `/agentic` (router, lightweight only) — self-look, classification, no explorer dispatch
5. `sketch` + `blueprint` — std/deep ceremony
6. `trace` — FIX gate (must exist before craft handles FIX flows)
7. Upgrade router to dispatch explorers for std/deep
8. Explorer agents + code review agents + blueprint reviewer
9. `/extend` — manage phase extensions
10. `/propose` + `/evolve` — feedback loop
11. PostCompact hook
12. CLAUDE.md template — project instructions that make the framework discoverable
