# Professor Review: Brand-Meta-Framework `/letsgo` Skill

> This document captures all findings from the 3-professor expert review + 2-reviewer quality audit of the brand-meta-framework. Use this as the single source of truth for what was found, what was fixed, and what still needs fixing.

## Current State of Files

Plugin files in the repo root:

```
agentic-kit/
  skills/letsgo/
    SKILL.md                          — 187 lines, main skill definition
    references/
      brainstorm-template.md          — 172 lines, artifact template (full + lightweight)
      section-guide.md                — 228 lines, 6-section dialogue guidance
      failure-modes.md                — 146 lines, dev-only failure catalog (NOT loaded at runtime)
  agents/
    code-explorer.md                  — 97 lines, codebase analysis agent
    docs-explorer.md                  — 115 lines, documentation + external research agent
    brainstorm-reviewer.md            — 83 lines, independent review subagent
```

**Total: 1,028 lines across 7 files** (down from ~1,162 after reviewer fixes on 2026-04-10).

The user's methodology spec has been split into focused files:
- `sources.md` — Overview, tech stack, repo summaries
- `architecture.md` — Design principles, skill/agent tables, artifact structure, handoff pattern
- `engineering-standards.md` — Rules tables for building skills & agents
- `skill-specs.md` — Per-aspect behavioral picks for /letsgo, /plan, TDD + placeholders for remaining 6 phases
- `claude-md-requirements.md` — What must go in the project's CLAUDE.md
- `compare.md` — 9-phase comparison tables across all source frameworks
- `professors.md` — THIS FILE (all expert findings, web research)

---

## Previous Expert Rounds (R1 & R2) — from my-view.md

> Before the 3 professors, there were 2 earlier expert review rounds that produced the Engineering Standards section in my-view.md. Their findings were already applied to the skill files. This section preserves that synthesis record.

**Applied on 2026-04-10.** Synthesized from 3 experts (Context Engineering, Prompt Compliance, Workflow Architecture), each producing complete rewrites.

**File sizes after R1/R2 application:**

| File | Lines | Budget | Status |
|------|-------|--------|--------|
| `skills/letsgo/SKILL.md` | 173 | 200 | All 17 SKILL.md changes applied |
| `skills/letsgo/references/section-guide.md` | 159 | — | All 4 section-guide changes applied |
| `skills/letsgo/references/brainstorm-template.md` | 113 | — | All 6 template changes applied |
| `agents/code-explorer.md` | 93 | 120 | 15-file budget + attribution rule |
| `agents/docs-explorer.md` | 103 | 120 | `.docs/plans/` fix + condensed escalation |

**Key architectural decisions from R1/R2 synthesis:**
- HARD-GATEs consolidated with `name` attributes (Expert 3) — referenceable, prominent
- Violation examples on all 4 gates (Expert 2) — makes constraints checkable
- "Be a thinking partner" uses sub-bullet format (Expert 2) — readable behavioral anchors
- Sycophancy resistance includes concrete "test" statement (Expert 2) — detects drift
- Agent failure handling with example warning message (Expert 3) — explicit gap-noting
- Mid-dialogue draft persistence specifies WHEN/WHAT/WHERE/HOW-to-resume (Expert 3)
- Artifact-before-handoff includes Glob verification step (Expert 3) — failsafe
- Rationalization Prevention table at end of SKILL.md (Expert 1) — token-efficient placement
- Adversarial posture in self-review (Expert 3) — "find flaws, not confirm quality"

**External review findings from R1/R2:**
- Slug timing bug: added "Generate artifact identifiers early" rule to Artifact Design
- Agent search procedures: added "Agents must encode search procedures, not just responsibilities" to Agent Design
- File budget for all agents: strengthened to explicitly include docs-explorer
- Independent artifact review: upgraded Self-Review rule from "consider" to "required for standard/deep"
- User review gate: added as Workflow Pattern with CE and Superpowers references
- Build consumers first: added as Workflow Pattern to prevent hypothetical handoff contracts
- Lightweight ceremony tradeoff: documented deliberate choice + throughput monitoring guidance in Hard Gates

