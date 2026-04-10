# AI-Driven Development: Framework Comparison

## Repository Overview

This document compares overlapping phases across **Superpowers**, **Compound Engineering (CE)**, and **CC10X** — three Claude Code framework repos — plus relevant skills from **Matt Pocock's Skills** and **Everything Claude Code (ECC)**.

---

## 1. Brainstorming

| Aspect | **Superpowers** | **Compound Engineering** | **CC10X** |
|--------|----------------|--------------------------|-----------|
| **Invocation** | User-facing, hard gate before ANY code | User-facing, right-sized to scope | Internal only (router invokes) |
| **Core philosophy** | "No code without approved design" — absolute | "Right-size ceremony to scope" — pragmatic | "No design without understanding purpose" — structured |
| **Scope assessment** | Detects multi-subsystem → decomposes into sub-projects | Classifies lightweight/standard/deep → adjusts depth | 5 mandatory dimensions + intent completeness gate |
| **Question style** | Open-ended, one at a time, multiple choice preferred | One at a time, single-select preferred, blocks on AskUserQuestion | 5-7 structured dimensions, skip if already answered |
| **Approaches** | 2-3 with trade-offs, then recommendation | 2-3 with pros/cons, present all THEN recommend (avoid anchoring) | 2-3 with trade-offs, skip menu if one clearly best |
| **Incremental validation** | Section-by-section approval | After each design section | 200-300 word sections with check-in |
| **Output artifact** | `docs/superpowers/specs/YYYY-MM-DD-*-design.md` | `docs/brainstorms/*-requirements.md` (or skip doc for lightweight) | `docs/plans/YYYY-MM-DD-*-design.md` + memory update |
| **Self-review** | Placeholder scan, consistency check, scope check | Document-review skill dispatched before handoff | Intent completeness gate (3 checks) |
| **Handoff** | ONLY `writing-plans` (hard-coded) | Flexible handoff options via reference doc | Router decides next phase |
| **Visual companion** | Yes (browser mockups, opt-in) | No | No |
| **Codebase verification** | Follow existing patterns | "Claims of absence must be verified" | Git history + directory scan |
| **Research integration** | None | Optional Slack, learnings-researcher, issue-intelligence | None |
| **Lightweight bypass** | Never — even "simple" projects need design | May skip document for trivial work | N/A (router decides scope) |

**CE also has `ce:ideate`** — a unique upstream step that generates grounded improvement ideas using 3-4 parallel sub-agents before brainstorming even starts. Neither Superpowers nor CC10X has an equivalent.

### Key Tension

Superpowers never lets you skip (prevents rationalization). CE lets you right-size (prevents ceremony overload). CC10X gates on structured dimensions (prevents ambiguity). A unified approach should have: CE's scope classification to decide depth + Superpowers' hard gate to prevent skipping entirely + CC10X's intent completeness gate for quality control.

---

## 2. TDD (Test-Driven Development)

| Aspect | **Superpowers** | **CC10X** | **Matt Pocock** | **ECC** |
|--------|----------------|-----------|-----------------|---------|
| **Iron law** | "No production code without failing test first" | Same + "always use run mode, never watch mode" | "Tests verify behavior through public interfaces" | "Tests BEFORE code" |
| **Slicing** | Vertical (one feature at a time) | Vertical (one feature at a time) | Vertical tracer bullets (first test proves full path) | Test pyramid (unit/integration/E2E) |
| **Red-Green-Refactor** | Detailed flowchart with verification diamonds | Same + git checkpoint commits at each phase | Planning → tracer bullet → incremental loop → refactor after all green | User journeys → test cases → RED → GREEN → refactor → coverage check |
| **Coverage target** | Not quantified (implicit 100%) | **80%+** explicit (statements, branches, functions, lines) | Not quantified | **80%+** explicit |
| **Mocking rules** | "Only if unavoidable" | Boundary-only + factory pattern for test data | Boundary-only (external APIs, DBs, time) + dependency injection | External deps only + specific patterns (e.g., hosted DB clients, caches, LLM APIs) |
| **Process discipline** | Psychological (rationalizations table, 12 red flags) | Process-strict (watch mode ban, process cleanup, checkpoint commits) | Design-focused (planning confirmation, per-cycle checklist) | Best practices (watch mode OK, pre-commit hooks) |
| **Failure handling** | "Test passes immediately? You're testing existing behavior" | Runtime RED vs compile-time RED gates explicitly defined | Per-cycle checklist (behavior? public interface? survives refactor?) | "Tests should fail before implementation" |
| **Loop cap** | Red flags + checklist | Watch mode prohibition + cleanup verification | "Never refactor while RED" | Pre-commit hooks |
| **Delete policy** | Code written before test must be deleted entirely | Same philosophy | Not explicit | Not explicit |
| **Anti-patterns doc** | Separate `testing-anti-patterns.md` | `testing-patterns.md` + `test-data-and-mocks.md` | `tests.md` + `mocking.md` + `interface-design.md` + `deep-modules.md` + `refactoring.md` | Embedded in SKILL.md |
| **Unique strength** | Strongest rationalization prevention | Most prescriptive process (git checkpoints, watch ban) | Deepest design philosophy (deep modules, tracer bullets) | Most complete test pyramid breakdown |

