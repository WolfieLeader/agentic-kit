# Gap Analysis: TIPS2.md vs FRAMEWORK.md

> Reviewed 2026-04-11. Based on corrected TIPS2.md (with independent research validation) and FRAMEWORK.md v0.1.
>
> Scope: Claude Code, Claude models (Haiku 4.5, Sonnet 4.6, Opus 4.6), English language.

---

## What FRAMEWORK.md Gets Right

Core philosophy is sound:

- **Disk as handoff** — artifacts survive compaction, context rot is sidestepped
- **Tier-scaled ceremony** — light gets light, the grug way
- **Explorers before classification** — structural anti-anchoring, not just instructional
- **TDD as iron law** with 3-fix circuit breaker
- **Knowledge compounding** — retro → propose → evolve
- **Evidence-before-claims** verification
- **Anti-sycophancy** in review feedback
- **Model routing** — Sonnet for read-heavy, Opus for code
- **Confidence gating** on review findings
- **Fresh-context review** via separate review agents in polish

---

## Gaps

### 1. Agent Voice — No Unified Template

Source: TIPS2.md §4 (Output Compression), §16 (Skill And Agent Design).

Output tokens cost 5x input. Every framework agent produces output, none have explicit brevity constraints.

Three levers, all unset:

| Lever | What it does | Current state |
|-------|-------------|---------------|
| **Persona** | Competent identity → better reasoning distribution | Agents have roles but no trait framing |
| **Output format** | Structured constraints → compressed output | Explorers have structure, others don't |
| **Token budget** | Measurable compression | No per-agent budgets |

Recommendation:

- Define an agent voice template inherited by every agent: one-line persona + output format + token budget.
- Explorer findings: <500 tokens. Review findings: <200 tokens per issue. Craft status: <100 tokens.
- Use role + trait: "Correctness reviewer. Methodical, skeptical, evidence-only."

Priority: **High**. Affects every agent prompt and has direct cost impact.

### 2. Positive Framing for Hard Gates

Source: TIPS2.md §16 (Instruction Framing — positive instructions followed more reliably than negative).

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

Source: TIPS2.md §16 — "common gotchas per domain are more actionable than abstract principles."

Each phase should include 2-3 specific failure modes agents commonly hit:

- **Router:** "Agents classify everything as lightweight to avoid ceremony"
- **Sketch:** "Agents anchor on the first approach" (handled by anti-anchoring — good)
- **Blueprint:** "Agents include implementation code in behavioral descriptions"
- **Craft:** "Agents write tests that test implementation details, not behavior"
- **Polish:** "Agents claim tests pass without running them"
- **Retro:** "Agents write generic retrospectives instead of specific technical findings"

Priority: **High**. More actionable than abstract principles.

### 4. Task Structure in Dispatch Decisions

Source: TIPS2.md §9 (Google Research study, Kim & Liu Jan 2026).

Google Research found task structure matters more than task size for multi-agent decisions:

- Parallelizable tasks: +80.9% with multi-agent.
- Sequential tasks: 39-70% degradation with multi-agent.

FRAMEWORK routes to subagents based on tier (complexity). But a "standard" task with 3 tightly coupled, sequentially dependent units may perform worse with subagents than inline execution.

Recommendation:

