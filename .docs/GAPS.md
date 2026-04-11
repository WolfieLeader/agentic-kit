# Gap Analysis: TIPS.md vs FRAMEWORK.md (Round 2)

> Reviewed 2026-04-11. Based on research-validated TIPS.md and FRAMEWORK.md v0.1.
>
> Scope: Claude Code, Claude models (Haiku 4.5, Sonnet 4.6, Opus 4.6), English language.

---

## What FRAMEWORK.md Gets Right

Core philosophy is sound:

- **Disk as handoff** — artifacts survive compaction, context rot is sidestepped
- **Tier-scaled ceremony** — light gets light, the grug way
- **Explorers before classification** — structural anti-anchoring, not just instructional
- **TDD as iron law** with 3-fix circuit breaker
- **Knowledge compounding** — retro -> propose -> evolve
- **Evidence-before-claims** verification
- **Anti-sycophancy** in review feedback
- **Model routing** — Sonnet for read-heavy, Opus for code
- **Confidence gating** on review findings
- **Fresh-context review** via separate review agents in polish
- **Checkpoint summary pattern** — caps questions at ~5 per round, mitigates lost-in-the-middle

---

## Gaps

### 1. Agent Voice — No Unified Template

Source: TIPS.md $4 (Output Compression), $16 (Skill And Agent Design).

Output tokens cost 5x input. Every framework agent produces output, none have explicit brevity constraints.

Three levers, all unset:

| Lever | What it does | Current state |
|-------|-------------|---------------|
| **Persona** | Competent identity -> better reasoning distribution | Agents have roles but no trait framing |
| **Output format** | Structured constraints -> compressed output | Explorers have structure, others don't |
| **Token budget** | Measurable compression | No per-agent budgets |

The caveman approach (~65% savings) saves tokens but degrades reasoning by shifting the model toward simpler thinking. TIPS.md $16 says: separate output format (terse, structured) from identity (competent, precise) — these are independent levers.

The right approach: a smart, direct persona. Expert who values time, uses no filler, appreciates conciseness. Think professor, not caveman — same compression, preserved reasoning.

Recommendation:

- Define an agent voice template inherited by every agent: one-line persona + output format + token budget.
- Persona pattern: "[Role]. Expert, direct, no filler. [domain-specific trait]."
- Explorer findings: <500 tokens. Review findings: <200 tokens per issue. Craft status: <100 tokens.
- Reference: `.inspiration/other/caveman/` for the output format techniques (drop articles, fragments OK, short synonyms). Apply them to a competent identity, not a dumb one.

Priority: **High**. Affects every agent prompt and has direct cost impact.

### 2. Positive Framing for Hard Gates

Source: TIPS.md $16 (Instruction Framing — positive instructions followed more reliably than negative).

FRAMEWORK's hard gates are all negative:

| Current (negative) | Proposed (positive) |
|---|---|
| NO-CODE-BEFORE-DESIGN | DESIGN-THEN-CODE |
| NO-RECOMMENDATION-BEFORE-OPTIONS | OPTIONS-THEN-RECOMMEND |
| NO-FIX-WITHOUT-ROOT-CAUSE | INVESTIGATE-THEN-FIX |
| NO-CODE-WITHOUT-FAILING-TEST | TEST-THEN-CODE |
| "Never refactor while RED" | "Refactor only when GREEN" |

Priority: **High**. Affects all hard gates and rationalization tables.

### 3. Per-Phase Gotchas

Source: TIPS.md $16 — "common gotchas per domain are more actionable than abstract principles."

Each phase should include 2-3 specific failure modes agents commonly hit:

- **Router:** "Agents classify everything as lightweight to avoid ceremony"
- **Sketch:** "Agents anchor on the first approach" (handled by anti-anchoring — good)
- **Blueprint:** "Agents include implementation code in behavioral descriptions"
- **Craft:** "Agents write tests that test implementation details, not behavior"
- **Polish:** "Agents claim tests pass without running them"
- **Retro:** "Agents write generic retrospectives instead of specific technical findings"

Priority: **High**. More actionable than abstract principles.

### 4. Task Structure in Craft Dispatch

Source: TIPS.md $9 (Google Research study, Kim & Liu Jan 2026).

Google Research found task structure matters more than task size for multi-agent decisions:

- Parallelizable tasks: +80.9% with multi-agent.
- Sequential tasks: 39-70% degradation with multi-agent.

FRAMEWORK routes to subagents based on tier (complexity). But a "standard" task with 3 tightly coupled, sequentially dependent units may perform worse with subagents than inline execution.

Recommendation:

