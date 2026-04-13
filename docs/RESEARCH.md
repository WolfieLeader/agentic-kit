# Tips & Standards for AI-Assisted Development

Verified and corrected with independent research validation.

Last reviewed: 2026-04-13

Scope: Claude Code, Claude models (Haiku 4.5, Sonnet 4.6, Opus 4.6), English language.

This document mixes official documentation, research findings, field heuristics, and observations of other published frameworks. Treat them differently:

| Tag               | Meaning                                                                                                                                                          |
| ----------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Official          | Vendor or project documentation. Re-check when tools/models change.                                                                                              |
| Study-specific    | True for the cited benchmark or experiment, not automatically universal.                                                                                         |
| Heuristic         | Practical rule of thumb. Validate against your own workflow.                                                                                                     |
| Local measurement | Depends on local config, installed tools, or project shape.                                                                                                      |
| Field observation | Pattern observed in a published competitor framework on a specific date. Describes what someone else built, not validated practice. Re-check URL and commit SHA. |

---

## 1. Core Principle

Context quality is usually the highest-leverage part of AI-assisted development.

Good agents do not need all available information. They need the smallest high-signal context that lets them make the next correct decision.

Practical standard:

- Prefer relevant files, exact commands, current errors, and clear success criteria.
- Avoid dumping whole repos, stale overviews, verbose logs, and unrelated docs.
- Use tools to retrieve context just in time instead of preloading everything.
- Persist durable decisions to files, not just conversation history.
- Verify claims about the codebase by reading the code.

Source class: Official and heuristic. Anthropic's context engineering article describes context as a finite resource with diminishing returns and recommends tight, informative context.

---

## 2. Context Engineering

### Signal Density Beats Context Size

Source class: Official, study-specific, heuristic.

Long context helps only when the additional tokens are relevant and usable. Large irrelevant context can reduce quality by increasing distraction and making relevant facts harder to recover.

Standards:

- Load the 2-10 most relevant files before considering broad context dumps.
- Prefer search results plus focused file reads over full directory ingestion.
- Put the most important instructions, constraints, and current objective near the beginning or end of the active context.
- Keep verbose tool output out of the transcript when a short summary is enough.

Scoping corrections:

- "Token usage explains 80% of performance variance" comes from Anthropic's BrowseComp analysis for their multi-agent Research system. It is not a universal coding-agent law. In that system, tool calls and model choice were the other explanatory factors.
- Long-context degradation has been shown across many models and tasks, but exact thresholds vary by model, task, context contents, and evaluation method.
- A Morph Engineering blog post illustrates $4.80 (200+ files, 800K tokens) vs $0.35 (2 targeted files) for a single task. This is a marketing example with no disclosed methodology, not a benchmark.

### Lost In The Middle

Source class: Study-specific.

The "lost in the middle" effect (Liu et al. 2023, arxiv 2307.03172) means models perform worse when relevant information is buried in the middle of long context compared with the beginning or end.

Specific findings from Liu et al.:

- Multi-document QA: ~20 percentage point drop (75% accuracy at position 1 to 55% at position 10 in 20-document context).
- Key-value retrieval: sharper drops, some models fell below 40% from near-perfect.
- Effects are model-specific and task-dependent. Modern models may show different patterns.

Standards:

- Put the task objective and current checklist near the end of context.
- Put stable governing instructions early.
- After long exploration, restate the current decision, constraints, and next action before implementation.

### Context Rot

Source class: Study-specific and heuristic.

Chroma's context-rot research found that model performance can degrade as input length grows, even on controlled tasks. It also showed that degradation is non-uniform: distractors, semantic similarity, and document structure matter.

Specific Chroma findings:

- Tested at word counts (25 to 10,000 words), not token counts.
- No single threshold. Degradation is progressive and model-specific, starting as early as 250 words for low-similarity queries.
- The claim "degradation starts at 50K tokens" does not appear in Chroma's paper. It is a secondary-source extrapolation.
- Opus 4 (the model version available when the study was conducted, prior to Opus 4.6) showed the slowest degradation rate among tested models.

Standards:

- Treat large context windows as capacity, not permission to include everything.
- Compact before the conversation becomes hard to steer.
- For long tasks, write durable notes, plans, decisions, and verification results to files.
- Use context size thresholds as local heuristics, not universal rules.

### Context Layers

Source class: Heuristic.

| Layer                | Contents                                                      | Practice                      |
| -------------------- | ------------------------------------------------------------- | ----------------------------- |
| Persistent base      | System prompt, tool definitions, project instructions, skills | Keep stable and concise.      |
| Dynamic task context | Relevant files, examples, current plan, recent decisions      | Rotate per task.              |
| Ephemeral context    | Tool outputs, errors, temporary search results                | Summarize or discard quickly. |

### Append-Only Context

Source class: Official and heuristic.

For API agents using prompt caching, stable prefixes matter. Changing early content can reduce cache hits. For coding-agent conversations, append-only notes also preserve traceability.

Standards:

- Keep stable system and tool definitions deterministic.
- Avoid timestamps, random IDs, or changing metadata in stable cached prefixes.
- Append observations rather than rewriting previous observations.
- Keep task state in a file when work spans many tool calls or compactions.

---

## 3. Prompt Caching And Cost

Source class: Official. Re-check pricing before relying on it.

Anthropic API prices as verified on 2026-04-11:

| Model             | Input     | Output     | 5-min cache write | 5-min cache read |
| ----------------- | --------- | ---------- | ----------------- | ---------------- |
| Claude Haiku 4.5  | $1 / MTok | $5 / MTok  | $1.25 / MTok      | $0.10 / MTok     |
| Claude Sonnet 4.6 | $3 / MTok | $15 / MTok | $3.75 / MTok      | $0.30 / MTok     |
| Claude Opus 4.6   | $5 / MTok | $25 / MTok | $6.25 / MTok      | $0.50 / MTok     |

Pricing facts:

- Output tokens cost 5x input tokens for these models.
- 5-minute cache reads cost 10% of base input price.
- 5-minute cache writes cost 125% of base input price.
- Extended 1-hour cache exists and costs more to write.

Prompt caching mechanics:

- Up to 4 cache breakpoints per prompt.
- Minimum cacheable: 4,096 tokens (Haiku 4.5, Opus 4.6), 2,048 tokens (Sonnet 4.6).
- Cache TTL is 5 minutes, refreshed on each hit (sliding window).
- Content must be identical across requests. A single character breaks the cache from that point forward.

Standards:

- Put stable content at the beginning of the prompt.
- Keep serialization deterministic.
- Avoid changing stable cached prefixes.
- Track `cache_read_input_tokens`, `cache_creation_input_tokens`, and normal `input_tokens` separately.

---

## 4. Token Efficiency

Source class: Heuristic and local measurement.

Token efficiency matters, but the target is not "fewest tokens." The target is lowest cost per verified correct outcome.

Standards:

- Compress tool output before feeding it back to the model.
- Use `rg`, `git diff --stat`, focused diffs, and targeted file reads.
- Prefer exact commands over prose instructions.
- Avoid long preambles, repeated summaries, and full passing test output.
- Preserve failing test output, error messages, and changed-file summaries.

### CLI Proxy Pattern

Source class: Local measurement.

Tools like `rtk` can reduce noisy CLI output. The savings depend on command shape and repository size.

Use for:

- `git status`
- `git diff`
- `git log`
- test output where success can be summarized

Do not hide:

- failing assertions
- stack traces needed for diagnosis
- changed-file paths
- security-relevant warnings

### Output Compression

Source class: Heuristic and study-specific.

Prefer a competent, concise engineering voice over persona tricks that may degrade reasoning.

Caveman (JuliusBrussee/caveman) reports ~65% average savings across 10 benchmarks (range 22-87%). The repo claims reasoning is unaffected because only output tokens are compressed; thinking/reasoning tokens remain untouched. Separate output format (terse, structured) from identity (competent, precise) — these are independent levers.

Standards:

- Give output templates for common tasks.
- Set budgets by artifact type.
- Require findings to include "why it matters."
- Keep final answers short unless the user asks for detail.

### Frequently Cited But Unsourced Claims

Several token-efficiency claims appear widely in secondary sources but lack traceable origins:

| Claim                                                | Status                                                                                                                                   |
| ---------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| "Agents have ~100:1 input-to-output ratio"           | Unsourced. OpenRouter programming data shows ~93% input vs 4% output (~23:1). Use measured ratios from your own sessions.                |
| "/compact achieves 60-80% context reduction"         | Not documented by Anthropic. Compaction docs make only qualitative claims. Third-party observations report 50-70%.                       |
| "Autocompact triggers at ~167K tokens"               | Community measurement derived from ~83.5% of 200K window. Not officially documented. Configurable via `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE`. |
| "Auto mode burns 5-20x more tokens than interactive" | No traceable source. The 5x and 20x in public discourse refer to Claude Code Max pricing tiers, not token rates.                         |
| "CLAUDE.md instruction compliance ~60-70%"           | Community observation, not officially measured by Anthropic. Depends on instruction clarity, complexity, and model defaults. See §5.     |

