# Tips & Standards for AI-Assisted Development

> Distilled from deep research across Anthropic docs, Manus engineering blog, Compound Engineering, Superpowers, Addy Osmani's articles, academic papers, and community practice. Numbers are cited where available.

---

## 1. Context Engineering

Context engineering is the most impactful lever in AI-assisted development. Token usage explains **80% of performance variance** — model choice is secondary.

### Signal Density > Context Size

- Every frontier model degrades as input grows. A 200K-window model can degrade significantly at 50K tokens.
- **Lost-in-the-middle effect:** ~20-30% accuracy drop for information placed in the middle of context vs. start/end.
- Irrelevant context doesn't just waste tokens — it **increases hallucinations** via distractor interference.
- 2 surgical files at <50K tokens outperform 500K tokens of noise.
- **14x cost difference** ($4.80 vs $0.35) for the same task with bad vs. good context.

### Three Context Layers

| Layer | Content | Behavior |
|-------|---------|----------|
| **Persistent base** | System prompt, safety policies, CLAUDE.md, tool definitions | Cache this. Rarely changes. |
| **Dynamic** | Task-relevant examples, recent memory, metadata | Rotate per task or step. |
| **Ephemeral** | User query, tool outputs | Keep small and short-lived. |

### KV-Cache Optimization (from Manus)

KV-cache hit rate is the single most important metric for production agents.

- Cached tokens: **$0.30/MTok** vs uncached: **$3/MTok** — a **10x** difference.
- **Even a single-token change** invalidates cache from that point forward.
- Avoid timestamps in system prompts — kills cache hit rate.
- Make context **append-only**. Never modify previous actions/observations; only add new ones.
- Ensure **deterministic serialization** (consistent JSON key ordering).
- **Mask tools, don't remove them.** Adding/removing tools mid-iteration invalidates KV-cache for everything downstream. Manus uses logit masking during decoding instead.

### Context Rot

Despite increasing context windows, model quality declines past a threshold:

- **Context rot is continuous:** performance degrades as context grows — Chroma found degradation starting as early as ~50K tokens. Even in a 1M context window, try to stay below 200K.
- Compact/summarize **before** hitting ~60% of the context window, not after overflow.
- `/compact` typically achieves 60-80% context reduction. `/new` clears entirely for task switches.
- Git commits become the reconstruction mechanism post-compaction — not conversation history.

### Todo-List Driven Development (from Manus)

Agents average ~50 tool calls per task — long enough for goal drift.

- Create/update a task checklist file step-by-step during execution.
- This pushes objectives to the **end of context**, countering the lost-in-the-middle attention failure.
- The agent "recites" its goals by reading the list, keeping them in active attention.

### Few-Shot Pattern Hazards

- Models replicate behavioral patterns in context even when suboptimal (mimicry vulnerability).
- In repetitive tasks, identical action-observation patterns cause **drift and brittleness**.
- Fix: introduce structured variation in serialization, phrasing, and ordering.

---

## 2. Token Efficiency & Cost

### Pricing Reference (Anthropic, as of April 2026)

| Model | Input | Output | Cached Input |
|-------|-------|--------|-------------|
| Haiku 4.5 | $1/MTok | $5/MTok | $0.10/MTok |
| Sonnet 4.6 | $3/MTok | $15/MTok | $0.30/MTok |
| Opus 4.6 | $5/MTok | $25/MTok | $0.50/MTok |

Output tokens are **5x** more expensive than input across all tiers.

### Prompt Caching

- **5-minute TTL**, refreshed on each hit. 1-hour option available at additional cost.
- Content must be **identical** across requests — a single character breaks the cache.
- Place stable content (tools, system instructions, examples) at the **beginning** of your prompt.
- Up to **4 cache breakpoints** per prompt. The system finds the longest matching cached prefix.
- Minimum cacheable: 4,096 tokens (Haiku 4.5, Opus 4.6), 2,048 tokens (Sonnet 4.6).
- Agents have ~100:1 input-to-output token ratio — heavily prefill-dominated, making caching critical.

