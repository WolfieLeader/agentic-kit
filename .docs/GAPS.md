# Gap Analysis: TIPS.md vs FRAMEWORK.md

> Reviewed 2026-04-11. Cross-references TIPS.md research, FRAMEWORK.md design, inspiration sources (Compound Engineering, Superpowers, CC10X, Matt Pocock, Everything-Claude-Code), and grugbrain.dev philosophy.

---

## What FRAMEWORK.md Gets Right

Core philosophy is sound. Properly incorporates:

- **Disk as handoff** / context engineering (artifacts survive compaction)
- **Tier-scaled ceremony** (right-size to scope)
- **Explorers before classification** (informed decisions)
- **TDD as iron law** with 3-fix circuit breaker
- **Knowledge compounding** (retro → propose → evolve)
- **Evidence-before-claims** verification
- **Anti-sycophancy** in review feedback
- **Model routing** (sonnet for read-heavy, opus for code)
- **Confidence gating** on review findings

---

## Gaps: TIPS Insights Missing from FRAMEWORK

### 1. KV-Cache Optimization — Not Operationalized

TIPS says: append-only context, deterministic serialization, mask tools don't remove them. FRAMEWORK uses disk-based handoff (good) but says nothing about how skill/agent prompts should be structured for cache-friendliness. When a craft agent gets dispatched, the prompt structure matters for cache hits across units.

### 2. Todo-List Driven Development — Absent from Craft

TIPS says: agents average ~50 tool calls, checklists counter lost-in-the-middle. FRAMEWORK's blueprint has implementation units, but craft agents don't maintain a running checklist during execution. The blueprint units *are* the checklist, but no one tells the craft agent to use them that way.

### 3. Few-Shot Pattern Hazards — Not Mentioned

TIPS warns about mimicry vulnerability and drift in repetitive tasks. Craft agents doing repeated TDD cycles are exactly the scenario where this applies. No guidance on introducing structured variation.

### 4. Subagent Cost Awareness — Implicit but Not Explicit

TIPS: 15-50K token overhead per subagent, 3-10x cost vs inline. FRAMEWORK makes lightweight inline (good), but the dispatch decision for std/deep is based on *complexity*, not cost. A 2-unit standard task might be cheaper inline than spawning 2 subagents.

### 5. Output Token Cost — Agents Aren't Told to Be Concise

Output is 5x input cost. FRAMEWORK's agent sections describe what agents *return* but never say "be concise." Explorer findings, review findings, craft status — all should have explicit brevity constraints.

### 6. No Haiku Anywhere

TIPS has a clear model routing table. FRAMEWORK only uses Sonnet and Opus. Haiku could handle: placeholder scanning in polish, simple file searches, classification subtasks.

### 7. Context Rot Checkpoints — Missing from Pipeline

TIPS says compact before hitting ~60% of context window. FRAMEWORK has PreCompact hook but no guidance on *when* during a long std/deep pipeline the router should check context health. A multi-unit craft phase can easily burn 200K+ tokens.

### 8. CLI > Skills > MCP Hierarchy — Not Encoded

TIPS says CLI is 4-32x more efficient than MCP. FRAMEWORK doesn't state a tool preference. Agents should prefer `gh` over GitHub MCP, `git` over MCP equivalents, etc.

### 9. Auto-Mode / Max-Turns Safeguards

TIPS warns about 5-20x token burn in auto mode. FRAMEWORK's 3-fix circuit breaker is per-error, but there's no overall iteration cap per agent. TIPS mentions MAX_ITERATIONS=8 in multi-agent section. FRAMEWORK's agent design rules are scattered — only craft agents get behavioral rules.

---

## Gaps: Concepts Missing from FRAMEWORK

### 10. Agent Voice — Unified Design Decision

Gaps #5 (output cost), persona framing, output compression, and instruction framing are really one design decision with three levers. Now covered in TIPS.md Sections 2 ("Output Compression") and 13 ("Agent Persona & Voice", "Instruction Framing").

**The three levers:**

| Lever | What it does | Example |
|-------|-------------|---------|
| **Persona** | Sets competent identity → better reasoning distribution | "You are a correctness reviewer. Methodical, skeptical, evidence-only." |
| **Output format** | Structured constraints → compressed output, 5x cost savings | "Return: findings list, max 200 tokens per issue. No preamble." |
| **Instruction framing** | Positive + specific → higher compliance | "Design then code" not "don't code before designing" |