---

## What the 3 Professors Did

Three Opus-model "professors" independently rewrote all brand-meta-framework files, each from a different angle. The files on disk represent Professor 3's final pass (which explicitly kept the best elements from Professors 1 and 2).

### Professor 1: Context Engineering & LLM Behavior
- Kept SKILL.md under 200-line budget
- Progressive disclosure: section-guide.md loads ONLY for standard/deep scope
- Named hard gates with `<HARD-GATE name="G1-agent-dispatch">` format + violation IDs
- Created `brainstorm-reviewer.md` as a separate Sonnet subagent (fixes known issue #1)
- Structured agent output formats (tables, numbered findings) for reliable Sonnet production
- Token-efficient placement of rationalization prevention table
- Research applied: Anthropic context engineering ("smallest set of high-signal tokens"), Columbia AI docs study (8K char limit per file)

### Professor 2: Process Discipline & Anti-Fragility
- Added 7-item rationalization prevention table with detection+correction columns
- Added turn budgets per scope tier (3/5/7 exchanges per section) with overflow protocol
- Added circuit breaker: 3+ backward unlocks triggers scope reassessment
- Added Contradiction Detection Protocol in section-guide.md
- Created `failure-modes.md` — 19 failure modes with detection/recovery
- Added recovery protocols for every phase (agent failure, session crash, contradictory input)
- Added `resume_from` field in YAML frontmatter for mid-dialogue persistence
- Research applied: Silicon Mirror framework (85.7% sycophancy reduction), NeuralTrust circuit breakers, Arize AI agent failure patterns

### Professor 3: DX & Multi-Platform Practicality
- Lightweight S5+S6 exception (Sections 5+6 can be combined for lightweight scope)
- Clear-requirements fast-exit (Phase 0.3) for users with fully formed requirements
- Integration complexity modifier: third-party service work = minimum standard scope
- Cross-platform contract detection in code-explorer agent (step 4b)
- "Prior Decisions That Constrain This Work" highlighted output section in docs-explorer
- Added "Team-readable artifacts" as 5th core principle
- Removed Decision Register (duplicated section content, replaced by inline R-IDs and D-IDs)
- Added Cross-Platform Contracts and Integration Points subsections to Affected Systems
- Research applied: Anthropic 2026 Agentic Coding Trends, startup ceremony-to-value findings

---

## Detailed Design Decisions (from HTML comments in files — will be stripped)

These are the per-file design notes the professors embedded as HTML comments. Preserved here before stripping.

### SKILL.md — Professor 2 final synthesis
Incorporates best elements from all three professors:
- **P1:** Named gates with violation IDs, front-loaded dispatch prompts, lean prose, `resume_from`
- **P2:** Rationalization Prevention with detection+correction, circuit breakers, recovery protocols, failure mode catalog (`references/failure-modes.md`), subagent review, Decision Register
- **P3:** Lightweight S5+S6 exception, clear-requirements fast-exit, integration complexity modifier, cross-platform contract awareness, team-readability principle, inline D-IDs
- Process discipline additions: turn budgets with overflow protocol, 7-item rationalization table, explicit recovery for every phase, subagent spot-check of codebase claims, backward unlock limit

### brainstorm-template.md — Professor 3 changes
**KEPT from Prof 2:** Stable requirement IDs (R1, R2...), `resume_from` field, requirement grouping by theme, "no retroactive weakening" rule, alternatives from different axes, agent coverage in Research Context, R-ID tags on Open Questions, implementing agent test.
**CHANGED:**
1. **Removed Decision Register** — it duplicates section content and requires constant sync. Inline R-IDs and D-IDs in each section provide the same traceability without a shadow copy that drifts. If `/plan` needs a summary, it reads the Requirements + Success Criteria sections which ARE the authoritative source.
2. **Added Cross-Platform Contracts subsection** to Affected Systems — forces explicit identification of shared types, API shapes, and data formats consumed across platforms. This is the #1 multi-platform brainstorm gap: changing a backend API without considering how cross-platform consumers depend on it.
3. **Added Integration Points subsection** for third-party services — separates "systems we control" from "systems we don't control" (different risk profiles entirely).
4. Research Context requires explicit **"what was NOT searched"** alongside findings.
5. Lightweight template further streamlined — R-IDs in Scope + Success Criteria sections, no separate Requirements section, no Decision Register.
6. Added writing rules: affected systems is not a checklist (omit non-involved systems); team-readable (write for the absent teammate).
7. **D-IDs (D1, D2...)** inline in Chosen Approach and Constraints sections — decision traceability without a separate register.

### section-guide.md — Professor 3 changes
**KEPT from Prof 2:** Contradiction Detection protocol, turn budget overflow protocol, failure modes per section, challenge approach from different axis, R-ID traceability in Section 6, mid-dialogue draft triggers, R-IDs assigned in Section 2, section lock durability, Rationalization Prevention table.
**CHANGED:**
1. **Section 3 (Affected Systems) restructured** into three subsections: Direct Changes, Cross-Platform Contracts, Integration Points — forces multi-platform thinking that was previously optional free-text. Core DX improvement: when a backend API changes, the framework now REQUIRES identifying mobile and frontend consumers.
2. Mid-dialogue draft triggers moved to **after Section 2 and after Section 4** (earlier protection, matching SKILL.md Phase 3).
3. Removed Decision Register references from unlock protocol — IDs are inline in sections.
4. Section 5 contradiction check now specifically calls out **cross-platform contract risks**.
5. Section 6 completeness check verifies **cross-platform coverage**: if Section 3 lists a consumer, Section 6 must have a criterion for that consumer's behavior.
6. Lightweight S5+S6 combination guidance added — matching SKILL.md G3 exception.

### code-explorer.md — Professor 3 changes
**KEPT from Prof 2:** "What Was NOT Found" section, grep hit count logging, MAP.md fallback, attribution rule (model-knowledge labeled), coverage reporting, claims-of-absence protocol, budget overflow behavior.
**CHANGED:**
1. **Added cross-platform contract detection as step 4b** — when a backend API or shared type is found, actively search for consumers in other parts of the codebase. The #1 gap in multi-platform work: changing a producer without knowing consumers.
2. Added **"Cross-Platform Contracts" output section** — makes contract relationships visible to the brainstorm skill as structured data, not buried in prose.
3. Added **integration pattern detection** — when third-party service code is found, note the SDK version, auth method, error handling, retry patterns. Gives the brainstorm concrete facts about existing integrations instead of assumptions.
4. Each finding gets a **"why it matters" annotation** — the caller shouldn't have to interpret raw facts. The agent knows the context; it should explain relevance.

### docs-explorer.md — Professor 3 changes
**KEPT from Prof 2:** `.docs/plans/` access rule (completed = reference), principle-based escalation heuristic, grep hit count logging, "What Was NOT Found" output section, site discovery protocol, three-tier attribution, coverage reporting, stale-info dates.
**CHANGED:**
1. External research persistence rule **tightened** — ONLY persist when the finding is reusable AND the topic is a third-party service. Internal architecture decisions don't need `.docs/researches/` files.
2. Added **"Prior Decisions That Constrain This Work"** as a highlighted output subsection — the #1 value of docs-explorer is surfacing existing decisions that the brainstorm must respect. Burying these in a generic "Key Findings" list means they get overlooked.
3. Synthesis priority order adds **"cross-cutting constraints"** (e.g., CLAUDE.md rules that apply broadly) as first priority — these override everything else.
4. Each finding gets a **"relevance" annotation**: direct constraint vs. background context. The brainstorm skill shouldn't have to judge which findings are blocking.
5. External research section now explicitly covers the project's third-party services — the dispatch prompt from `/letsgo` names the specific service and aspect to research, making the agent's external search targeted rather than broad.

### brainstorm-reviewer.md — Professor 3 changes
**KEPT from Prof 2:** Adversarial posture, 6-check structure (remapped to 5), cold-read test as Critical finding, severity tiers, PASS/FAIL verdict, read-only tools, spot-check claims of absence, specificity rule, no false positives rule.
**CHANGED:**
1. **Merged Decision Register check into Consistency (check 2)** — since Prof 3 removed the Decision Register section, the reviewer checks ID consistency across sections instead of a separate register.
2. Added **cross-platform contract check to Completeness** — if Affected Systems lists consumers of a changed contract, Success Criteria must verify consumer behavior. This is the multi-platform gap this review catches.
3. Added **team-readability check to Handoff Readiness** — "Could a teammate NOT in the conversation understand this?" is distinct from "/plan can operate from this."
4. Tightened output format — each finding gets a **concrete FIX suggestion**, not just a problem statement. The authoring agent shouldn't have to figure out the fix.
5. Kept to **5 checks (not 6)** — combining register check + consistency check reduces review time without losing coverage.

### failure-modes.md — Professor 2 (NEW FILE)
NOT loaded during normal execution — this is a reference for:
- Skill authors iterating on the framework
- Debugging when something goes wrong
- Training material for understanding the framework's safety model

Informed by web research on:
- AI agent failure modes (hallucination, drift, scope creep, sycophancy, cascading failure)
- Circuit breaker patterns for agentic AI
- Anti-sycophancy techniques (Silicon Mirror framework, CAUSM, behavioral gating)
- Session crash recovery and context loss mitigation
- Guardrail enforcement at framework level vs. prompt level

---

## What the 2 Reviewers Found

### Reviewer 1: writing-skills methodology (Superpowers)

**Verdict: Strong — needs targeted improvements.**

Key findings:
- **S-1 (Medium):** Agents live in `agents/` outside the skill directory. Skill is not self-contained/portable. **Fix:** Move to `skills/letsgo/agents/`.
- **T-1 (Major):** Total 9,815 words is 2-3x larger than CE (~4,675) or Superpowers (~3,352). Compression opportunities exist.
- **T-3 through T-9 (Minor):** HTML professor comment blocks in ALL 7 files waste ~800-1200 tokens. **Fix:** Remove all `<!-- Professor ... -->` comments.
- **T-2 (Medium):** Rationalization Prevention table duplicated in SKILL.md (7 items) AND section-guide.md (4 items). **Fix:** Keep canonical in SKILL.md only.
- **Q-3 (Minor):** Phase 0.3 clear-requirements fast-exit skips Phase 3 but Phase 5 needs content for all sections. **Fix:** Add guidance on mapping pre-formed requirements to template sections.
- **P-1 (Medium):** No process flowchart despite 7-phase flow with branches. Superpowers includes a DOT graph. **Fix:** Add graphviz flowchart.
- **P-2 (Minor):** Phase 6 option 3 references `/worker` which doesn't exist yet. **Fix:** Change to "Execute directly in this session" or remove.

Praised: Hard gates with violations (best-in-class), mid-dialogue persistence (novel), anti-anchoring gate (corrects Superpowers weakness), instruction hierarchy statement, rationalization prevention table.

### Reviewer 2: skill-creator methodology (Matt Pocock)

**Verdict: Strong but over-engineered. Not yet production-ready.**

Key findings:
- **Issue 3 (SKILL.md 79-89 + section-guide.md 65-73):** Duplicate rationalization table. **Fix:** Single canonical location.
- **Issue 4 (SKILL.md 113-114):** Fast-exit under-specified — what goes in the artifact if Phase 3 is skipped? **Fix:** Add mapping guidance.
- **Issue 5 (SKILL.md 137):** "Exchange" in turn budgets is undefined. **Fix:** Define as "1 assistant question + 1 user response."
- **Issue 6 (SKILL.md 165):** Reviewer dispatch doesn't specify how to find template path. **Fix:** Include template path in dispatch prompt.
- **Issue 7 (SKILL.md 166-171):** Warning/Suggestion handling after review unspecified. **Fix:** "Critical: fix + show user. Warnings: fix silently. Suggestions: note for user."
- **Issue 8 (SKILL.md 188):** `/worker` dead link. **Fix:** Remove or clarify.
- **Issue 9 (code-explorer.md 40):** "likely directories" is vague. **Fix:** Explicit list: `src/`, `app/`, `lib/`, `packages/`.
- **Over-engineered:** Turn budgets per section (Sonnet can't count accurately), 7-item rationalization table (3-4 high-value entries would suffice), mid-dialogue persistence (complex for a low-probability event), failure-modes.md (dev documentation, not runtime).
- **Missing:** Non-software task handling (CE has universal-brainstorming.md), YAGNI principle, platform question tools (AskUserQuestion), decomposition guidance, visual communication in artifacts.

Praised: Same items as Reviewer 1 plus cross-platform contract analysis, separate reviewer agent, instruction hierarchy.

---

## Consolidated Fix List

### Must Fix (both reviewers agree) — ALL APPLIED 2026-04-10

| # | Issue | Fix | Status |
|---|-------|-----|--------|
| 1 | HTML professor comments in all 7 files (~1200 tokens waste) | Stripped all comment blocks | DONE |
| 2 | Rationalization table duplicated | Canonical in SKILL.md, section-guide references it | DONE |
| 3 | Clear-requirements fast-exit under-specified | Added template mapping guidance + lightweight template | DONE |
| 4 | Reviewer dispatch missing template path | Added `references/brainstorm-template.md` to dispatch | DONE |
| 5 | Warning/Suggestion handling unspecified | Added Critical/Warning/Suggestion handling rules | DONE |
| 6 | `/worker` dead link in Phase 6 | Changed to "Proceed with implementation in this session" | DONE |
| 7 | Description missing intent-based triggers | Added "help me think through", "not sure how to approach", "I want to brainstorm" | DONE |

### Should Fix (one or both reviewers flagged) — PARTIALLY APPLIED 2026-04-10

| # | Issue | Fix | Status |
|---|-------|-----|--------|
| 8 | Agents live outside skill directory | **KEPT as-is** — agents shared across skills, stay in `agents/` | WON'T FIX |
| 9 | No process flowchart for 7-phase flow | Deferred — would push SKILL.md over 200-line budget | DEFERRED |
| 10 | Turn budget "exchange" undefined | Defined: "1 assistant message + 1 user response" | DONE |
| 11 | code-explorer "likely directories" is vague | Replaced with dynamic: `ls` repo root to discover structure | DONE |
| 12 | docs-explorer persistence rule too subjective | Already specific enough after professor rewrites | WON'T FIX |
| 13 | No non-software task handling | Deferred — CE has universal-brainstorming.md but not needed yet | DEFERRED |
| 14 | No YAGNI principle | Added 3 principles: YAGNI, Prefer extending over inventing, Single-responsibility scoping | DONE |
| 15 | failure-modes.md position | **KEPT in references/** — dev docs belong with the skill they describe | WON'T FIX |

### What Both Reviewers Praised (keep these)

- Hard gates with named violations (G1-G4) — "best-in-class pattern"
- Subagent reviewer in fresh context — fundamentally better than inline review
- Cross-platform contract analysis — "genuine innovation"
- Mid-dialogue persistence — "novel and useful"
- Anti-anchoring gate (G2) — "corrects a specific weakness in Superpowers"
- Instruction hierarchy statement — "CE and Superpowers should adopt this"
- Failure mode catalog — "shows deep thinking" (even if dev-only)
- Rationalization prevention table — directly aligned with writing-skills methodology
- Three specialized agents with structured output formats
- Circuit breaker for cascading unlocks

---

## What CE and Superpowers Have That We Don't (Gaps to Consider)

### From CE
- **Non-software brainstorming** — universal-brainstorming.md for non-code tasks
- **Platform question tools** — AskUserQuestion, request_user_input
- **Product pressure test** — explicit "Is this the right problem?" phase
- **YAGNI with nuance** — "Apply YAGNI to carrying cost, not coding effort"
- **Visual communication guidance** — when to include diagrams in artifacts
- **Lighter artifact option** — skip document entirely for trivial alignment
- **External sharing** — Share to Proof (not relevant for us)
- **Document review as separate reusable skill** — our reviewer is brainstorm-specific

### From Superpowers
- **Visual companion** — full browser-based mockup system (we stripped to opt-in ASCII)
- **Process flowchart** — DOT graph for execution flow
- **Checklist format** — TodoWrite-driven numbered steps (more trackable)
- **Design doc git commit** — we write to disk but don't commit
- **Terminal state clarity** — "The terminal state is invoking writing-plans" (we have 3 options)
- **Existing codebase guidance** — "Follow existing patterns. Where problems affect work, include targeted improvements."

---

## Web Research (all sources — original + professor-discovered)

### Industry Best Practices (original research)
- [Addy Osmani — AI Coding Workflow](https://addyosmani.com/blog/ai-coding-workflow/) — Spec before code ("waterfall in 15 min"), 70% planning/verification + 30% execution, tests at every stage, multi-model code review
- [Compound Engineering (Every.to)](https://every.to/guides/compound-engineering) — Plan 40% → Work 10% → Review 40% → Compound 10%. Developer as orchestrator. "Plans are the new code"
- [Spec-Driven Development](https://prommer.net/en/tech/guides/spec-driven-development/) — Specifications as source of truth, code as secondary artifact. Requirements → Design → Tasks → Implementation
- [Context Engineering (Anthropic)](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) — "Find the smallest set of high-signal tokens." Just-in-time context, progressive disclosure, sub-agent architectures
- [AI Agents and Docs (Columbia University)](https://daplab.cs.columbia.edu/general/2026/03/31/your-ai-agent-doesnt-care-about-your-readme.html) — Global files waste tokens. Hierarchical per-directory context wins. 8K char limit per file
- [Multi-Agent Development (Addy Osmani)](https://addyosmani.com/blog/code-agent-orchestra/) — Parallel subagents for review, 10-15 worktree sessions simultaneously, 18% throughput improvement
- [Forcing Claude Code to TDD](https://alexop.dev/posts/custom-tdd-workflow-claude-code-vue/) — Custom TDD workflow with Vue and Claude Code hooks
- [Simon Willison — Red/Green TDD](https://simonwillison.net/guides/agentic-engineering-patterns/red-green-tdd/) — Red/green TDD as a core agentic engineering pattern
- [The 80% Problem in Agentic Coding](https://addyo.substack.com/p/the-80-problem-in-agentic-coding) — Why AI gets 80% right but the last 20% needs human judgment
- [Martin Fowler — Context Engineering](https://martinfowler.com/articles/exploring-gen-ai/context-engineering-coding-agents.html) — How context shapes coding agent quality more than model choice
- [Parallel AI Dev with Git Worktrees](https://medium.com/@ooi_yee_fei/parallel-ai-development-with-git-worktrees-f2524afc3e33) — Practical guide to running multiple AI sessions in isolated worktrees
- [Anthropic — 2026 Agentic Coding Trends](https://resources.anthropic.com/hubfs/2026%20Agentic%20Coding%20Trends%20Report.pdf) — Industry report on agentic coding adoption and patterns
- [AWS — ADR Best Practices](https://aws.amazon.com/blogs/architecture/master-architecture-decision-records-adrs-best-practices-for-effective-decision-making/) — Architecture Decision Records for capturing design rationale
- [CE Plugin docs/](https://github.com/EveryInc/compound-engineering-plugin/tree/main/docs) — Compound Engineering plugin documentation and workflow reference
- [CE Workflow (Mintlify)](https://www.mintlify.com/EveryInc/compound-engineering-plugin/plugin/workflow) — Interactive CE workflow documentation

### Professor-Discovered Sources

**Context Engineering:**
- Morphllm — 2 surgical files at <50K tokens outperform 500K tokens of noise

**Process Discipline & Anti-Sycophancy:**
- [Silicon Mirror: Dynamic Behavioral Gating](https://arxiv.org/html/2604.00478) — 85.7% sycophancy reduction
- [Reducing LLM Sycophancy](https://sparkco.ai/blog/reducing-llm-sycophancy-69-improvement-strategies) — 69% improvement with counter-instructions
- [NeuralTrust: Circuit Breakers for AI Agents](https://neuraltrust.ai/blog/circuit-breakers)
- [Arize: Why AI Agents Break](https://arize.com/blog/common-ai-agent-failures/) — common production failures
- [Concentrix: 12 Failure Patterns](https://www.concentrix.com/insights/blog/12-failure-patterns-of-agentic-ai-systems/)
- [DEV: AI Agent Guardrails](https://dev.to/aws/ai-agent-guardrails-rules-that-llms-cannot-bypass-596d)
- [Codified Context](https://arxiv.org/html/2602.20478v1) — infrastructure for AI agents in complex codebases

**DX & Practical Workflows (from Anthropic 2026 report):**
- 60% of work involves AI but only 0-20% is fully delegated
- 3-5 parallel worktrees is the practical upper bound
- Ceremony overhead is the #1 adoption killer for startup teams

---

## Context for Post-Compact Continuation

### What We've Done So Far
1. Inventoried all 5 source repos (Superpowers, CE, CC10X, Matt Pocock, ECC)
2. Compared all 9 overlapping phases side-by-side (in `export.md`)
3. Made per-aspect picks for Brainstorming, TDD, and Planning phases (in `my-view.md`)
4. Built the brand-meta-framework with `/letsgo` skill, 2 agents, brainstorm template, section guide
5. Ran 3 expert professors to improve all files (Context Engineering, Process Discipline, DX)
6. Ran 2 quality reviewers (writing-skills methodology, skill-creator methodology)
7. Documented all findings in this file (`professors.md`)

### What Needs to Happen Next
1. ~~**Apply the 7 "must fix" items**~~ — DONE (2026-04-10). Also applied should-fix #10, #11, #14.
2. ~~**Decide on "should fix" items**~~ — DONE. #8, #12, #15 won't fix. #9, #13 deferred.
3. **Continue with remaining phases** — Code Review, Debugging, Verification, Execution, Worktrees, Memory per-aspect picks (not yet started)
4. **Build `/plan` skill** — spec in `skill-specs.md` section 2
5. **Build TDD internal skill** — spec in `skill-specs.md` section 3
6. **Build remaining skills** — Code Review, Debugging, Verification, Execution, Worktrees, Memory (comparison tables in `compare.md`, placeholder summaries in `skill-specs.md` sections 4-9)
7. **Write actual CLAUDE.md** — requirements in `claude-md-requirements.md`
8. **Testing** — user said "I will do it later no need for testing now"

### Key Files to Read After Compact
- `professors.md` — THIS FILE (all expert findings, fix lists, web research)
- `sources.md` — Overview, tech stack, repo summaries
- `architecture.md` — Framework structure decisions
- `engineering-standards.md` — Rules tables for building skills & agents
- `skill-specs.md` — Per-aspect behavioral picks for each skill
- `claude-md-requirements.md` — What must go in project CLAUDE.md
- `compare.md` — 9-phase comparison tables across source frameworks
- `brand-meta-framework/` — current implementation

### User Preferences
- Uses `.docs/` (hidden) for workflow artifacts, NOT `docs/`
- Has `tree` command available (macOS)
- Has `rtk` installed (token-optimized CLI proxy)
- Wants educational insights (explanatory output style)
- Works well for teams that ship fast across multi-platform projects
- Designed to handle projects with many third-party service integrations