### Subagent Cost Reality

- Each subagent spawns a fresh context: system prompt + task description re-injected = **3-10x more input tokens** vs inline work.
- Practical overhead per subagent: ~15-50K tokens (system prompt + tool definitions + MCP tools + skills + CLAUDE.md). Bare minimum without MCP is ~2-5K.
- A UIUC study found multi-agent systems consume **4-220x more tokens** than single-agent counterparts.
- **Use subagents for:** parallelizable independent tasks, read-heavy exploration, unbiased review.
- **Avoid subagents for:** small edits, sequential dependent work, anything under 2-3 minutes of inline work.

### Output Cost by Language

| Language | Relative Cost | Tradeoff |
|----------|--------------|----------|
| Python | Lowest (~1 token/4 chars) | Dynamic typing = more correction cycles |
| TypeScript | Low-moderate (~1 token/3.5 chars) | Good balance of cost + type safety |
| Java | Moderate (~1 token/3 chars) | Verbose but typed = fewer corrections |
| C++ | Highest | Most verbose output |

Optimize for **total tokens per correct feature**, not tokens per first attempt. Verbose-but-typed languages cost more per generation but produce fewer correction cycles.

### CLI Proxy Savings (RTK Pattern)

- `git status`, `git diff`, `git log` output is **60-90% reducible** by stripping whitespace, unchanged hunks, and verbose headers.
- Hook-based rewriting: zero workflow overhead, transparent to the user.

### Output Compression (Agent Voice)

Output tokens are **5x** more expensive than input. Most agent output is filler — preamble, hedging, pleasantries, verbose explanations.

- **Caveman approach** ([JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman)): drop articles, use fragments, telegraphic style. Achieves **65-75% output token savings**.
- **The catch:** forcing a "dumb" persona contaminates reasoning. The model shifts its distribution toward simpler thinking patterns. You save tokens but may lose quality.
- **Better approach:** competent persona + structured output constraints. "Principal engineer who values colleagues' time" gets the same brevity without the IQ penalty.
- Separate **output format** (terse, structured) from **identity** (competent, precise). These are independent levers.
- Specific output templates beat vague "be concise" instructions. Define what the agent returns, not just "keep it short."
- Token budgets per output type (e.g., explorer findings: <500 tokens, review findings: <200 tokens per issue) make compression measurable.

### Auto Mode

- Can burn **5-20x** more tokens than guided interactive use due to exploration loops and retries.
- Set `--max-turns` to cap runaway sessions.

---

## 3. CLAUDE.md & Harness Configuration

### The Budget

Your CLAUDE.md competes for a limited instruction budget:

| Component | Tokens | % of 200K |
|-----------|--------|-----------|
| System prompt | ~2.7K | 1.3% |
| System tools | ~16.8K | 8.4% |
| Skills metadata | ~1K | 0.5% |
| Memory files | ~7.4K | 3.7% |

Top reasoning models (e.g., Gemini 2.5 Pro, o3) maintain near-perfect performance through ~150+ instructions before declining; non-reasoning models decay earlier. The system prompt already contains ~50. That leaves **~100-150 for your CLAUDE.md + rules + skills**.

### What to Include

- Commands Claude can't guess (`pnpm lint:fix && pnpm typecheck`, not `npm test`)
- Architecture decisions and style that linters can't enforce
- Pointers to supplementary docs (`@file:line` references, not inline code copies)
- Key gotchas, common mistakes, "Always Do / Never Do" rules
- Build/test/verify commands with exact flags

### What to Exclude

- Code style guidelines — "Never send an LLM to do a linter's job"
- Information that changes frequently or is redundant
- Codebase overviews or directory listings — **zero benefit** (ETH Zurich study)
- Auto-generated content (`/init` is unreliable)
- Anything enforceable via formatting, linting, or type checking

### Size & Structure