---

## 5. Project Instructions

Source class: Official and heuristic.

Project instructions compete with task context. Keep always-loaded instructions short, durable, and hard to infer.

Include:

- exact build, test, lint, and format commands
- non-obvious architecture constraints
- security or data-handling rules
- project-specific gotchas that models repeatedly miss
- pointers to deeper docs instead of copying them inline

Exclude:

- generic style rules enforced by formatter/linter
- stale directory listings
- long architecture essays
- generated boilerplate from `/init` unless reviewed
- facts that change often unless they point to a source of truth

Size standard:

- Ideal: short enough to scan quickly.
- Maximum: whatever is justified by repeated observed failures.
- Better than line-count dogma: measure whether the instructions reduce mistakes.

### ETH Zurich AGENTS.md Study

Source class: Study-specific. (arxiv 2602.11988)

Tested 138 real-world Python tasks across multiple coding agents:

- Human-written context files: ~4% average improvement, +19% inference cost.
- LLM-generated files: reduced success rate in 5 of 8 settings (-0.5% on SWE-bench Lite, -2% on AGENTbench), +20-23% cost.
- 95-100% of LLM-generated files included repository overviews. Agents discovered relevant files no faster than with no context file.
- Recommendation: omit LLM-generated context files. Limit human-written instructions to non-inferable details.

### Instruction Compliance

Source class: Heuristic. Not officially measured.

Multiple practitioners report CLAUDE.md instruction compliance around 60-70%. This is a community observation, not an official Anthropic measurement. The exact rate depends on instruction clarity, complexity, and alignment with model defaults.

Hooks achieve deterministic compliance by executing code rather than relying on model adherence.

### Progressive Disclosure

Source class: Official and heuristic.

Use small always-loaded files plus on-demand references:

- root `CLAUDE.md` for universal rules
- subdirectory instructions for area-specific constraints
- skills for workflows
- references for phase-specific detail
- templates for artifacts

### Instructions vs Guardrails

Source class: Official and heuristic.

Use deterministic mechanisms for deterministic rules:

- formatter for formatting
- linter for style and bug patterns
- type checker for type boundaries
- tests for behavior
- hooks for repeatable workflow checks

Use instructions for judgment:

- architectural tradeoffs
- scope boundaries
- collaboration behavior
- when to ask for clarification

---

## 6. Claude Code Hooks

Source class: Official. Re-check when Claude Code updates.

Hooks are user-defined commands or model-based checks that run at lifecycle events. They make workflow behavior deterministic instead of relying on the model to remember.

Hook event types:

- `PreToolUse` can block or modify tool calls before execution.
- `PostToolUse` runs after a successful tool call; provides corrective feedback.
- `Notification` fires on user-relevant events.
- `PreCompact` and `PostCompact` run around context compaction.
- All matching hooks run in parallel. Identical handlers are deduplicated.
- `PreToolUse` decision precedence: `deny > defer > ask > allow`.

Good uses:

- block dangerous shell commands
- prevent edits to protected files
- format after edits
- run focused checks after changes
- notify when user input is needed
- re-inject important context after compaction

Security standard:

- Hooks run with the user's system permissions.
- Treat hook inputs as untrusted.
- Quote shell variables.
- Use absolute script paths or documented project/plugin variables.
- Keep failure output concise and actionable.

---

## 7. Tool Hierarchy

Source class: Heuristic and study-specific.

Prefer the lowest-overhead tool that reliably solves the task.

| Tool type | Strength                                                      | Cost/risk                                           |
| --------- | ------------------------------------------------------------- | --------------------------------------------------- |
| CLI       | Fast, scriptable, terse output, existing auth                 | Requires command knowledge and safe shell handling  |
| Skills    | Low at-rest overhead, good for workflows and domain practices | Trigger descriptions still consume attention        |
| MCP       | Rich integrations and structured tools                        | Can add many tool definitions and ambiguous choices |

### CLI vs MCP Benchmark

Source class: Study-specific. (Scalekit, 2025)

Scalekit benchmarked GitHub operations via CLI (`gh`) versus GitHub MCP:

- Token efficiency: 10-32x advantage for CLI. Worst case: 1,365 tokens via CLI vs 44,026 via MCP (32x).
- Reliability: MCP had 28% failure rate vs CLI 0%.
- Root cause of MCP overhead: carrying all 43 tool schemas on every call.
- Schema filtering at a gateway layer can close the gap by ~90%.

Standards:

- Prefer CLI for mature external tools: `gh`, `aws`, `gcloud`, `sentry-cli`, database CLIs.
- Use skills to teach process, quality bars, artifact formats, and domain workflow.
- Use MCP when it gives data or actions that CLI cannot provide cleanly.
- Keep MCP server count small unless each server has a clear job.

MCP can be better when it provides safe structured actions, auth, discovery, or data not available through CLI.

---

## 8. Spec-Driven Development

Source class: Heuristic.

For new work, the spec should drive implementation. For existing systems, the current code and tests remain the source of truth for current behavior.

Workflow:

```text
INTENT -> RESEARCH -> SPEC -> PLAN -> IMPLEMENT -> VERIFY -> REVIEW -> RELEASE
```

Good specs include:

- purpose and non-goals
- affected systems
- exact acceptance criteria
- relevant constraints
- examples of desired behavior
- links to source files or prior decisions
- open questions

Avoid:

- "build something cool"
- 50-page undifferentiated context dumps
- implementation detail unless it constrains behavior
- letting agent speed exceed human verification capacity

Planning ratio:

- "80% planning/review, 20% coding" is a useful reminder for complex work, not a law.
- Right-size ceremony to scope.
- For tiny edits, a short plan and direct verification may be enough.

---

## 9. Multi-Agent Workflows

Source class: Official, study-specific, heuristic.

Multi-agent systems help when work is parallel, information-heavy, and decomposable. They hurt when work is sequential, tightly coupled, or small.

### Anthropic Multi-Agent Research System

Source class: Official. (June 2025)

- Multi-agent (Opus 4 lead + Sonnet 4 subagents, the model versions at time of publication) outperformed single-agent Opus 4 by 90.2% on internal research eval.
- In BrowseComp analysis, token usage explained 80% of variance, with tool calls and model choice as additional factors.
- Multi-agent systems used about 15x more tokens than chat interactions. Single agents used about 4x more than chat.
- "Most coding tasks involve fewer truly parallelizable tasks than research, and LLM agents are not yet great at coordinating and delegating to other agents in real time."

Scope limitation: these are research-system results on information-retrieval tasks, not proof that multi-agent coding is always better.

### Google Research: Scaling Agent Systems

Source class: Study-specific. (Kim & Liu, Google Research, January 2026)

"Towards a Science of Scaling Agent Systems" tested five agent architectures across four benchmarks:

- Finance-Agent (parallelizable financial reasoning): centralized multi-agent achieved +80.9% over single-agent.
- PlanCraft (sequential, state-dependent planning): all multi-agent variants degraded performance by 39-70%.
- Developed a predictive model achieving 87% accuracy for identifying optimal architectures for unseen tasks.

Key finding: multi-agent is not a universal solution. It can significantly boost or unexpectedly degrade performance depending on task structure.

### Token Consumption Studies

Source class: Study-specific.