**What FRAMEWORK.md should add:**

1. An **agent voice template** that every agent inherits — one line persona + output format + token budget
2. **Rewrite hard gates as positive imperatives** — "DESIGN-THEN-CODE" not "NO-CODE-BEFORE-DESIGN"
3. **Per-agent output budgets** — explorers: <500 tokens findings, reviewers: <200 tokens per issue, craft status: <100 tokens

**Caveman reference:** [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) achieves 65-75% output savings but uses a "dumb" persona that hurts reasoning. The fix: competent persona + structured output constraints = same savings, no IQ penalty.

### 11. Positive Framing ("Do X" Over "Don't Do X")

Subsumed by #10 (instruction framing lever), but worth keeping as a separate action item since it affects hard gates, rationalization tables, and TDD rules throughout the framework.

FRAMEWORK's current negative framing:
- "NO-CODE-BEFORE-DESIGN" → "DESIGN-THEN-CODE"
- "NO-RECOMMENDATION-BEFORE-OPTIONS" → "OPTIONS-THEN-RECOMMEND"
- "Never refactor while RED" → "Refactor only when GREEN"
- "NO-FIX-WITHOUT-ROOT-CAUSE" → "INVESTIGATE-THEN-FIX"
- "NO-CODE-WITHOUT-FAILING-TEST" → "TEST-THEN-CODE"

### 12. Common Gotchas / Constraints Per Phase

Each phase should include 2-3 specific gotchas that agents commonly hit. Examples:
- Sketch: "Agents tend to anchor on the first approach they generate" (handled by anti-anchoring rule, good)
- Craft: "Agents write tests that test implementation details, not behavior"
- Polish: "Agents claim tests pass without running them"

More actionable than abstract principles.

---

## The Complexity Critique

Now covered in TIPS.md Section 14 ("Complexity Management"). Core reference: [grugbrain.dev](https://grugbrain.dev/).

The framework that exists to fight complexity has itself accumulated complexity. 760 lines, 6 pipeline phases, 10+ agent types, 7 hard gates, 10 root cause categories, 6 YAML schemas.

Specific concerns:

1. **Blueprint review agents for std tier** — is a 3-agent review of a plan *before code even starts* justified for a multi-file feature? Prove the light pipeline works first, let std/deep ceremony emerge when you feel the pain of its absence.

2. **10 root cause categories for retro** — agents will pick the wrong category half the time, and categories overlap (is "poor sketch decisions" vs "poor CLAUDE.md" always clear?). Consider: free-text root cause, let `/propose` find patterns.

3. **YAML frontmatter schemas** — 6 different schemas with specific required fields. Is `overall_confidence: GREEN` in blueprint frontmatter actually useful for grep-first retrieval, or is it ceremony? Fields useful for retrieval: `module`, `tags`, `type`, `date`. The rest is metadata that lives in the document body anyway.

4. **Durable decisions in blueprint** — good concept, but the list (API routes, DB schema, shared types, auth boundaries, service boundaries, cross-platform) is prescriptive. "Decisions that cross implementation units" is the principle. The list is examples at best, false requirements at worst.

However — FRAMEWORK.md already embodies grug's most important principle: **tier-scaled ceremony**. Light gets light. The question is whether std/deep have *earned* their ceremony yet, or if it's designed speculatively.

---

## Recommendations

| Priority | Change |
|----------|--------|
| High | Define agent voice template (persona + output format + token budget) — gap #10 |
| High | Rewrite hard gates as positive imperatives — gap #11 |
| High | Add per-phase gotchas (2-3 each) — gap #12 |
| Medium | Add todo-checklist instruction to craft agents |
| Medium | Encode CLI > Skills > MCP preference |
| Medium | Add context health checkpoints to pipeline |
| Medium | Add Haiku to model routing for simple tasks |
| Low | Simplify YAML frontmatter (keep retrieval-useful fields, drop the rest) |
| Low | Simplify root cause categories (merge overlapping ones) |
| Defer | KV-cache prompt structure (learn empirically during build) |
| Defer | Few-shot variation patterns (learn from practice) |

**Build order principle:** Build light first, validate, then add std/deep ceremony. This is both the grug way and the framework's own principle of right-sizing.