**CE has no dedicated TDD skill** — it signals execution posture ("test-first", "characterization-first") in plan units but doesn't enforce a TDD cycle.

### Best Synthesis

Matt Pocock's "test behavior through public interfaces" as the design philosophy + CC10X's process discipline (checkpoint commits, watch mode ban, 80% coverage) + Superpowers' rationalization prevention (the 12 red flags). ECC's test pyramid (unit/integration/E2E) fills the structural gap none of the others address.

---

## 3. Planning

| Aspect | **Superpowers** | **Compound Engineering** | **CC10X** | **Matt Pocock** |
|--------|----------------|--------------------------|-----------|-----------------|
| **Trigger** | After brainstorming produces a spec | User asks "plan this" or plan invoked by ce:work | Internal (planner agent via router) | User has PRD ready |
| **Task granularity** | **2-5 min steps**, each is ONE action | **2-5 min steps**, task clusters up to 15 min | **2-5 min steps**, explicit iron law | **Coarse-grained phases** (days each) |
| **Code in steps** | **Required** — full code blocks in every step | **Not code** — pseudo-code sketches only when directional | **Not code** — behavioral contracts for critical-path only | **Not code** — durable architectural decisions |
| **Placeholders** | Forbidden ("TBD", "TODO", "add validation" = fail) | Forbidden (same, plus "etc." and "similar") | Forbidden (same + plan-review-gate enforces) | N/A (coarse-grained) |
| **Durable decisions** | Not explicit | Key Technical Decisions section with rationale | **Mandatory** for multi-phase (routes, schema, models, auth, boundaries) | **Mandatory** (routes, schema, models, auth, boundaries) |
| **Dependency tracking** | Implicit in task order | Explicit `Dependencies` field per unit + system-wide impact section | **DAG rule** — phase N depends only on predecessors, cross-phase contracts required | Implicit in vertical slice ordering |
| **Plan review gate** | Self-review checklist (not automated) | Confidence scoring + document-review skill + sub-agent deepening | **Fail-closed spec gate** (3 checks: feasibility, completeness, scope) — max 3 retries | User quiz on phase breakdown |
| **Confidence scoring** | None | Yes (0-100, factors: context refs, edge cases, tests, risks, paths) | Yes (0-100, same factors, <50 = NEEDS_CLARIFICATION) | None |
| **Context references** | In-task file references | Mandatory (relevant code, institutional learnings, external refs) | **Mandatory** with file:line + "Cole Medin Principle" (plan must contain ALL info for single-pass execution) | Optional (focuses on durable decisions, avoids file paths) |
| **Research integration** | None | Phase 1: repo-research, learnings, Slack, best-practices, framework-docs agents | None (internal) | None |
| **Resume/deepen** | Implicit | Explicit resume + "deepen" keyword triggers confidence re-check | N/A | N/A |
| **Output location** | `docs/superpowers/plans/` | `docs/plans/` | `docs/plans/` | `./plans/` |
| **Execution handoff** | Choice: subagent-driven OR inline execution | Flexible (via handoff reference doc) | Router dispatches build agents | User executes |
| **Verification rigor** | Not present | Implicit in depth classification | **Explicit** (`standard` or `critical_path` with behavior contracts, edge-case catalogs, provable properties) | Not present |
| **Risk assessment** | Not present | Optional (Deep plans only): risk/likelihood/impact/mitigation table | **Mandatory** for non-trivial: risk/probability/impact/score/mitigation | Not present |

### Key Tension

Superpowers and CC10X want plans to be executable by agents without questions (code-in-steps for Superpowers, single-pass-execution for CC10X). CE and Matt Pocock want plans to capture decisions while leaving implementation to the builder. Both are valid — the choice depends on whether your team uses AI agents as implementers (need detailed plans) or human developers (need architectural guidance).

**For a mixed AI+human team:** Use CC10X's fail-closed spec gate + CE's research integration + Superpowers' no-placeholders rule. Use Matt Pocock's vertical slicing as the organizing principle.