- Add task structure assessment to craft dispatch: "Are implementation units truly independent?"
- If units have sequential dependencies (unit B depends on unit A's output), prefer inline or sequential dispatch.
- Subagents only when units can be worked in parallel without coordination.

Priority: **High**. Directly affects craft dispatch for std/deep.

### 5. Coding-Specific Multi-Agent Limits

Source: TIPS2.md §9 (Anthropic — "most coding tasks involve fewer truly parallelizable tasks than research").

FRAMEWORK's std/deep pipeline assumes implementation units are parallelizable. Many coding tasks have sequential dependencies, shared state, or overlapping files.

Recommendation:

- Document when parallel craft dispatch is appropriate (disjoint files, independent modules, no shared state).
- Default to sequential craft dispatch; parallel is an optimization.
- Blueprint should flag unit independence explicitly.

Priority: **Medium**. Overlaps with gap #4 but worth a separate framework note.

### 6. No Haiku in Model Routing

Source: TIPS2.md §12 (Model Routing).

FRAMEWORK only uses Sonnet 4.6 and Opus 4.6. Haiku 4.5 is absent.

Haiku candidates:

- Placeholder scanning in polish (hard ban check: TBD, TODO, etc.)
- Simple file searches in explorers (grep-first narrowing)
- Classification subtasks in the router
- YAML frontmatter validation

At $1/$5 vs Sonnet's $3/$15, Haiku is 3x cheaper for deterministic, low-ambiguity work.

Priority: **Medium**. Cost optimization.

### 7. CLI > Skills > MCP Preference

Source: TIPS2.md §7 (Scalekit benchmark — 10-32x CLI advantage, 28% MCP failure rate).

FRAMEWORK doesn't state a tool preference. Agents should prefer `gh` over GitHub MCP, `git` over MCP equivalents, `rg`/`tree` over MCP file tools.

Recommendation:

- State preference in agent prompts: "Use CLI tools when available. Use MCP only when CLI cannot provide the data."

Priority: **Medium**. Token efficiency and reliability.

### 8. Todo-Checklist for Craft Agents

Source: TIPS2.md §2 (Lost In The Middle — Liu et al. showed ~20pp accuracy drop for mid-context info).

Blueprint units serve as a checklist, but craft agents don't maintain a running progress tracker. For multi-unit craft, the current and remaining units should be restated periodically to counter attention drift.

Recommendation:

- Craft agents maintain: "[x] Unit 1, [x] Unit 2, [ ] Unit 3 — currently on Unit 3."
- Restate at unit boundaries.

Priority: **Medium**. Simple to add, addresses documented attention drift.

### 9. Overall Iteration Cap

Source: TIPS2.md §9 (Multi-Agent Workflows), §17 (Complexity Management).

The 3-fix circuit breaker is per-error. No overall iteration cap per agent exists. A craft agent could make 50+ tool calls without triggering the breaker if each attempt targets a different error.

Recommendation:

- Add a hard iteration cap per agent (e.g., MAX_ITERATIONS=25).
- Auto-pause at cap with status report to user.
- Separate from the 3-fix circuit breaker, which remains per-error.

Priority: **Medium**. Safety guard for runaway sessions.

### 10. Context Health Between Craft Units

Source: TIPS2.md §2 (Context Rot — no universal threshold, but degradation is real and progressive).

FRAMEWORK has a PreCompact hook but no guidance on when during a long std/deep pipeline to check context health.

Recommendation:

- Between craft units, assess whether the session is degrading.
- If context is large, compact and restate the plan before starting the next unit.
- Not a fixed token threshold — a heuristic check.

Priority: **Low**. Claude Code autocompacts; this is extra safety.

---

## The Complexity Critique

Source: TIPS2.md §17 (Complexity Management), grugbrain.dev.

The framework has accumulated speculative complexity. 760 lines, 6 pipeline phases, 10+ agent types, 7 hard gates, 10 root cause categories, 6 YAML schemas.

### Blueprint Review Agents for Std Tier

Three agents reviewing a plan before code starts. No evidence yet that blueprint quality is a bottleneck.

Google Research's study supports review being parallelizable and independent, but the ETH Zurich study shows LLM-generated content can hurt as much as help.

Recommendation: Defer. Add when retros show blueprint quality is a problem.

### 10 Root Cause Categories

Agents will misclassify. Categories overlap ("poor sketch decisions" vs "poor CLAUDE.md" vs "poor code patterns/structure"). Rigid categories force wrong buckets.

Recommendation: Replace with free-text root cause. Let `/propose` find patterns from actual retro data.

### YAML Frontmatter

Six schemas with specific required fields. Not all are useful for retrieval.

Useful for grep: `module`, `tags`, `type`, `date`, `tier`, `outcome`.
Questionable: `overall_confidence`, `source_sketch`, `unit_count`.

Recommendation: Keep retrieval-useful fields. Make others optional.

### Durable Decisions List

"API routes, DB schema, auth boundaries..." reads as a checklist. "Decisions that cross implementation units" is the principle. The list is examples.

Recommendation: Frame as "e.g." not requirements.

---

## Recommendations

| Priority | Change | Gap |
|----------|--------|-----|
| High | Define agent voice template (persona + output format + token budget) | #1 |
| High | Rewrite hard gates as positive imperatives | #2 |
| High | Add per-phase gotchas (2-3 each) | #3 |
| High | Add task structure assessment to craft dispatch | #4 |
| Medium | Document coding-specific multi-agent limits | #5 |
| Medium | Add Haiku to model routing for bounded tasks | #6 |
| Medium | Encode CLI > Skills > MCP preference | #7 |
| Medium | Add todo-checklist to craft agents | #8 |
| Medium | Add overall iteration cap per agent | #9 |
| Low | Context health checkpoints between craft units | #10 |
| Low | Simplify YAML frontmatter (keep retrieval-useful fields) | Complexity |
| Low | Replace root cause categories with free-text | Complexity |
| Defer | Blueprint review agents (validate need from retros) | Complexity |
| Defer | KV-cache prompt structure (learn empirically) | — |
| Defer | Few-shot variation patterns (learn from practice) | — |

**Build order principle:** Build light first, validate with real tasks, add ceremony where retros show pain.