- Target: **<60 lines** ideal, **<300 lines** maximum.
- One-line tool refs beat prose: `"Run pnpm lint:fix && pnpm typecheck"` > paragraphs about style.
- Use **progressive disclosure**: separate `/agent_docs/` or `references/` files for detail. Let Claude choose what's relevant.
- Use multiple CLAUDE.md files — root for universal rules, subdirectories for area-specific context.
- Bad instructions **compound** through research -> plan -> code phases.
- LLM-generated agentfiles **hurt** performance — 20%+ more tokens, no better resolution.
- Living document: add a rule every time Claude makes a repeated mistake. Review weekly.

### Hooks > Instructions

- CLAUDE.md instructions are followed ~70% of the time. Hooks close the gap to **100%**.
- **PreToolUse** hooks: the only blocking hook. Use for security gates and policy guards.
- **PostToolUse** hooks: auto-formatting, linting, feedback. Success = silent, failure = verbose errors.
- Start with: auto-format on PostToolUse, dangerous-command blocking on PreToolUse, desktop notifications on Stop.
- Swallow test output on success — full suite output floods context and causes hallucination.
- Hooks run in parallel. If multiple PreToolUse hooks modify the same input, last one wins (non-deterministic order). Avoid this.

### Strict Boundaries Principle

Type safety + linting + formatting = **deterministic guardrails** AI cannot bypass.

- Feed lint errors back to the model — it corrects aggressively.
- Codify every bug/incident as a lint rule — turns lessons into executable constraints.
- TypeScript strict mode > loose types. AI defaults to `any` without enforcement.
- Strict boundaries make output better than any prompt instruction.

---

## 4. Tool Hierarchy

**CLI > Skills > MCP** — in terms of token efficiency.

| Tool Type | Token Cost | When to Use |
|-----------|-----------|-------------|
| **CLI** | Minimal (output only) | External services (gh, aws, gcloud, sentry-cli). 4-32x more efficient than MCP (Scalekit benchmark). Near-100% success rate. |
| **Skills** | ~50-100 tokens at rest; full load only on match | Teaching Claude workflows, processes, domain knowledge. No server, no dependencies. |
| **MCP** | Tens of thousands of tokens (GitHub MCP alone consumes massive context) | Only when no CLI alternative exists. ToolSearch reduces overhead by 85%. |

- Most developers need **2-3 MCP servers** max + a few custom skills.
- MCP connects Claude to data; skills teach Claude what to do with data.
- Replace MCP servers with CLI wrappers + 6 usage examples in CLAUDE.md where possible.

---

## 5. Spec-Driven Development

The spec is the source of truth — not the code.

### The Planning Ratio

**Compound Engineering formula:** 80% non-coding (plan + review), 20% coding (work + compound).

"Plans are the new code."

### Workflow State Machine

```
INTENT -> SPEC -> PLAN -> IMPLEMENT -> VERIFY -> REVIEW -> RELEASE
```

Each gate validates before the next phase. Claude Code's plan mode enforces read-only exploration + clarifying questions until you approve a plan.

### Writing Good Specs

- **One real code snippet beats paragraphs.** Show style through examples.
- **Specific stack details:** name exact versions and key dependencies.
- **Three-tier boundaries:**
  - Always do (safe, no approval needed)
  - Ask first (requires human review)
  - Never do (hard stops — "Never commit secrets")
- **Success criteria** with specific test cases — define what "done" means.
- **Explain the "why"** so the agent optimizes for correct outcomes, not just pattern matching.
- Vague specs **multiply errors** across parallel runs. Your spec is your leverage.

### Anti-Patterns

- "Build something cool" provides no anchor — be specific about inputs, outputs, constraints.
- Monolithic 50-page contexts without summarization cause attention degradation.
- Conflating speed with quality — don't let agent speed outpace your ability to verify.
- Over-specification on simple tasks — adjust detail to complexity.

---

## 6. Multi-Agent Architecture

### When Parallel Agents Win