---

## 4. Code Review

| Aspect | **Superpowers** | **CC10X** | **Compound Engineering** |
|--------|----------------|-----------|--------------------------|
| **Reviewer model** | Single agent (`code-reviewer`) | Single agent (`code-reviewer`) with skill loading | **17+ personas** — 4 always-on + conditional per diff |
| **Always-on reviewers** | N/A (single) | N/A (single) | Correctness, testing, maintainability, project-standards + agent-native + learnings-researcher |
| **Conditional reviewers** | N/A | N/A | Security (auth changes), performance (DB queries), API-contract (routes), data-migrations (schema), reliability (error handling), adversarial (>50 lines), cli-readiness, previous-comments |
| **Confidence threshold** | Not specified | **>=80%** per finding; HARD signals (security, correctness) vs SOFT (perf, maintainability) | **>=0.60** per finding; P0 at 0.50+ survives; cross-reviewer agreement boosts +0.10 |
| **Scoring model** | Severity: Critical/Important/Minor | Signal scores: min(HARD) capped by avg(SOFT)-10 | P0-P3 severity + confidence (0.0-1.0) + autofix_class + owner routing |
| **Zero-finding halt** | Not specified | **Mandatory** — must provide positive-assertion evidence or cap confidence at <=70 | Not explicit (confidence gating handles naturally) |
| **Output format** | Prose (strengths, issues, recommendations, assessment) | `CONTRACT {s, b, cr}` envelope (machine-readable) + prose | Pipe-delimited tables by severity + structured JSON per reviewer on disk |
| **Autofix** | None | None (read-only; router creates remediation tasks) | **Yes** — 3-tier: safe_auto (auto-applied), gated_auto (needs approval), manual (handed off) |
| **Modes** | Single mode | Single mode | Interactive, autofix, report-only, headless |
| **Deduplication** | N/A | N/A | Fingerprinting (file + line +/-3 + title) + agreement boost |
| **Receiving review** | **Yes** — separate `receiving-code-review` skill: verify before implementing, push back if technically wrong, no performative agreement | N/A | N/A |

### Key Insight

The progression is clear: Superpowers = single reviewer, human reads prose. CC10X = single reviewer, machine-readable contract enables automation. CE = orchestrated multi-persona with autofix. For a small team, CE's conditional reviewer selection is powerful — you only pay for security review when auth code changes. But CC10X's zero-finding halt catches lazy reviews that CE doesn't enforce.

---

## 5. Debugging

| Aspect | **Superpowers** | **CC10X (skill + agent)** | **CE** |
|--------|----------------|---------------------------|--------|
| **Iron law** | "No fixes without root cause investigation first" | Same + "no variant coverage skip before RED" | Hypothesis-driven reproduction |
| **Investigation phases** | 4 phases (root cause → pattern analysis → hypothesis → implementation) | **12 mandatory steps** (understand → git → context → logs → variant scan → hypothesis → RED → GREEN → blast radius → verify → prevention → memory) | 5 phases (understand → hypothesize → reproduce → investigate → document) |
| **Hypothesis management** | 1 at a time; form new if previous fails | 2-3 simultaneously, confidence 0-100, proceed only at 80+ | 2-3 by likelihood, not scored |
| **Confidence scoring** | Basic verification | Explicit 0-100 with evidence-for/against tracking | Not formalized |
| **Cognitive bias prevention** | Red flags + human partner signals | Explicit bias table (confirmation, anchoring, availability, sunk cost) + meta-debugging + 30-min freshness check | Implicit ("skeptical but thorough") |
| **Loop cap** | 3 fixes → treat as architectural problem | DEBUG-3 → BLOCKED status + external research request | "Reasonable attempts" (vague) |
| **Blast radius scanning** | Deferred to defense-in-depth doc | **Mandatory step 9** — same-file + adjacent files + tracked results | Not formalized |
| **Anti-hardcode gate** | Not formalized | **Required before RED** — regression test must cover >=1 non-default variant | Not formalized |
| **Variant dimensions** | Not formalized | Locale, config, roles, platform, time, data shape, concurrency, network, caching | Environment-aware but not formalized |
| **TDD integration** | Test-first mandatory | Test-first mandatory + variant coverage + RED/GREEN exit codes | Tests for reproduction only |
| **Supporting docs** | 5 files (root-cause-tracing, defense-in-depth, condition-based-waiting, example, find-polluter.sh) | 2 reference docs + LSP tracing | agent-browser for UI reproduction |
| **Memory persistence** | Stateless | activeContext.md, patterns.md, progress.md | Stateless |
| **Bug classification** | Not explicit | Not explicit | **6 categories** (confirmed bug, cannot reproduce, not a bug, environmental, data issue, user error) |