- Add task structure assessment to craft dispatch: "Are implementation units truly independent?"
- If units have sequential dependencies (unit B depends on unit A's output), prefer inline or sequential dispatch.
- Subagents only when units can be worked in parallel without coordination.
- Blueprint should flag unit independence explicitly (already has "Dependencies" field — surface it as a dispatch signal).

Priority: **High**. Directly affects craft dispatch for std/deep.

### 5. Hard Gate Compliance Gap

Source: TIPS.md $5 (Instruction Compliance ~60-70%), $6 (Hooks achieve deterministic compliance).

FRAMEWORK's 7 hard gates are instruction-based. TIPS.md reports ~60-70% instruction compliance. The most critical gates need enforcement beyond instructions.

Hookable hard gates (enforceable via PreToolUse/PostToolUse):

| Gate | Hook approach |
|---|---|
| ARTIFACT-BEFORE-HANDOFF | PostToolUse: verify file exists before phase transition |
| EVIDENCE-BEFORE-CLAIMS | PostToolUse: check for test/build output before completion claim |
| TEST-THEN-CODE | PreToolUse: track test runs, warn if Edit called without recent test failure |

Non-hookable gates (require judgment, stay as instructions):

| Gate | Why not hookable |
|---|---|
| DESIGN-THEN-CODE | "Design" is a judgment call, not a file check |
| OPTIONS-THEN-RECOMMEND | Requires understanding content, not just structure |
| INVESTIGATE-THEN-FIX | Investigation is subjective |

Recommendation:

- Acknowledge the compliance gap in the framework.
- Move hookable hard gates to the v1 hooks list (currently only SessionStart, PreCompact, Stop).
- Keep non-hookable gates as instructions with violation examples.

Priority: **High**. Three of 7 hard gates can go from ~65% to 100% compliance.

### 6. Coding-Specific Multi-Agent Limits

Source: TIPS.md $9 (Anthropic — "most coding tasks involve fewer truly parallelizable tasks than research").

FRAMEWORK's std/deep pipeline assumes implementation units are parallelizable. Many coding tasks have sequential dependencies, shared state, or overlapping files.

Recommendation:

- Document when parallel craft dispatch is appropriate (disjoint files, independent modules, no shared state).
- Default to sequential craft dispatch; parallel is an optimization.
- Blueprint should flag unit independence explicitly.

Priority: **Medium**. Overlaps with gap #4 but worth a separate framework note.

### 7. No Haiku in Model Routing

Source: TIPS.md $12 (Model Routing).

FRAMEWORK only uses Sonnet 4.6 and Opus 4.6. Haiku 4.5 is absent.

Haiku candidates:

- Placeholder scanning in polish (hard ban check: TBD, TODO, etc.)
- Simple file searches in explorers (grep-first narrowing)
- Classification subtasks in the router
- YAML frontmatter validation

At $1/$5 vs Sonnet's $3/$15, Haiku is 3x cheaper for deterministic, low-ambiguity work.

Priority: **Medium**. Cost optimization.

### 8. CLI > Skills > MCP Preference

Source: TIPS.md $7 (Scalekit benchmark — 10-32x CLI advantage, 28% MCP failure rate).

FRAMEWORK doesn't state a tool preference. Agents should prefer `gh` over GitHub MCP, `git` over MCP equivalents, `rg`/`tree` over MCP file tools.

FRAMEWORK's docs-explorer already uses "Context7 MCP / official docs / GitHub" for external escalation. This should be CLI-first with MCP as fallback.

Recommendation:

- State preference in agent prompts: "Use CLI tools when available. Use MCP only when CLI cannot provide the data."

Priority: **Medium**. Token efficiency and reliability.

### 9. Todo-Checklist for Craft Agents

Source: TIPS.md $2 (Lost In The Middle — Liu et al. showed ~20pp accuracy drop for mid-context info).

Blueprint units serve as a checklist, but craft agents don't maintain a running progress tracker. For multi-unit craft, the current and remaining units should be restated periodically to counter attention drift.

Recommendation:

- Craft agents maintain: "[x] Unit 1, [x] Unit 2, [ ] Unit 3 — currently on Unit 3."
- Restate at unit boundaries.

Priority: **Medium**. Simple to add, addresses documented attention drift.

### 10. Overall Iteration Cap

Source: TIPS.md $9 (Multi-Agent Workflows), $17 (Complexity Management).

The 3-fix circuit breaker is per-error. No overall iteration cap per agent exists. A craft agent could make 50+ tool calls without triggering the breaker if each attempt targets a different error.

Recommendation:

- Add a hard iteration cap per agent (e.g., MAX_ITERATIONS=25).
- Auto-pause at cap with status report to user.
- Separate from the 3-fix circuit breaker, which remains per-error.

Priority: **Medium**. Safety guard for runaway sessions.

### 11. Context Health Between Craft Units

Source: TIPS.md $2 (Context Rot — no universal threshold, but degradation is real and progressive).

FRAMEWORK has a PreCompact hook but no guidance on when during a long std/deep pipeline to check context health.

Recommendation:

- Between craft units, assess whether the session is degrading.
- If context is large, compact and restate the plan before starting the next unit.
- Not a fixed token threshold — a heuristic check.

Priority: **Low**. Claude Code autocompacts; this is extra safety.

### 12. Hook Security Standard

Source: TIPS.md $6 (Hooks — security standard).

FRAMEWORK's hooks section (v1 and deferred) describes what hooks do but not how to write them safely. TIPS.md $6 lists: treat hook inputs as untrusted, quote shell variables, use absolute script paths, keep failure output concise.

Recommendation:

- Add a brief security note to the hooks section when implementing.

Priority: **Low**. Relevant at implementation time, not design time.

---

## The Complexity Critique

Source: TIPS.md $17 (Complexity Management), grugbrain.dev.

The framework has accumulated speculative complexity. 760 lines, 6 pipeline phases, 10+ agent types, 7 hard gates, 10 root cause categories, 6 YAML schemas.

### Blueprint Review Agents for Std Tier

Three agents reviewing a plan before code starts. No evidence yet that blueprint quality is a bottleneck.

Google Research's study supports review being parallelizable and independent, but the ETH Zurich study shows LLM-generated content can hurt as much as help.

Recommendation: Defer. Add when retros show blueprint quality is a problem.

### 10 Root Cause Categories

Agents will misclassify. Categories overlap ("poor sketch decisions" vs "poor CLAUDE.md" vs "poor code patterns/structure"). Rigid categories force wrong buckets. TIPS.md $17: "treat rigid categorization schemes as optional unless they drive action."

Recommendation: Replace with free-text root cause. Let `/propose` find patterns from actual retro data.

### YAML Frontmatter

Six schemas with specific required fields. Not all are useful for retrieval.

Useful for grep: `module`, `tags`, `type`, `date`, `tier`, `outcome`.
Questionable: `overall_confidence`, `source_sketch`, `unit_count`.

Recommendation: Keep retrieval-useful fields. Make others optional.

### Durable Decisions List

"API routes, DB schema, auth boundaries..." reads as a checklist. "Decisions that cross implementation units" is the principle. The list is examples.

Recommendation: Frame as "e.g." not requirements.

### MAP.md vs ETH Zurich Tension

FRAMEWORK maintains MAP.md as an agent-friendly project navigation index, updated incrementally by retros (LLM-generated updates). ETH Zurich found: "95-100% of LLM-generated files included repository overviews. Agents discovered relevant files no faster than with no context file."

MAP.md is different from what ETH studied (curated tree vs prose overview, incremental vs from-scratch). But the tension exists: auto-maintained navigation files may not help agents navigate faster.

Recommendation: Keep MAP.md but validate empirically. If retros show agents ignore MAP.md or find files just as fast without it, simplify or remove.

---

## Recommendations

| Priority | Change | Gap | Status |
|----------|--------|-----|--------|
| High | Define agent voice template (smart persona + output format + token budget) | #1 | Done |
| High | Rewrite hard gates as positive imperatives | #2 | Done |
| High | Add per-phase gotchas (2-3 each) | #3 | Done |
| High | Add task structure assessment to craft dispatch | #4 | Done |
| High | Move enforceable hard gates to hooks | #5 | Done (revised: PostCompact + project-level verification) |
| Medium | Document coding-specific multi-agent limits | #6 | Done (absorbed by #4) |
| Medium | Add Haiku to model routing for bounded tasks | #7 | Done |
| Medium | Encode CLI > Skills > MCP preference | #8 | Done |
| Medium | Add todo-checklist to craft agents | #9 | Done |
| Medium | Add overall iteration cap per agent | #10 | Done |
| Low | Context health checkpoints between craft units | #11 | Done |
| Low | Add hook security standard | #12 | Done |
| Low | Simplify YAML frontmatter (keep retrieval-useful fields) | Complexity | Skipped (fields serve evolve cycle) |
| Low | Replace root cause categories with free-text | Complexity | Done (kept categories as guidance, added free-text first) |
| Low | Frame durable decisions list as examples | Complexity | Done |
| Validate | MAP.md usefulness (empirical, from retros) | Complexity | -- |
| Defer | Blueprint review agents (validate need from retros) | Complexity | -- |
| Defer | KV-cache prompt structure (learn empirically) | -- | -- |
| Defer | Few-shot variation patterns (learn from practice) | -- | -- |

**Build order principle:** Build light first, validate with real tasks, add ceremony where retros show pain.