- On **parallelizable tasks**: +81% improvement over single-agent (Finance-Agent benchmark).
- On **sequential tasks**: up to **70% degradation** with multi-agent coordination.
- Three focused agents consistently outperform one generalist agent working three times longer.
- **Sweet spot: 3-5 agents.** 1 reviewer per 3-4 builders (read-only, fresh context = less biased).

### When to Stay Inline

- If the entire codebase fits in one context window and tasks are sequential.
- Small edits, sequential dependent work.
- Tasks under 2-3 minutes — subagent overhead exceeds inline cost.
- Write-heavy parallel workflows — conflicts increase coordination overhead.

### Coordination Patterns

| Level | Pattern | Best For |
|-------|---------|----------|
| **1: Subagents** | Parent decomposes, spawns children with file scopes | Simple decomposition, independent tasks |
| **2: Agent Teams** | Shared task list, peer-to-peer messaging, file locking | Complex features with dependencies |
| **3: Orchestration** | External tools (Conductor, Ruflo) manage lifecycle | Large-scale parallel development |

### Agent Design Rules

- **Hard MAX_ITERATIONS=8** per agent. Reassign after 3+ stuck iterations on same error.
- **File budget:** max 15 files per investigation. Report findings + open questions if more needed.
- **Token budgets per agent** (e.g., frontend 180K, backend 280K). Auto-pause at 85%.
- **Concrete search targets** in every dispatch prompt — generic "investigate the codebase" produces generic findings.
- **Query echo:** agents log actual search terms so caller can assess coverage.
- **Attribution:** distinguish codebase findings from model assumptions.
- **Hierarchical:** spawn 2 leads each with 2-3 specialists, not 6 flat subagents.

### Agent Failure Handling

Eight named failure patterns (Arize): retrieval noise, hallucinated tool arguments, recursive polling loops, guardrail failures, pre-training bias overriding context, unhandled API schema changes, instruction drift in long sessions, destructive code generation.

- **Instruction drift:** models prioritize recent tokens over initial system prompts as sessions lengthen.
- **Preserve failure traces** in context — the model updates its beliefs when observing its own failures.
- Acknowledge gaps explicitly rather than silently degrading.

---

## 7. Git Worktrees & Parallel Development

### Why Worktrees

Each agent gets an isolated git worktree — no merge conflicts during parallel work. Branches prevent main code contamination.

### Practical Limits

- **3-5 parallel worktrees** before context-switching overhead dominates.
- A 20-min session on ~2GB codebase used **9.82 GB** with automatic worktree creation.
- Beyond 5, use CI/CD or orchestration frameworks.
- Worktrees share local DB, Docker daemon, caches — two agents modifying DB state creates race conditions.

### Best Practices

- Use when: tasks take >few minutes, touch different parts of the codebase, you want reviewable isolated history.
- Claude Code's `-w` / `--worktree` flag auto-manages worktree lifecycle.
- Automatic cleanup: if no changes made, worktree + branch are deleted on exit.
- `symlinkDirectories` in settings.json for node_modules/.cache sharing.
- `sparsePaths` for monorepo package-specific checkouts.
- **One file, one owner** — prevent merge conflicts during parallel work.

---

## 8. Quality & Verification

### TDD with AI Agents

Red/green TDD: write tests first, confirm failure (red), then agent implements until pass (green).

- "No longer optional when working with coding agents" — Simon Willison.
- Tests are the **cheapest verification** mechanism. They run automatically, catch regressions, and define "done."
- E2E tests are especially valuable — they verify feature correctness, not just code correctness.

### Anti-Sycophancy

Models default to agreeing with you. This is dangerous for code review and architecture decisions.

- Silicon Mirror framework: reduced Claude's sycophancy from 9.6% to **1.4%** (85.7% reduction).
- Explicit counter-instructions measurably reduce sycophantic behavior.
- Fresh-context reviewers (subagents) are less biased than the agent that wrote the code.
- When the model pushes back, evaluate whether the argument changes your reasoning. If it doesn't, maintain your position.