### Key Insight

CC10X's bug-investigator is the most rigorous debugging framework across all repos. The 12-step mandatory sequence with anti-hardcode gate, blast radius scanning, and variant coverage prevents the most common debugging failure: fixing the symptom you can see while leaving duplicates and edge cases unfixed. Superpowers adds practical tools (find-polluter.sh, condition-based-waiting). CE adds bug classification (useful for triage — is it actually a bug?).

---

## 6. Verification / Completion

| Aspect | **Superpowers** | **CC10X** |
|--------|----------------|-----------|
| **Iron law** | "No completion claims without fresh verification evidence" | Same + self-critique gate first |
| **Audience** | Humans (confrontational, "dishonesty" framing) | Autonomous agents (structured audit) |
| **Steps** | 5: IDENTIFY → RUN → READ → VERIFY → CLAIM | 6: same + REFLECT before claim |
| **Pre-verification** | Implicit (assumes human judgment) | **Self-Critique Checklist** (code quality, completeness, no debug artifacts) |
| **Stub detection** | Mentioned briefly | **Comprehensive** (TODO markers, empty returns, line-count minimums, pattern library) |
| **Wiring checks** | Not explicit | **Explicit** (Component → API → DB verification) |
| **Validation levels** | One standard level | 4 levels (syntax → unit → integration → manual) |
| **Post-verification gate** | None | **Completion Guard** — final gate before Router Contract |
| **Rationalization prevention** | Strongest (confrontational prose, excuses table) | Structural (checklists prevent rather than confront) |

**CE has no dedicated verification skill** — it relies on ce:work's Phase 3 quality checks and ce:review.

### Key Insight

Both enforce the same Iron Law but serve different audiences. Superpowers assumes a human partner and uses confrontational language to prevent rationalization. CC10X is designed for autonomous agents and adds structured pre-verification and post-verification gates, plus exhaustive stub/wiring detection. The overlap is intentional — defense in depth.

---

## 7. Execution / Work / Subagent Management

| Aspect | **Superpowers: executing-plans** | **Superpowers: subagent-driven** | **Superpowers: parallel-agents** | **CE: ce:work** | **CC10X: router** |
|--------|--------------------------------|----------------------------------|----------------------------------|-----------------|-------------------|
| **Session** | Parallel (separate context) | Same session | Same session | Same session | Same session |
| **Input** | Plan file required | Plan file required | Ad-hoc independent tasks | Plan OR bare prompt | Intent routing |
| **Task dispatch** | Manual between tasks | Fresh subagent per task | All at once (parallel) | Inline or subagent | Phase-based agent dispatch |
| **Review gates** | Lightweight (human) | **Two-stage** (spec, then quality) | None | **Tier 1/2** (Tier 2 = full review, default) | Phase contracts + integration-verifier |
| **Complexity routing** | None | None | None | **Auto** (trivial/small/large) | Intent routing (ERROR/PLAN/REVIEW/BUILD) |
| **Test discovery** | None | None | None | **Yes** (finds existing tests first) | None |
| **System-wide test check** | None | None | None | **Yes** (callbacks, middleware, error propagation, parity) | None |
| **Resume** | Implicit | Implementer status (DONE/BLOCKED/NEEDS_CONTEXT) | N/A | Phase 0 resume | UUID-based workflow hydration |
| **Unique strength** | Isolated execution context | Model selection per task + status handling | Pure parallelization | Bare-prompt support + complexity routing | Full orchestration (BUILD/DEBUG/REVIEW/PLAN chains) |

### Key Insight

CE's ce:work is the most practical for a small team — it handles "just do this thing" without requiring a formal plan. CC10X's router is the most powerful orchestrator but requires the full CC10X ecosystem. Superpowers' subagent-driven gives the clearest review discipline (two-stage: spec then quality). A unified approach: CE's complexity routing to decide ceremony level + Superpowers' two-stage review + CC10X's phase contracts for complex work.

---

## 8. Git Worktrees

| Aspect | **Superpowers** | **Compound Engineering** |
|--------|----------------|--------------------------|
| **Entry point** | Direct skill invocation | Manager script (worktree-manager.sh) |
| **Directory selection** | Priority logic (existing → CLAUDE.md → ask) | Always `.worktrees/` |
| **Safety** | .gitignore verification mandatory | .gitignore auto-managed by script |
| **.env handling** | Not mentioned | **Auto-copies** all .env* files |
| **Dev tool handling** | Not mentioned | **Auto-trusts** mise/direnv with branch-aware safety |
| **Project setup** | Auto-detects and runs (npm/cargo/pip/go) | Assumes manual or separate |
| **Baseline verification** | Runs tests, checks for failures | Not explicit |
| **Commands** | Create only | Create, list, switch, cleanup, copy-env |