The "Tokenomics" paper (Concordia University, arxiv 2601.14470, MSR '26) analyzed token distribution in multi-agent software engineering:

- Code review phase consumed 59.4% of total tokens due to iterative full-code-context passing.
- The paper analyzes where tokens are spent, not consumption multipliers.

A separate study (arxiv 2604.02460) found that under equal token budgets, single-agent LLMs can outperform multi-agent systems on multi-hop reasoning tasks.

Note: the "4-220x more tokens" figure attributed to a "UIUC study" in some secondary sources has no traceable origin. It does not appear in the Tokenomics paper or other identifiable research.

### Unsourced Multi-Agent Claims

"Three focused agents consistently outperform one generalist working three times longer" is from Addy Osmani's blog. No empirical evidence is cited; the argument is conceptual. Treat as practitioner opinion.

### When To Use Subagents

Use subagents for:

- independent codebase exploration
- docs research
- unbiased review
- parallel implementation in disjoint files
- tasks where isolated context improves quality

Avoid subagents for:

- simple edits
- sequential dependent work
- tasks where the next step depends on one result
- write-heavy work in overlapping files

Dispatch standard:

- Give each agent a concrete objective.
- Include search terms and expected sources.
- Define file or module ownership for writers.
- Require findings to distinguish verified facts from assumptions.
- Require short outputs with "why it matters."

Coordination standard:

- Prefer 2-5 agents for most local development tasks.
- Use clear ownership boundaries.
- Avoid duplicate investigations.
- Preserve subagent findings in files when they are durable.
- Review and integrate subagent work; do not blindly trust it.

---

## 10. Git Worktrees And Parallel Development

Source class: Official and heuristic.

Worktrees isolate branches and working directories so parallel agents or sessions do not overwrite each other.

Use worktrees when:

- tasks take more than a few minutes
- work touches different modules
- parallel review or implementation is useful
- you want isolated history

Avoid or be careful when:

- agents share the same database, Docker daemon, local server, or cache
- tasks modify the same files
- setup cost exceeds task size

Claude Code note:

- Claude Code supports `claude --worktree` and `claude --worktree <name>` for isolated sessions.
- Re-check short flags against the installed CLI before documenting them.

Standards:

- 3-5 parallel sessions is a practical ceiling before context-switching overhead dominates.
- One file, one owner during parallel edits.
- Record which worktree owns which scope.
- Keep branch names descriptive.
- Clean up abandoned worktrees.
- Run verification in the worktree that owns the change.

---

## 11. Quality And Verification

Source class: Official, heuristic.

The bottleneck in AI-assisted development is often verification, not generation.

Standards:

- Prefer tests that verify behavior through public interfaces.
- Add regression tests for bugs.
- Use type checking and linting as mandatory gates.
- Run the narrowest meaningful test first, then broader checks.
- For UI, verify in browser or with screenshots, not just type checks.
- For user-facing behavior, test the actual workflow.

### TDD With Agents

Source class: Heuristic.

Red/green TDD is especially useful with agents:

1. Write a failing test that captures desired behavior.
2. Confirm it fails for the right reason.
3. Implement until it passes.
4. Refactor only after the behavior is protected.

Not mandatory for every tiny edit, but valuable when behavior is ambiguous or regression risk is meaningful.

### Reviews

Source class: Heuristic.

Review should focus on:

- behavioral regressions
- missing tests
- incorrect assumptions
- security and data risks
- concurrency and state issues
- error handling
- migration and compatibility risks

Fresh-context review is useful because the writer often shares the same blind spots as the implementation.

### Anti-Sycophancy

Source class: Study-specific and heuristic.

Models can over-agree with users.

Silicon Mirror framework (arxiv 2604.00478):

- Tested on 437 TruthfulQA adversarial scenarios.
- Claude Sonnet 4: sycophancy dropped from 9.6% to 1.4% (85.7% relative reduction, p < 10^-6).
- Cross-model on Gemini 2.5 Flash: 46.0% baseline to 14.2% (cited for study completeness; outside scope).
- Uses three-part architecture: Behavioral Access Control, Trait Classifier, Generator-Critic loop.
- Numbers are specific to this orchestration framework, not a general model property.

Counter with explicit review posture:

- Ask the model to identify reasons the proposal may be wrong.
- Require evidence for claims.
- Make disagreement acceptable when justified.
- When changing position, name the evidence that changed it.

---

## 12. Model Routing

Source class: Heuristic. Re-check current model lineup.

Match model capability to task risk. Scoped to Claude model family.

| Task                                                                   | Model      | Reasoning                                                       |
| ---------------------------------------------------------------------- | ---------- | --------------------------------------------------------------- |
| File search, classification, placeholder scanning, simple transforms   | Haiku 4.5  | Cheapest ($1/$5), fastest. Deterministic checks, low ambiguity. |
| Feature work, code review, exploration, daily coding                   | Sonnet 4.6 | Balance of capability and cost ($3/$15).                        |
| Complex architecture, subtle bugs, multi-file refactors, orchestration | Opus 4.6   | Strongest reasoning ($5/$25). High-ambiguity work.              |

Standards:

- Upgrade model when failures are due to reasoning, not missing context.
- Improve context when failures are due to missing or noisy information.
- Use cheaper models when the task has deterministic checks and low ambiguity.
- Do not state fixed capability ratios between models unless backed by a current benchmark.

---

## 13. Library And Stack Choices

Source class: Heuristic and study-specific.

Models usually perform better with widely adopted, well-documented technologies.

A survey of LLM code generation for low-resource languages (arxiv 2410.03981) confirms that LLMs perform significantly worse on languages underrepresented in training data (OCaml, Racket, R) compared to high-resource languages (Python, JavaScript, Java). This extends logically to frameworks and libraries, though no study directly benchmarks framework popularity against AI code quality.

Standards:

- Prefer boring, popular libraries for AI-assisted work unless there is a product reason not to.
- Prefer versions with strong docs, stable APIs, and known migration paths.
- For very new major versions, provide current docs and local examples.
- For proprietary or niche frameworks, create small local exemplars and tests.

Correction:

- "Recent major versions have more training examples" is often false. Newer versions may have less training coverage. Prefer "well-adopted and well-documented versions."

---

## 14. Codebase Organization For Agents

Source class: Heuristic.

Agents navigate best when source-of-truth files are easy to find.

Good patterns:

- clear root README
- exact commands in `package.json`, `Makefile`, `justfile`, or equivalent
- small module READMEs for complex folders
- architecture decision records for durable choices
- stable file naming
- feature folders when locality is more useful than layer separation

Avoid:

- stale exhaustive directory listings
- duplicated setup instructions
- docs that describe old architecture
- hidden conventions enforced only by tribal knowledge

Navigation rule: stale docs are worse than no docs. If a doc cannot be maintained, replace it with links to source-of-truth files.

### Claude Code Settings

Source class: Official. Re-check current docs.

Current precedence:

1. managed settings
2. command line arguments
3. local project settings
4. shared project settings
5. user settings

Do not document undocumented settings object shapes as official.

---

## 15. Memory And Knowledge Compounding

Source class: Official and heuristic.

Persist information that helps future tasks. Do not persist noise.

Persist:

- repeated mistakes and fixes
- project conventions
- decisions and tradeoffs
- integration behavior that will matter again
- commands and verification recipes
- durable research about third-party services

Do not persist:

- intermediate grep output
- full passing test logs
- dead-end searches
- duplicate summaries
- stale assumptions

Standards:

- Date external research.
- Include source URLs.
- Record what was verified versus inferred.
- Keep hot memory small and stable.
- Put detailed references behind links or files loaded on demand.

---

## 16. Skill And Agent Design

Source class: Official and heuristic.

Skills should teach workflows. Agents should perform bounded roles.

Skill standards:

- Description only defines trigger conditions.
- Main SKILL.md stays concise.
- Use `references/` for phase-specific detail.
- Use templates for artifacts.
- Include hard gates only for truly non-negotiable steps.
- Include violation examples for rules the model often rationalizes away.

Agent standards:

- Define role, inputs, tools, file budget, and output format.
- Encode search procedure, not just responsibility.
- Require source attribution.
- Require gaps and open questions.
- Keep output short enough for the caller to use.

Persona standard:

- Use role + trait when it improves behavior:
  - "Correctness reviewer. Skeptical, evidence-only."
  - "Implementation planner. Conservative, codebase-first."
- Avoid roleplay that makes the model less capable.

Instruction framing:

- Positive, concrete instructions beat vague or purely negative ones.
- Examples beat abstract principles.
- Output templates beat "be concise."
- Hard gates should include what to do next, not only what to avoid.

---

## 17. Complexity Management

Source class: Heuristic.

Complexity is a real cost. AI can generate code faster than teams can understand, verify, and maintain it.

Standards:

- Start with the simplest design that satisfies current requirements.
- Prefer duplication over premature abstraction until the abstraction boundary is clear.
- Understand why existing code exists before replacing it.
- Keep related behavior close together when that improves comprehension.
- Add process only after the light path fails in a repeated, observable way.
- Treat rigid categorization schemes as optional unless they drive action.

Applied to agent frameworks:

- Do not build a 6-phase process for a 6-line bug fix unless the workflow has proven value.
- Keep lightweight, standard, and deep paths consistent but not equally ceremonial.
- Use free-text findings when rigid categories would force bad classification.
- Validate framework changes with real tasks, not just intuition.

---

## 18. Framework Field Analysis

Source class: Field observation (introduced in this revision).

Purpose: survey published competitor frameworks and capture the mechanisms they deploy, so absorption or rejection is deliberate rather than by omission. Each writeup is a neutral description of someone else's work; recommendations live in §18.10.

Method: 9 parallel subagents dispatched 2026-04-13. 5 deep (Opus) for the frameworks suspected to have the most to teach (Karpathy's wiki pattern, Addy Osmani, Superpowers, Compound Engineering, Matt Pocock). 4 shallow (Sonnet) for coverage (CC10X, Spec-Kit, Sequential Thinking MCP, Everything Claude Code). Agents were instructed not to compare against any reference framework -- pure observation only. Synthesis is the reader's job (§18.10).

Epistemic handling: treat competitor patterns as observations, not validated practice. Star counts and marketing claims are not evidence of effectiveness. What matters is the _mechanism_ each framework deploys and whether it addresses a constraint this framework also faces.

### 18.1 Karpathy -- LLM Wiki / Personal Knowledge Compounding

Source class: Field observation.

**Primary source:** https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f (gist titled "llm-wiki", posted April 4, 2026 per antigravity.codes; accessed 2026-04-13)
**Supporting sources:**

- Karpathy follow-up tweet, ~April 2-3, 2026: https://x.com/karpathy/status/2040572272944324650 (accessed 2026-04-13)
- https://antigravity.codes/blog/karpathy-llm-wiki-idea-file (secondary; reproduces gist quotes; accessed 2026-04-13)
- https://reliabilitywhisperer.substack.com/p/the-andrej-karpathy-llm-wiki-idea (secondary; "knowledge as compiled code" framing; accessed 2026-04-13)

**Format:** Tweet thread announcing a GitHub gist elaborating the pattern as an "idea file." The gist is the canonical artifact.
**Scope (author's stated scope):** A personal, LLM-maintained markdown wiki compiled from a user's curated raw sources, intended to replace on-the-fly RAG retrieval for knowledge work the user cares about over time. [Inference from gist structure and tweet framing]

**What's distinctive:**

Karpathy frames the wiki as a compiled layer sitting between raw sources and queries. [Direct quote: "Instead of just retrieving from raw documents at query time, the LLM incrementally builds and maintains a persistent wiki."] The motivation is that pure RAG does not accumulate: [Direct quote: "The LLM is rediscovering knowledge from scratch on every question. There's no accumulation."]

Three-layer structure: (1) `raw/` holds curated source documents (articles, papers, repos, datasets, images) that are never modified; (2) a `wiki/` directory of LLM-generated markdown that the LLM "owns entirely" -- including `index.md` (content catalog), `log.md` (append-only chronological record), plus sub-directories like `concepts/`, `entities/`, `sources/`, `comparisons/`; (3) a schema file (`CLAUDE.md` or `AGENTS.md`) describing conventions.

Recompilation is LLM-driven across three named operations. [Direct quote: "Ingest. You drop a new source into the raw collection... Query. You ask questions against the wiki... Lint. Periodically, ask the LLM to health-check the wiki."] On ingest the LLM reads the new source, writes/updates pages, notes contradictions, and strengthens cross-references; lint passes check for contradictions, stale claims, and orphan pages. Compiled-once property: [Direct quote: "The knowledge is compiled once and then kept current, not re-derived on every query."]

**Mechanisms worth observing:**

- Three-layer separation with strict ownership: raw sources immutable user-curated input; wiki layer LLM-owned; schema file instructs the agent. [Direct quote: "You never (or rarely) write the wiki yourself -- the LLM writes and maintains all of it."]
- Two index artifacts on orthogonal axes: [Direct quote: "index.md is content-oriented... log.md is chronological. It's an append-only record."]
- Three named operations as entry points: ingest / query / lint. Lint is scheduled/on-demand rather than continuous. [Inference from "Periodically" wording]
- Query outputs can be promoted back into the wiki as new pages, so exploration compounds alongside ingested sources. [Paraphrase from secondary summaries]
- Division of labor stated explicitly: [Direct quote: "The human's job is to curate sources, direct the analysis, ask good questions, and think about what it all means. The LLM's job is everything else."]
- Tooling suggestion: [Direct quote: "Obsidian is the IDE; the LLM is the programmer; the wiki is the codebase."]

**Scoping notes:**

Karpathy's stated scope is personal knowledge, his own curated reading pile, compiled for his own queries. The gist is framed as an "idea file" / pattern proposal rather than a tested system with metrics -- no effectiveness data, no user studies, no claim about team or codebase use. Extension to shared team knowledge or live codebases is not addressed. Evidence is anecdotal: Karpathy reports his own token throughput shifted toward "manipulating" knowledge rather than code, but the gist offers no before/after measurements. The gist is light on concrete recompilation triggers beyond "periodically" for lint and "on drop" for ingest; it does not prescribe update frequency, conflict-resolution rules, or failure modes when the LLM mis-compiles. Secondary implementers have filled in these details; those additions are not Karpathy's.

### 18.2 Addy Osmani -- Agent-Skills & Orchestration Patterns

Source class: Field observation.

**Primary sources:**

- https://addyosmani.com/blog/code-agent-orchestra/ (accessed 2026-04-13)
- https://addyosmani.com/blog/good-spec/ (accessed 2026-04-13)
- https://github.com/addyosmani/agent-skills (accessed 2026-04-13)
- https://github.com/addyosmani/web-quality-skills (accessed 2026-04-13)

**Format:** Blog posts and GitHub repos (two skill libraries plus written essays).
**Scope (author's stated scope):** Production-grade engineering workflows packaged so AI coding agents follow senior-engineer practices "consistently across every phase of development." [Direct quote, README of agent-skills]

**What's distinctive:**

On spec-driven workflow: Osmani frames a "good spec" as a structured PRD-style document that focuses on "what and why, more than the nitty-gritty how (at least initially)." He identifies six core sections derived from "GitHub's analysis of over 2,500 agent configuration files" [Paraphrase]: Commands, Testing, Project Structure, Code Style, Git Workflow, and Boundaries. His template uses a three-tier boundaries block -- [Direct quote: "Always" / "Ask first" / "Never"]. He recommends in-spec verification: self-verification via embedded tests/lint, "LLM-as-a-Judge" for stylistic criteria, and conformance suites (often YAML) acting as "a contract for expected inputs/outputs."

On multi-agent orchestration: The "Code Agent Orchestra" essay names three patterns -- Subagents (parent decomposes, children own files, manual coordination), Agent Teams (shared task list, file locking, peer-to-peer messaging, [Direct quote: "3-5 teammates is the sweet spot"]), and the "Ralph Loop" (stateless-but-iterative cycle: pick task, implement, validate, commit, reset). [Direct quote: "You're no longer just writing code. You're building the factory that builds your software."] Core diagnostic claim: [Direct quote: "The bottleneck has shifted... It's verification."]

On published skill templates: `agent-skills` ships 20 skills across six lifecycle phases (Define/Plan/Build/Verify/Review/Ship), 7 slash commands (`/spec`, `/plan`, `/build`, `/test`, `/review`, `/code-simplify`, `/ship`), 3 agent personas, session lifecycle hooks. Every skill has fixed anatomy: Overview, When to Use, Process, Common Rationalizations, Red Flags, Verification. YAML frontmatter requires `name` and `description`; description starts with what the skill does in third person followed by "Use when..." triggers. [Direct quote, README]

**Mechanisms worth observing:**

- **Intent -> Skill mapping table** in AGENTS.md with hard rules: [Direct quote: "If a task matches a skill, you MUST invoke it... Never implement directly if a skill applies... Always follow the skill instructions exactly."]
- **Six-section skill anatomy** including "Common Rationalizations" to pre-empt agent excuses for skipping workflow.
- **Three-tier boundaries grammar** (Always / Ask first / Never) embedded in spec template.
- **AGENTS.md curation rule:** [Direct quote: "Never let an agent write to AGENTS.md directly. The lead must approve every line."]
- **Model routing per phase:** planning to one model, implementation to another, review to a dedicated security model. [Paraphrase]

**Scoping notes:**

Osmani's evidence base is mixed. The good-spec post cites GitHub's analysis of 2,500+ agent configuration files as quantitative grounding for the six-section structure. He cites Gloaguen et al. (ETH Zurich) for the counterintuitive finding that "LLM-generated AGENTS.md files offer no benefit... Developer-written context files... provide modest ~4% improvement." [Direct quote] When drawing on empirical work, he names it.

The characterization in §9 that "three focused agents outperform one generalist" lacks empirical citation is **confirmed**: Osmani states this claim and frames four multiplicative mechanisms (parallelism, specialization, isolation, compound learning), but provides no measurement, A/B test, or external citation for the headline assertion. "3-5 teammates is the sweet spot" and "Token costs scale linearly with team size" are practitioner heuristics without published data. The repo content is observable artifact; the orchestration performance claims are practitioner assertion.

### 18.3 Superpowers (obra / Jesse Vincent)

Source class: Field observation.

**Primary source:** https://github.com/obra/superpowers -- main branch, observed commit `917e5f5` (2026-04-06), last pushed 2026-04-10, accessed 2026-04-13.
**Format:** Claude Code plugin / skill framework (also ships Cursor, Codex, OpenCode, Copilot CLI, Gemini CLI adapters).
**Scope (stated):** [Direct quote, README: "Superpowers is a complete software development workflow for your coding agents, built on top of a set of composable 'skills' and some initial instructions that make sure your agent uses them."]

**Structure (concrete):**

- Skills: 14 directories under `skills/` -- `brainstorming`, `dispatching-parallel-agents`, `executing-plans`, `finishing-a-development-branch`, `receiving-code-review`, `requesting-code-review`, `subagent-driven-development`, `systematic-debugging`, `test-driven-development`, `using-git-worktrees`, `using-superpowers`, `verification-before-completion`, `writing-plans`, `writing-skills`.
- Agents: 1 (`agents/code-reviewer.md`).
- Hooks: 1 event -- `SessionStart` (matcher `"startup|clear|compact"`), invoking `${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd session-start`.
- Commands: 3 (`commands/brainstorm.md`, `commands/execute-plan.md`, `commands/write-plan.md`).
- Cross-platform: `.claude-plugin/`, `.cursor-plugin/`, `.codex/`, `.opencode/`, `gemini-extension.json`.

**What's distinctive:**

Skill frontmatter is minimal: `name` + `description` only, no explicit triggers, priorities, or tool lists. Auto-trigger is achieved via description framing. [Direct quote, `skills/using-superpowers/SKILL.md`: "If you think there is even a 1% chance a skill might apply to what you are doing, you ABSOLUTELY MUST invoke the skill."] Skills contain DOT graphviz flowcharts as canonical process diagrams (observed in `using-superpowers`, `test-driven-development`, `brainstorming`, `subagent-driven-development`).

Orchestration is a directed pipeline. [Paraphrase, README "Basic Workflow"] intended chain: `brainstorming -> using-git-worktrees -> writing-plans -> subagent-driven-development | executing-plans -> test-driven-development -> requesting-code-review -> finishing-a-development-branch`. Skills name-drop each other. [Direct quote, brainstorming/SKILL.md: "The terminal state is invoking writing-plans. Do NOT invoke frontend-design, mcp-builder, or any other implementation skill. The ONLY skill you invoke after brainstorming is writing-plans."] `subagent-driven-development/SKILL.md` dispatches fresh subagents per task using three prompt files (`implementer-prompt.md`, `spec-reviewer-prompt.md`, `code-quality-reviewer-prompt.md`) -- a two-stage review pattern.

The `SessionStart` hook is load-bearing. On every session start/clear/compact, the bash script inlines the full contents of `skills/using-superpowers/SKILL.md` into `additionalContext` wrapped in `<EXTREMELY_IMPORTANT>` tags -- the skill-invocation rule is injected at turn zero rather than discovered lazily. The script emits platform-specific JSON shapes. Design artifacts persist to `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`. Skills use custom XML pseudo-tags (`<HARD-GATE>`, `<SUBAGENT-STOP>`, `<EXTREMELY-IMPORTANT>`) as attention markers -- prose conventions, not validated schema.

**Mechanisms worth observing:**

- `SessionStart` hook that inlines a "meta-skill" into session context on every startup/clear/compact.
- Two-stage subagent review pattern (spec reviewer then code-quality reviewer) with separate prompt files per role.
- DOT graphviz flowcharts embedded in Markdown skills as machine-readable decision logic.
- Named "Iron Law" doctrine in key skills (`NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST`, `NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST`).
- Explicit cross-platform adapter layout with one canonical skills tree.

**Scoping notes:**

Stars reported by GitHub API: 149,981; forks 12,966. [Inference] This figure is anomalous for a 6-month-old repo (created 2025-10-09) and is plausibly inflated or API-artifact -- treat as unverified. CHANGELOG version `5.0.5` implies five major versions in six months -- rapid iteration. Gap between README aspiration and code: the 7-step chain's enforcement lives entirely in skill prose ("You MUST invoke writing-plans") rather than code-level hooks, so adherence depends on model compliance with textual directives. `AGENTS.md` is a 9-byte file (stub) despite multiple platforms reading that filename. `CLAUDE.md` opens: [Direct quote: "This repo has a 94% PR rejection rate. Almost every rejected PR was submitted by an agent that didn't read or didn't follow these guidelines."] -- indicating adversarial AI-PR history.

### 18.4 Compound Engineering (EveryInc)

Source class: Field observation.

**Primary sources:**

- https://every.to/chain-of-thought/compound-engineering-how-every-codes-with-agents (Shipper & Klaassen, accessed 2026-04-13)
- https://every.to/source-code/compound-engineering-the-definitive-guide (Klaassen, partially paywalled, accessed 2026-04-13)
- https://every.to/source-code/my-ai-had-already-fixed-the-code-before-i-saw-it (origin essay, accessed 2026-04-13)
- https://github.com/EveryInc/compound-engineering-plugin (MIT, accessed 2026-04-13)

**Format:** Essays (Every "Compounding Engineering" column), an open-source plugin (50+ agents, 41+ skills, multi-target CLI), podcast appearances, a "Compound Engineering Camp" event series.
**Scope (stated):** [Direct quote, Klaassen plugin README: "Each unit of engineering work should make subsequent units easier -- not harder."]

**What's distinctive:**

The "compounding" claim is about _institutional knowledge baked into agent context_, not engineer hours per se. [Direct quote, Shipper & Klaassen: "each feature makes the next feature easier to build"] because [Direct quote: "each bug, failed test, or problem-solving insight gets documented and used by future agents"]. Origin: Klaassen noticed Claude Code was applying patterns from three months of prior PR reviews unprompted, which suggested treating review artifacts as a deliberate training surface.

The prescribed workflow is a four-step loop **Plan -> Work -> Review -> Compound** (sometimes prefixed with **Ideate -> Brainstorm**), with [Direct quote: "80 percent of compound engineering is in the plan and review parts, while 20 percent is in the work and compound."] Concrete techniques: parallel sub-agents during planning (codebase + commit history + web research); MCPs (Playwright, XcodeBuildMCP) for real-usage simulation; tiered persona review agents running in parallel -- security, performance, correctness, maintainability, reliability, data integrity -- plus role-personas like `dhh-rails-reviewer`, `kieran-rails-reviewer`; `/ce:compound` and `/ce:compound-refresh` slash commands that promote solved problems into `docs/solutions/` markdown with YAML frontmatter and a category enum.

Context separation is explicit. [Direct quote, plugin AGENTS.md: "**Workflow state** (`.context/`): Files that other skills or agents in the same session may need to read -- plans in progress, gate files, inter-skill handoff artifacts. Namespace under `.context/compound-engineering/<workflow-or-skill-name>/`, add a per-run subdirectory when concurrent runs are plausible, and clean up after successful completion."] Throwaway artifacts go to `mktemp -d` outside the repo. Durable knowledge lives in repo-tracked `docs/brainstorms/`, `docs/plans/`, `docs/solutions/`, `docs/specs/`, plus `CLAUDE.md` (coding preferences) and `llms.txt` (architectural principles). Multi-day memory: [Direct quote: "Read them on-demand at the step that needs them -- do not bulk-load at skill start."]

**Mechanisms worth observing:**

- Three-tier scratch/memory split: `.context/<plugin>/<workflow>/<run>/` (session-scoped), `mktemp -d` (OS-temp throwaways), `docs/solutions/` (frontmatter-indexed, durable).
- Bug -> test -> rule conversion: failed test runs analyzed for patterns; successful iterations update the originating prompt.
- Parallel persona reviewers aggregating into a deduped report with confidence calibration.
- Fully-qualified agent references (`compound-engineering:<category>:<agent-name>`) and self-contained skill directories to stay portable across 11+ agent platforms.
- `/ce:compound-refresh` to revisit older `docs/solutions/` entries and decide keep/update/replace/archive -- explicit learning-rot prevention.

**Scoping notes:**

Philosophy (four-step loop, 80/20 split) is prescribed in essays. The plugin is one concrete instantiation; the CLI converts skills across 11+ agent platforms, so the _shape_ is portable while the specific 50+ agents are illustrative of Every's stack (heavy Rails, TypeScript, Python, iOS) and house personas. Productivity claims -- [Direct quote: "a single developer can do the work of five developers a few years ago"] and [Direct quote, Klaassen origin: "Feature time-to-ship: reduced from 1+ week to 1-3 days"] -- are anecdotal/internal, not benchmarked. No controlled study, comparison cohort, or measurement methodology is published for the "5x" multiplier. Every is a paid newsletter; the "definitive guide" full text is paywalled past the philosophy section. The plugin and its docs are fully open under MIT.

### 18.5 Matt Pocock -- Skills / Agent Library

Source class: Field observation.

**Primary source:** https://github.com/mattpocock/skills @ commit `651eab0` (pushed 2026-04-01, accessed 2026-04-13)
**Format:** Repo.
**Scope (stated):** [Direct quote: "My personal directory of skills, straight from my .claude directory."]

**Structure:**

- Skills: 20 top-level skill directories -- `design-an-interface`, `edit-article`, `git-guardrails-claude-code`, `github-triage`, `grill-me`, `improve-codebase-architecture`, `migrate-to-shoehorn`, `obsidian-vault`, `prd-to-issues`, `prd-to-plan`, `qa`, `request-refactor-plan`, `scaffold-exercises`, `setup-pre-commit`, `tdd`, `triage-issue`, `ubiquitous-language`, `write-a-prd`, `write-a-skill`.
- Each skill is a self-contained folder with `SKILL.md` and sibling reference files where needed (e.g. `tdd/` holds `deep-modules.md`, `interface-design.md`, `mocking.md`, `refactoring.md`, `tests.md`).

**What's distinctive:**

Skill shape is spartan. Every `SKILL.md` uses a two-field YAML frontmatter: `name` and `description`. [Direct quote, `write-a-skill/SKILL.md`: "The description is **the only thing your agent sees** when deciding which skill to load."] Convention: `description` max 1024 chars, third person, first sentence = what it does, second sentence = "Use when [specific triggers]". Bodies are short imperative prose; [Direct quote: "SKILL.md under 100 lines"] in his own review checklist. Overflow goes into sibling Markdown files linked one level deep.

Domain focus is NOT TypeScript-specific despite his identity. [Inference] The library is generalist engineering-process toolkit: PRD authoring, plan decomposition, TDD, refactor planning, issue triage. Only `migrate-to-shoehorn` is TS-specific. Thinking is shaped by "A Philosophy of Software Design" -- `tdd/deep-modules.md` reproduces Ousterhout's deep-module diagram. [Direct quote: "Actively look for opportunities to extract deep modules that can be tested in isolation."]

Several distinctive patterns. (1) Relentless interviewing as a first-class primitive: `grill-me` is a reusable sub-skill; `write-a-prd` says [Direct quote: "Interview the user relentlessly about every aspect of this plan until you reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one."] (2) Vertical-slice / tracer-bullet TDD: [Direct quote, tdd/SKILL.md: "**DO NOT write all tests first, then all implementation.**"] with [Direct quote: "Never refactor while RED."] (3) Labeled state-machine for GitHub issue triage in `github-triage/SKILL.md`: transition table from `unlabeled` through `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`, each transition spelling out trigger and side-effect.

**Mechanisms worth observing:**

- Frontmatter reduced to the two fields that affect routing (`name`, `description`), with format rules encoded in a `write-a-skill` meta-skill.
- Sibling-file progressive disclosure: SKILL.md short; reference material lives as plain `.md` peers linked one level deep only.
- `grill-me` as composable interviewing primitive reused by `write-a-prd`, `request-refactor-plan`, `github-triage`.
- Explicit anti-patterns in-line (e.g. `tdd/SKILL.md` names "horizontal slicing" and explains why) rather than only happy-path prescriptions.
- State-machine-as-table for workflow skills: transitions, triggers, side-effects as a Markdown table the agent consults.
- Preview-before-mutate gate: [Direct quote, github-triage/SKILL.md: "Before posting any comment or applying any label, show the maintainer a **preview** of exactly what will be posted and which labels will be applied/removed. Only proceed on confirmation."]

**Scoping notes:**

14,646 stars, last push 2026-04-01, latest commit `651eab0`. Repo size 28 KB -- tiny, pure Markdown. [Direct quote: "My personal directory of skills"] -- positioned as personal tooling, not polished framework -- yet the `npx skills@latest add mattpocock/skills/<name>` install instruction signals it is explicitly intended for cherry-picking via the Vercel-Labs `skills` CLI.

### 18.6 CC10X

Source class: Field observation.

**Primary source:** https://github.com/romiluz13/cc10x (accessed 2026-04-13)
**Format:** GitHub repo / Claude Code marketplace plugin (`romiluz13/cc10x`).
**Scope (stated):** "A developer-focused Claude Code harness" that routes tasks, loads context, dispatches specialists, and blocks weak done-states. [Direct quote, README: "You describe the job. cc10x decides the workflow, loads the right context, brings in narrow specialists, and blocks weak 'done' states."]

**Distinctive patterns:**

- Router-as-sole-entry-point: `cc10x-router` (a skill file, not an agent) is the declared only entry point; all five workflow modes (PLAN, BUILD, DEBUG, REVIEW, RESEARCH) flow through it before any agent fires. Observed in `plugins/cc10x/skills/cc10x-router/`.
- 9 single-role agents in `plugins/cc10x/agents/`: `component-builder`, `bug-investigator`, `code-reviewer`, `silent-failure-hunter`, `integration-verifier`, `planner`, `plan-gap-reviewer`, `web-researcher`, `github-researcher`. README: agents are "intentionally specialized" so "prompts stay sharper."
- 10 lifecycle hooks in `plugins/cc10x/hooks/` covering PreToolUse, PostToolUse, SessionStart, PostCompact, PreCompact, SubagentStop, TaskCompleted, Stop, StopFailure, InstructionsLoaded -- described as audit/guardrail-only.
- Versioned durable memory written to `.claude/cc10x/v10/` per session; `session-memory` and `verification-before-completion` skills explicitly manage state across compaction events.

**Claimed differentiators (from README/marketing):**

- RED->GREEN->REFACTOR enforcement and a stated >=80% confidence threshold gate before code-review completion -- present as instruction text in skill files; runtime enforcement depends on model compliance, not a hard programmatic check.
- "Competition-grade" planning introduced in v10.1.0 with "adversarial gates" -- stated in CHANGELOG; no independent evaluation found.
- [Direct quote, README: "The point is not 'more AI'. The point is tighter execution."] -- positioning claim, marketing only.

**Scoping notes:**

137 stars, 18 forks, sole contributor (`romiluz13`, 354 commits). Created 2025-10-22; last commit 2026-04-12. Latest GitHub release `v10.1.17` (2026-04-04); README references `v10.1.19`. Active solo-maintainer with frequent releases. MIT license. No community contributors visible.

### 18.7 GitHub Spec-Kit

Source class: Field observation.

**Primary source:** https://github.com/github/spec-kit @ `e27896e` (accessed 2026-04-13)
**Format:** Official GitHub open-source toolkit / CLI framework.
**Scope (stated):** "Toolkit to help you get started with Spec-Driven Development" -- a methodology making specifications "executable, directly generating working implementations rather than just guiding them." [Direct quote, README]

**Distinctive patterns:**

- **Constitution file** (`memory/constitution.md`): The framework's most distinctive pattern. Nine immutable articles stored in `.specify/memory/` that function as "project supreme law" -- AI agents read and obey it before any planning or implementation step. Articles govern architecture decisions: Article I mandates features begin as standalone libraries; Article III enforces test-before-implementation; Articles VII-VIII cap project complexity. The constitution evolves only through documented amendments, providing consistency across AI model changes.
- **Specification-first inversion** (GitHub blog, 2025-09-02, Den Delimarsky). Explicit anti-"vibe-coding" stance: specs are the primary artifact; code serves specs.
- **Mandatory uncertainty markers**: Templates enforce `[NEEDS CLARIFICATION]` tags, preventing LLMs from filling ambiguous gaps silently.
- **Phase-separated CLI commands**: `/speckit.specify`, `/speckit.plan`, `/speckit.tasks`, then implement -- sequential phase gates rather than open-ended prompting.
- **Extension catalog**: 80+ community extensions as of April 2026, suggesting the core is intentionally minimal/composable.

**Structure:** `src/specify_cli/` (core CLI), `templates/` (spec and plan templates), `extensions/`, `presets/` (bundled workflow presets incl. multi-repo/greenfield/brownfield), `memory/constitution.md` (generated per-project), `spec-driven.md` (methodology manifesto). Artifact types: specification doc, implementation plan, task list, constitution. Five named phases: Constitution -> Specify -> Plan -> Tasks -> Implement.

**Scoping notes:**

Created 2025-08-21 by GitHub (Den Delimarsky, Principal PM). 87.6k stars, 7.5k forks as of 2026-04-13 -- among the highest-starred AI tooling repos. Presented as deliberate open-sourcing of an internal GitHub practice, though initial framing solicited feedback, suggesting methodology was still being validated. README claim it "works with any coding agent" is broad and not independently verified beyond documentation examples. MIT licensed; officially GitHub-authored.

### 18.8 Sequential Thinking MCP

Source class: Field observation.

**Primary source:** https://github.com/modelcontextprotocol/servers/tree/main/src/sequentialthinking -- `index.ts`, `lib.ts`, `README.md` -- accessed 2026-04-13
**Format:** Official MCP reference server (MIT, TypeScript, v0.2.0).
**Scope (stated):** "A detailed tool for dynamic and reflective problem-solving through thoughts" supporting revision and branching across a flexible, LLM-driven step count.

**Distinctive patterns:**

- Tool shape: single tool `sequentialthinking` accepting `thought` (string), `thoughtNumber` (int >=1), `totalThoughts` (int >=1), `nextThoughtNeeded` (bool) as required; optional `isRevision` (bool), `revisesThought` (int), `branchFromThought` (int), `branchId` (string), `needsMoreThoughts` (bool).
- Revision mechanics: `isRevision` + `revisesThought` together flag that a thought supersedes an earlier numbered thought; the original is not deleted -- both remain in `thoughtHistory`.
- Branching: `branchFromThought` + `branchId` open a parallel reasoning path; the server stores branches in a separate `branches: Record<string, ThoughtData[]>` map.
- State management: fully stateful within a session -- `SequentialThinkingServer` class holds `thoughtHistory` and `branches` in memory for the lifetime of the process; no persistence across restarts.
- Output: `content` array containing JSON with `thoughtNumber`, `totalThoughts`, `nextThoughtNeeded`, `branches`, `thoughtHistoryLength`.

**Mechanisms:**

- `totalThoughts` is dynamically mutable: if `thoughtNumber` exceeds current `totalThoughts`, the server auto-increments.
- `needsMoreThoughts` signals mid-stream that the original estimate was too low.
- `nextThoughtNeeded: false` is the termination signal.
- Boolean inputs use a Zod `coercedBoolean` preprocessor for loose MCP client serialization.

**Scoping notes:**

Reference/demo implementation in the official `modelcontextprotocol/servers` monorepo (~83,700 stars as of 2026-04-13). Actively maintained (recent commit `f424458`). Listed for Claude Desktop, VS Code, Codex CLI -- positioned as production integration rather than pure demo, but no persistence layer, so session-scoped by design. Single-tool surface area is intentionally minimal: all reasoning structure is encoded in the numeric/boolean fields rather than separate tool calls.

### 18.9 Everything Claude Code (affaan-m)

Source class: Field observation.

**Primary source:** https://github.com/affaan-m/everything-claude-code (accessed 2026-04-13)
**Format:** Installable Claude Code plugin repo (compatible also with Codex, Cursor, OpenCode, Gemini).
**Scope (stated):** [Direct quote, README: "Not just configs. A complete system: skills, instincts, memory optimization, continuous learning, security scanning, and research-first development."]

**Distinctive patterns:**

- Frames itself as an "agent harness performance optimization system" -- positioning above config-pack or tip-list genre.
- Cross-tool compatibility first-class: separate config directories for `.claude/`, `.codex/`, `.cursor/`, `.opencode/`, `.gemini/`.
- Includes a continuous-learning loop: sessions automatically extract and generalize patterns into new skills.
- Language coverage unusually broad -- 12+ stack-specific rule sets (TypeScript, Python, Go, Rust, Java, Swift, Kotlin, PHP, Perl, C++, Android/KMP, Dart).
- Domain-specific skills extend into healthcare compliance (HIPAA, PHI, EMR, CDSS), logistics, DeFi/AMM security, customs/trade.

**Structure:**

- `skills/` -- 183 domain-organized workflow folders.
- `agents/` -- 47 specialized subagent definitions (15+ language reviewers, 8 build-error resolvers, ML pipeline agents, cross-cutting roles).
- `commands/` -- 79 legacy slash command shims.
- `hooks/` -- pre/post action automation.
- `rules/` -- 12+ language rule sets.
- `mcp-configs/`, `docs/`, `examples/`, `tests/`, `.claude-plugin/`.

**Scoping notes:**

Original authorship, not curated link list. Maintainer (Affaan Mustafa) describes content as "evolved over 10+ months of intensive daily use." 154k stars, 23.9k forks, 170+ contributors as of 2026-04-13. Commit velocity high -- ~34 commits on 2026-04-13 alone. Scale (154k stars) places it in a different tier; note similarity to Superpowers star-count anomaly (both repos report stars in the 150k range, which is unusual for 6-month-old repos in this category -- treat both with measurement skepticism).

### 18.10 Synthesis

Purpose: map the observations in §18.1-§18.9 to three buckets -- (a) already present in this framework, (b) worth absorbing, (c) reject. Absorption decisions are proposals for the next iteration, not commitments.

#### (a) Patterns already present

- **Hard gates / Iron Laws** (§18.3 obra, §18.4 Compound). CLAUDE.md's 7 hard gates (DESIGN-THEN-CODE, TEST-THEN-CODE, INVESTIGATE-THEN-FIX, etc.) match the pattern.
- **Phased pipeline with artifacts** (§18.7 Spec-Kit Constitution->Specify->Plan->Tasks->Implement, §18.4 Compound Plan->Work->Review->Compound). BUILD std/deep path (sketch -> blueprint -> craft -> verify -> retro) is the same shape.
- **YAML frontmatter on durable artifacts** (§18.4 docs/solutions/ category enum, §18.5 Pocock two-field). Frontmatter conventions (slug, module, tags, status) align.
- **Progressive disclosure: SKILL.md body + references/** (§18.5 Pocock sibling files). Identical shape.
- **Persistence of explorer findings to disk** (§18.4 `.context/` workflow state). New in v0.3.1 (yo step 15).
- **Anti-rationalization red flags** (§18.2 Addy "Common Rationalizations"). Present in sketch/blueprint/craft/verify/yo.
- **Parallel subagent dispatch for independent work** (§18.2 Agent Teams, §18.4 persona reviewers). Explorer dispatch + code-review parallel passes already implement this.
- **Slug-based knowledge graph** (§18.4 docs/solutions/ frontmatter). `wiki/<type>/<slug>.md` with frontmatter is the same shape.
- **TDD RED-GREEN-REFACTOR** (§18.3, §18.5). craft/SKILL.md and references/tdd-guardrails.md.

#### (b) Worth absorbing

Each candidate: the mechanism, where it maps, and a proposed action. Ordered roughly by expected leverage.

1. **Karpathy's three-layer wiki model** (§18.1) -- raw/ (user-curated, LLM never writes), wiki/ (LLM-owned compiled digest), schema file. _Partially absorbed in v0.4.0:_ top-level directory renamed `.docs/` → `wiki/` to signal the LLM-owned layer; CLAUDE.md remains the schema file. No separate `raw/` subdirectory shipped -- in practice everything in the current tree is LLM-authored; users who accumulate genuine raw sources can create `wiki/raw/` ad-hoc. Revisit if raw-source drops become common.

2. **Spec-Kit's constitution.md with numbered articles** (§18.7) -- nine immutable articles, amendment-only, single file. The 7 hard gates are scattered across CLAUDE.md, yo/SKILL.md, craft's tdd-guardrails, etc. _Proposed action:_ `wiki/constitution.md` with numbered articles (or keep in CLAUDE.md but as numbered articles instead of bullets). Skills cite by number ("per Article III"). Discoverability and citation cost drop.

3. **Obra's SessionStart hook inlining a meta-skill** (§18.3) -- bootstrap routing rules at turn zero. v0.3.0 -> v0.3.1 fixed the auto-invocation bug via description-only, which remains probabilistic. _Proposed action:_ SessionStart hook that injects a minimal trigger table (what's user-invocable vs internal, what the explicit triggers are) into session context. Model still decides, but has ground truth rather than pattern-matching on description prose. Note hooks risk: re-check against Claude Code hook semantics before shipping.

4. **Compound's `/ce:compound-refresh`** (§18.4) -- revisit older learnings, decide keep / update / replace / archive. Retros accumulate indefinitely with no prune mechanism; stale learnings compete with fresh ones at grep time. _Proposed action:_ `/evolve refresh` (new mode on existing `/evolve`) that iterates over `wiki/retros/` by date, surfaces merge/archive candidates, confirms with user.

5. **Karpathy's lint operation** (§18.1) -- periodic health check for contradictions, stale claims, orphan pages. `/health diagnose` covers some of this but isn't explicit about wiki-layer pruning. _Proposed action:_ `/health lint` as a named mode operating on `wiki/` (orphan pages, stale date_updated, broken frontmatter edges). No longer depends on #1 after the v0.4.0 rename.

6. **Spec-Kit's `[NEEDS CLARIFICATION]` marker** (§18.7) -- sanctioned uncertainty tag. Current placeholder ban (TBD/TODO/FIXME -> hard fail) doesn't distinguish _unknown and resolved later_ from _forgotten placeholder_. _Proposed action:_ `[NEEDS CLARIFICATION]` as the sanctioned marker. Hook allows it in drafts, blocks in finalized artifacts (status: complete). Paired with a skill (or yo Pass 3 extension) that resolves markers by asking the user.

7. **Pocock's state-machine-as-table for workflow skills** (§18.5) -- transition table rows: (from-state, trigger, to-state, side-effect). diagnose classifies severity but doesn't document transitions; review triage has implicit state. _Proposed action:_ adopt the table pattern in diagnose/SKILL.md and review-pipeline.md. One table per skill with branching.

8. **Pocock's `grill-me` as composable interviewing primitive** (§18.5) -- one skill that other skills invoke. yo Pass 3 has inline questioning; sketch has implicit clarification. _Proposed action:_ extract a `clarify` skill; yo/sketch/blueprint invoke it when blocked. DRY for questioning.

9. **Compound's three-tier scratch/memory split** (§18.4) -- `.context/` (session-scoped, gitignored), `mktemp -d` (OS-temp), `docs/solutions/` (repo-tracked durable). `wiki/` conflates all three. _Proposed action:_ introduce `.context/` (gitignored) for session-scoped inter-skill handoffs (e.g., the explorer exploration file could live here or in `wiki/research/` depending on whether it's durable). `wiki/` remains the durable knowledge layer. Touches the user's Workstream D grep-noise concern.

10. **Compound's tiered persona reviewers** (§18.4) -- security / performance / correctness / maintainability / reliability as parallel named agents. code-reviewer has 3 internal passes. _Proposed action:_ no schema change; expose the 3 existing passes as named personas in code-reviewer's output header so the review shape is legible to users.

#### (c) Reject

1. **Addy's / obra's "MUST invoke skill if match"** (§18.2, §18.3) -- this is the pattern that caused the auto-invocation bug fixed in v0.3.1. Opt-in ceremony is load-bearing here. Rigid must-invoke rules produce silent auto-starts.

2. **Everything Claude Code's 183 skills + 47 agents** (§18.9) -- the value proposition of agentic-kit is right-sized ceremony, not maximal coverage. More skills -> more routing attention -> more overlap -> more stale content.

3. **CC10X's 10 lifecycle hooks** (§18.6) -- hooks are brittle across user environments and hard to debug. Current policy (one PostToolUse for placeholder enforcement) is intentionally minimal. Add hooks only when prose repeatedly fails.

4. **Addy's "three focused agents outperform one generalist" claim** (§18.2) -- already flagged in §9 as unsourced. Re-confirmed during this research: no empirical citation in the source article. Not policy.

5. **Compound's productivity-multiplier claims** (§18.4) -- "5x", "1+ week to 1-3 days" -- anecdotal, internal, no methodology. Per §4 policy on unsourced claims, don't cite as policy number.

6. **Obra's DOT graphviz in skills** (§18.3) -- valuable concept (machine-readable decision logic) but DOT syntax in Markdown is not tool-parseable in this framework. Absorb the concept via Pocock's state-machine-as-table instead (proposal 7 in §18.10 (b)).

#### Open questions (carried forward)

- Do we ever need a `wiki/raw/` subdirectory? The v0.4.0 rename subsumed the top-level raw-vs-wiki distinction; a subdir-level split is only valuable if users start dropping genuine raw sources (papers, policy docs, reference PDFs) and we want to guarantee the LLM treats them as read-only.
- Does `constitution.md` in a separate file beat inlined hard gates in CLAUDE.md? Discoverability gain vs indirection cost.
- SessionStart hook brittleness when Claude Code updates hook semantics -- how to version injected content?
- `[NEEDS CLARIFICATION]` interaction with placeholder hook: exempt only in `status: draft` artifacts, or always allow and treat resolution as a final-gate check?
- Absorption validation: which candidate should be piloted first on a real project, with context-usage and pipeline-completion measurements, before committing to shape changes?

---

## Key Numbers With Correct Scope

| Number                                            | Correct Scope                                                             |
| ------------------------------------------------- | ------------------------------------------------------------------------- |
| Output 5x input price                             | Anthropic Claude API pricing as checked 2026-04-11                        |
| Cache read 10% of input price                     | Anthropic 5-minute prompt caching as checked 2026-04-11                   |
| Cache write 125% of input price                   | Anthropic 5-minute prompt caching as checked 2026-04-11                   |
| 5 min / 60 min cache TTL                          | Anthropic prompt caching docs as checked 2026-04-11                       |
| Up to 4 cache breakpoints                         | Anthropic prompt caching docs as checked 2026-04-11                       |
| Min cacheable: 2,048 (Sonnet), 4,096 (Haiku/Opus) | Anthropic prompt caching docs as checked 2026-04-11                       |
| 80% variance from token usage                     | Anthropic BrowseComp analysis, multi-agent Research system only           |
| 90.2% multi-agent improvement                     | Anthropic internal Research eval, not universal coding                    |
| ~15x tokens vs chat (multi-agent)                 | Anthropic multi-agent Research system                                     |
| ~4x tokens vs chat (single agent)                 | Anthropic multi-agent Research system                                     |
| +80.9% multi-agent on parallelizable              | Google Research (Kim & Liu, Jan 2026), Finance-Agent benchmark            |
| 39-70% degradation on sequential                  | Google Research (Kim & Liu, Jan 2026), PlanCraft benchmark                |
| 10-32x CLI vs MCP token efficiency                | Scalekit benchmark, GitHub operations                                     |
| 28% MCP failure rate vs 0% CLI                    | Scalekit benchmark, GitHub operations                                     |
| ~4% improvement with human AGENTS.md              | ETH Zurich (arxiv 2602.11988), 138 Python tasks                           |
| LLM-generated AGENTS.md hurts 5/8                 | ETH Zurich (arxiv 2602.11988), 138 Python tasks                           |
| 9.6% to 1.4% sycophancy reduction                 | Silicon Mirror (arxiv 2604.00478), Claude Sonnet 4, 437 scenarios         |
| ~65% output savings (caveman)                     | JuliusBrussee/caveman, 10 benchmarks                                      |
| 59.4% tokens in code review phase                 | Tokenomics paper (Concordia, arxiv 2601.14470), MSR '26                   |
| 3-5 parallel sessions                             | Claude help-center recommendation and heuristic. See §10 (Git Worktrees). |

Numbers to avoid unless locally measured and dated:

- exact Claude Code system/tool token counts
- universal CLAUDE.md compliance percentages
- universal subagent token multipliers
- universal "context rot starts at X tokens"
- fixed model capability ratios
- "agents have ~100:1 input-to-output ratio" (measured: ~23:1)
- "auto mode burns 5-20x tokens" (no traceable source)
- "/compact achieves 60-80% reduction" (not in Anthropic docs)
- "4-220x multi-agent token multiplier" (no traceable source)

---

## Maintenance Policy

Re-check at least monthly or before publishing:

- model names and pricing
- prompt caching behavior
- Claude Code settings schema
- Claude Code hook events and decision semantics
- CLI flags and tool behavior
- MCP behavior
- skill formats

When updating:

- record date checked
- link official source when available
- label local measurements clearly
- remove numbers that cannot be traced
- prefer scoped claims over universal claims

---

## Sources

Official:

- Anthropic, Effective context engineering for AI agents: https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
- Anthropic, How we built our multi-agent research system: https://www.anthropic.com/engineering/multi-agent-research-system
- Anthropic pricing: https://claude.com/pricing
- Anthropic prompt caching docs: https://platform.claude.com/docs/en/build-with-claude/prompt-caching
- Claude Code hooks guide: https://code.claude.com/docs/en/hooks-guide
- Claude Code hooks reference: https://code.claude.com/docs/en/hooks
- Claude Code settings: https://code.claude.com/docs/en/settings
- Claude Code power user tips: https://support.claude.com/en/articles/14554000-claude-code-power-user-tips

Research:

- Chroma, Context Rot: https://www.trychroma.com/research/context-rot
- Lost in the Middle (Liu et al. 2023): https://arxiv.org/abs/2307.03172
- ETH Zurich, Evaluating AGENTS.md (2602.11988): https://arxiv.org/abs/2602.11988
- Silicon Mirror anti-sycophancy (2604.00478): https://arxiv.org/abs/2604.00478
- Google Research, Towards a Science of Scaling Agent Systems: https://research.google/blog/towards-a-science-of-scaling-agent-systems-when-and-why-agent-systems-work/
- Tokenomics (Concordia, 2601.14470): https://arxiv.org/abs/2601.14470
- Single-Agent vs Multi-Agent equal budgets (2604.02460): https://arxiv.org/abs/2604.02460
- Low-Resource Language Code Generation Survey (2410.03981): https://arxiv.org/abs/2410.03981
- Scalekit, MCP vs CLI benchmark: https://www.scalekit.com/blog/mcp-vs-cli-use

Field writing:

- Addy Osmani, Code Agent Orchestra: https://addyosmani.com/blog/code-agent-orchestra/
- Addy Osmani, How to write a good spec: https://addyosmani.com/blog/good-spec/
- Simon Willison, Agentic engineering patterns: https://simonwillison.net/guides/agentic-engineering-patterns/red-green-tdd/
- Grug Brained Developer: https://grugbrain.dev/
- JuliusBrussee/caveman: https://github.com/JuliusBrussee/caveman
- Morph, Context Engineering: https://www.morphllm.com/context-engineering
- Manus, Context Engineering Lessons: https://manus.im/blog/Context-Engineering-for-AI-Agents-Lessons-from-Building-Manus

Field observation (competitor frameworks, accessed 2026-04-13):

- Karpathy LLM Wiki gist: https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f
- Addy Osmani, agent-skills: https://github.com/addyosmani/agent-skills
- Addy Osmani, web-quality-skills: https://github.com/addyosmani/web-quality-skills
- obra, Superpowers: https://github.com/obra/superpowers
- EveryInc, Compound Engineering plugin: https://github.com/EveryInc/compound-engineering-plugin
- Every.to, Compound Engineering: How Every codes with agents: https://every.to/chain-of-thought/compound-engineering-how-every-codes-with-agents
- Matt Pocock, skills: https://github.com/mattpocock/skills
- romiluz13, cc10x: https://github.com/romiluz13/cc10x
- GitHub, spec-kit: https://github.com/github/spec-kit
- ModelContextProtocol, Sequential Thinking server: https://github.com/modelcontextprotocol/servers/tree/main/src/sequentialthinking
- affaan-m, everything-claude-code: https://github.com/affaan-m/everything-claude-code

Use non-official sources as prompts for local experiments, not as policy by themselves.