### The Verification Bottleneck

"The bottleneck has shifted. It's no longer generation. It's **verification.**" — Addy Osmani

- PR review time up **91%**; PR size up **154%** in high-AI-adoption teams.
- 66% frustrated by "almost right" solutions.
- 45% say debugging AI code takes longer than writing it.
- Type checking and test suites verify code correctness, not feature correctness — always test in browser for UI.

### Circuit Breakers

- Operates on internal model activations, not input/output boundaries.
- ~90% reduction in attack compliance, <1% performance degradation.
- Critical insight: classic circuit breakers **can't catch hallucinations** — failures look like successes (status 200, valid JSON, confident hallucination).

---

## 9. Model Routing

Match the model to the task, not the task to the model.

| Model | Best For | Avoid For |
|-------|----------|-----------|
| **Haiku** | Linting, formatting, simple refactors, file search, boilerplate, classification | Complex architecture, subtle bugs |
| **Sonnet** | Standard feature work, code review, most coding tasks, daily driver | — |
| **Opus** | Complex architecture, multi-file refactors, subtle bugs, orchestration | Simple tasks (burns rate limit) |

- Sonnet delivers ~90% of Opus capability at significantly lower cost.
- Use Opus for orchestration, Sonnet/Haiku for subagents.
- Use Haiku to "crawl" docs, Sonnet to synthesize research, Opus to architect.

---

## 10. Training Data Density

LLMs produce significantly better code for open-source, widely-adopted technologies.

- **Choose libraries the model has seen the most correct examples of.** Python over Scala, React over Blazor, Express over obscure frameworks.
- **Versions matter** — recent major versions have more training examples.
- Niche/proprietary frameworks have sparse training examples = worse output.
- Small, isolated, tightly-scoped patterns = cleaner generation.
- GitHub stars and adoption correlate with AI output quality.

---

## 11. Codebase Organization for Agents

### Navigation

- Stale data is worse than no data. Find sources of truth: `package.json`, `Makefile`, `env.ts`.
- In complex folders, use a README to make indexing easier.
- Deeply nested structures make agents work harder. Solutions: MAP.md, `tree` command, feature folder patterns.

### Scope

- **Monorepos are ideal** — agents see all ends without guessing.
- If not possible: place repos under the same folder, use `--add-dir` or `additionalDirectories` in settings.json.
- `additionalDirectories` accepts strings (path) or objects (`{ "path": "...", "readClaudeMd": true }`).

### Settings Hierarchy

Three-tier: user (`~/.claude/settings.json`) > project (`.claude/settings.json`) > local (`.claude/settings.local.json`).

---

## 12. Memory & Knowledge Compounding

### What to Persist

- Repeated mistakes and their fixes
- Project conventions and team decisions
- Architectural constraints and tradeoffs
- Third-party service integration patterns (when reusable)

### What to Forget

- Intermediate grep results and verbose test output
- Exploration dead-ends
- Redundant tool outputs and duplicate messages

### Compound Engineering

Each completed task should make the next task easier:

- Extract bugs, insights, and problem-solving patterns from retros.
- Distribute as prompts/rules in codebase for future agents.
- Hot memory ceiling: ~660 lines (always loaded). Cold memory: on-demand via retrieval.
- Maintenance overhead for full context infrastructure: only **1-2 hours/week**.

---

## 13. Skill & Agent Design

### Skill Files

- **SKILL.md under 200 lines.** Every line competes with codebase context.
- **Agent files under 120 lines.** Agents have their own context windows — every instruction line competes with files they need to read.
- Use `references/` for phase-specific detail, loaded on-demand.
- Skill descriptions: **only triggering conditions**, never workflow summaries. The description is loaded on every scan.
- 133 skills = ~7K-13K tokens for all metadata vs hundreds of thousands if fully loaded.

### Agent Prompts