**CC10X has no dedicated worktree skill** — it delegates to the agent dispatch mechanism.

### Key Insight

CE's .env auto-copying is critical for multi-service projects. With multiple services or platforms, you likely have multiple .env files with API keys, database URLs, etc. Superpowers' approach will leave your worktree broken until you manually copy secrets. CE's manager script handles this automatically.

---

## 9. Memory / Compounding / Stale Management

| Aspect | **CC10X: session-memory** | **CE: ce:compound** | **CE: ce:compound-refresh** |
|--------|---------------------------|---------------------|------------------------------|
| **Purpose** | Runtime durable state for workflows | Document solved problems | Maintain solution docs |
| **What it stores** | Decisions, learnings, references, verification evidence, blockers | Problem + root cause + solution + prevention + what didn't work | Accuracy/staleness/overlap assessments |
| **Trigger** | Every workflow start/resume/key decision | After solving a problem | After refactor, migration, or contradiction detected |
| **Surfaces** | 3 files: activeContext.md, patterns.md, progress.md | 1 doc per problem in `docs/solutions/[category]/` | Bulk review of docs/solutions/ |
| **Ownership** | Router-owned (agents emit MEMORY_NOTES, router persists) | Orchestrator writes (4 parallel sub-agents in Full mode) | Autofix or interactive |
| **Distillation** | Index not transcript — decisions & learnings only | Full research (context analyzer, solution extractor, related docs finder, session historian) | Evidence-based judgment (5 outcomes: keep/update/consolidate/replace/delete) |
| **Staleness handling** | Not addressed (files overwritten per workflow) | Phase 2.5: selective refresh check after doc creation | **Core purpose** — 10 rules for evidence-based maintenance |
| **Overlap detection** | Not addressed | **High/moderate/low** overlap assessment; high = update existing, not create duplicate | Consolidation as one of 5 outcomes |
| **Auto-heal** | Yes — inserts missing sections automatically | Not applicable | Not applicable |
| **Discoverability** | Assumed (CC10X agents always load memory) | **Checks** whether AGENTS.md/CLAUDE.md surfaces docs/solutions/ to future agents | Not addressed |

**Superpowers has no memory/compounding system** — it's stateless by design.

### Key Insight

These three are sequential, not competing:
1. **CC10X session-memory** = runtime state (within a workflow)
2. **CE ce:compound** = knowledge capture (after solving)
3. **CE ce:compound-refresh** = knowledge maintenance (over time)

This is the compound knowledge loop: solve → capture → maintain → surface to future sessions. No single repo implements all three. A unified methodology needs all three layers.

---

## Summary: Best Foundation Per Phase

| Phase | Best Foundation | Why | What to Add From Others |
|-------|----------------|-----|-------------------------|
| **Brainstorming** | CE (pragmatic scope routing) | Right-sizes ceremony; has ideation upstream | Superpowers' hard gate + CC10X's intent completeness gate |
| **TDD** | CC10X (process discipline) | Git checkpoints, watch ban, 80% coverage | Matt Pocock's design philosophy + Superpowers' rationalizations table |
| **Planning** | CC10X (fail-closed gate) | Spec gate prevents bad plans from shipping | CE's research integration + Matt Pocock's vertical slicing + Superpowers' no-placeholders |
| **Code Review** | CE (multi-persona) | 17 reviewers, autofix, conditional selection | CC10X's zero-finding halt + Superpowers' receiving-review pushback protocol |
| **Debugging** | CC10X (12-step agent) | Anti-hardcode gate, blast radius, variant coverage, memory | Superpowers' practical tools (find-polluter.sh) + CE's bug classification |
| **Verification** | CC10X (structural) | Self-critique gate, stub detection, wiring checks, completion guard | Superpowers' confrontational rationalization prevention for humans |
| **Execution** | CE's ce:work (practical) | Bare-prompt support, complexity routing, test discovery | Superpowers' two-stage review + CC10X's phase contracts for complex work |
| **Worktrees** | CE (automation) | Manager script, .env auto-copy, dev tool trust | Superpowers' baseline test verification |
| **Memory** | All three (sequential) | session-memory (runtime) → compound (capture) → refresh (maintain) | Need all three as layers |