- Encode **search procedures**, not just responsibilities. "Find relevant patterns" is goal-level. Include: grep-first narrowing, specific search terms, what to look for.
- Set **file budgets** for all agents (including doc explorers). Without a cap, agents can read 50+ files.
- Handle **failure explicitly**: note gaps, warn the user, proceed with adjusted expectations.
- Each finding gets a **"why it matters" annotation** — the caller shouldn't have to interpret raw facts.

### Agent Persona & Voice

Persona framing shifts the model's probability distribution. It's not roleplay — it changes what the model considers likely outputs.

- **Competent personas improve output.** "Senior staff engineer specializing in X" produces better code than no persona. Named personas (Compound Engineering's Kieran, DHH) create even stronger behavioral anchoring.
- **Dumb personas hurt reasoning.** Caveman-style prompts save output tokens but shift the model toward simpler thinking. Separate output format (terse) from identity (competent).
- **Role + trait is the minimum.** "You are a correctness reviewer. Methodical, skeptical, evidence-only." — one line, measurable behavioral impact.
- **Persona carries through the session.** Models maintain persona consistency. A well-set persona at dispatch time influences all subsequent tool calls and reasoning.

### Instruction Framing

How you phrase instructions matters as much as what you say.

- **Positive framing > negative framing.** "Design then code" is followed more reliably than "don't code before designing." Positive instructions give the model a clear action; negative instructions require the model to infer what to do instead.
- **Specific constraints > vague guidelines.** "Explorer findings under 500 tokens" beats "be concise." "Test behavior through public interfaces" beats "don't test implementation details."
- **Common gotchas per domain** are more actionable than abstract principles. "Agents write tests that test implementation details, not behavior" prevents the mistake directly. "Follow TDD best practices" doesn't.
- **Violation examples** make rules concrete. A rule without a violation example is a guideline.

### Hard Gates

- Use `<HARD-GATE>` tags for non-negotiable rules — Claude treats these with higher compliance than prose.
- Include **violation examples** — a rule without a violation example is a guideline.
- Add a **Rationalization Prevention table** to skills with skippable phases: "if you're thinking X, STOP."

---

## 14. Complexity Management

Complexity is the primary enemy — not lack of features, not lack of abstraction, not lack of process.

### Core Principles (from grugbrain.dev)

- **Say "no" first.** Every feature, abstraction, and process adds complexity. The 80/20 rule applies: 80% of value from 20% of the code.
- **Premature abstraction is worse than duplication.** Three similar lines of code are better than a premature abstraction. Good factoring emerges naturally as cut-points become obvious — those narrow interfaces that elegantly trap complexity.
- **Chesterton's Fence.** Understand why code/process exists before removing it. Existing systems often have hidden value.
- **Integration tests are the sweet spot.** Favor integration tests over strict unit tests. Maintain small, curated E2E suites for critical features. Regression tests when bugs appear.
- **Locality of behavior > separation of concerns.** Place code near what it affects. Scattering related functionality across files creates confusion.
- **Fear of Looking Dumb (FOLD).** Acknowledging complexity you don't understand empowers others to do the same. Normalizing "I don't know" reduces bad decisions.

### Applied to AI-Assisted Development

- **Process complexity compounds.** A 6-phase pipeline with 10 agent types is itself a complexity problem. Right-size ceremony to scope — and prove the light path works before designing the heavy one.
- **Agent frameworks should emerge from practice, not speculation.** Build the simplest version, feel the pain, add ceremony where the pain was. Designing std/deep tiers before lightweight is validated is premature abstraction.
- **Categorization schemes fail gracefully as free-text.** Rigid enums (10 root cause categories) force agents into wrong buckets. Free-text with pattern detection later is more robust.
- **Prescriptive lists become false requirements.** "Durable decisions include: API routes, DB schema, auth boundaries..." reads as a checklist. "Decisions that cross implementation units" is the principle — the list is examples.

---

## Key Numbers to Remember

| Metric | Value |
|--------|-------|
| Context rot threshold | ~200-256K tokens (even in 1M windows) |
| Cache savings | 10x (cached vs uncached input) |
| Cache TTL | 5 min (refreshes on hit) |
| CLAUDE.md ideal size | <60 lines |
| Instruction budget remaining | ~100-150 after system prompt |
| CLI vs MCP efficiency | 4-32x more token-efficient |
| Subagent overhead | 3-10x vs inline work |
| Parallel agent sweet spot | 3-5 agents |
| Planning ratio | 80% non-coding (plan + review) |
| Verification bottleneck | PR review time +91%, PR size +154% |
| Hook compliance vs CLAUDE.md | 100% vs ~70% |
| Autocompact trigger | ~167K tokens used |
| Lost-in-the-middle drop | ~20-30% accuracy loss |
| Output compression (caveman) | 65-75% output token savings |
| Output vs input cost | 5x multiplier |

---

## Sources

- [Anthropic — Context Engineering for AI Agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- [Manus — Context Engineering Lessons](https://manus.im/blog/Context-Engineering-for-AI-Agents-Lessons-from-Building-Manus)
- [Martin Fowler — Context Engineering for Coding Agents](https://martinfowler.com/articles/exploring-gen-ai/context-engineering-coding-agents.html)
- [Chroma — Context Rot Research](https://www.trychroma.com/research/context-rot)
- [MorphLLM — Why More Tokens Makes Agents Worse](https://www.morphllm.com/context-engineering)
- [Codified Context (arXiv 2602.20478)](https://arxiv.org/abs/2602.20478)
- [Addy Osmani — Code Agent Orchestra](https://addyosmani.com/blog/code-agent-orchestra/)
- [Addy Osmani — The 80% Problem](https://addyo.substack.com/p/the-80-problem-in-agentic-coding)
- [Addy Osmani — How to Write a Good Spec](https://addyosmani.com/blog/good-spec/)
- [HumanLayer — Writing a Good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md)
- [HumanLayer — Skill Issue: Harness Engineering](https://www.humanlayer.dev/blog/skill-issue-harness-engineering-for-coding-agents)
- [Compound Engineering (Every.to)](https://every.to/chain-of-thought/compound-engineering-how-every-codes-with-agents)
- [Silicon Mirror — Anti-Sycophancy Framework](https://arxiv.org/abs/2604.00478)
- [NeuralTrust — Circuit Breakers for AI Agents](https://neuraltrust.ai/blog/circuit-breakers)
- [Arize — Common AI Agent Failures](https://arize.com/blog/common-ai-agent-failures/)
- [Simon Willison — Agentic Engineering Patterns](https://simonwillison.net/guides/agentic-engineering-patterns/red-green-tdd/)
- [Claude Code Best Practices (Official)](https://code.claude.com/docs/en/best-practices)
- [Claude Code Hooks Guide (Official)](https://code.claude.com/docs/en/hooks-guide)
- [Prompt Caching (Official)](https://platform.claude.com/docs/en/build-with-claude/prompt-caching)
- [Anthropic — Multi-Agent Research System](https://www.anthropic.com/engineering/multi-agent-research-system)
- [AGENTS.md Token Optimization Guide](https://smartscope.blog/en/generative-ai/claude/agents-md-token-optimization-guide-2026/)
- [Multi-Agent vs Single-Agent Coding](https://vibecoding.app/blog/multi-agent-vs-single-agent-coding)
- [MCP vs CLI Benchmarks (Scalekit)](https://www.scalekit.com/blog/mcp-vs-cli-use)
- [MCP vs CLI (mariozechner)](https://mariozechner.at/posts/2025-08-15-mcp-vs-cli/)
- [Factory.ai — Using Linters to Direct Agents](https://factory.ai/news/using-linters-to-direct-agents)
- [Spec-Driven Development](https://prommer.net/en/tech/guides/spec-driven-development/)
- [grugbrain.dev — The Grug Brained Developer](https://grugbrain.dev/)
- [JuliusBrussee/caveman — Output Token Compression](https://github.com/JuliusBrussee/caveman)
