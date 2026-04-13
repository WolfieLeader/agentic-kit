# Tips & Standards for AI-Assisted Development

Verified and corrected with independent research validation.

Last reviewed: 2026-04-11

Scope: Claude Code, Claude models (Haiku 4.5, Sonnet 4.6, Opus 4.6), English language.

This document mixes official documentation, research findings, and field heuristics. Treat them differently:

| Tag | Meaning |
|-----|---------|
| Official | Vendor or project documentation. Re-check when tools/models change. |
| Study-specific | True for the cited benchmark or experiment, not automatically universal. |
| Heuristic | Practical rule of thumb. Validate against your own workflow. |
| Local measurement | Depends on local config, installed tools, or project shape. |

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

| Layer | Contents | Practice |
|-------|----------|----------|
| Persistent base | System prompt, tool definitions, project instructions, skills | Keep stable and concise. |
| Dynamic task context | Relevant files, examples, current plan, recent decisions | Rotate per task. |
| Ephemeral context | Tool outputs, errors, temporary search results | Summarize or discard quickly. |

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

| Model | Input | Output | 5-min cache write | 5-min cache read |
|-------|-------|--------|-------------------|------------------|
| Claude Haiku 4.5 | $1 / MTok | $5 / MTok | $1.25 / MTok | $0.10 / MTok |
| Claude Sonnet 4.6 | $3 / MTok | $15 / MTok | $3.75 / MTok | $0.30 / MTok |
| Claude Opus 4.6 | $5 / MTok | $25 / MTok | $6.25 / MTok | $0.50 / MTok |

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

| Claim | Status |
|-------|--------|
| "Agents have ~100:1 input-to-output ratio" | Unsourced. OpenRouter programming data shows ~93% input vs 4% output (~23:1). Use measured ratios from your own sessions. |
| "/compact achieves 60-80% context reduction" | Not documented by Anthropic. Compaction docs make only qualitative claims. Third-party observations report 50-70%. |
| "Autocompact triggers at ~167K tokens" | Community measurement derived from ~83.5% of 200K window. Not officially documented. Configurable via `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE`. |
| "Auto mode burns 5-20x more tokens than interactive" | No traceable source. The 5x and 20x in public discourse refer to Claude Code Max pricing tiers, not token rates. |
| "CLAUDE.md instruction compliance ~60-70%" | Community observation, not officially measured by Anthropic. Depends on instruction clarity, complexity, and model defaults. See §5. |

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

| Tool type | Strength | Cost/risk |
|-----------|----------|-----------|
| CLI | Fast, scriptable, terse output, existing auth | Requires command knowledge and safe shell handling |
| Skills | Low at-rest overhead, good for workflows and domain practices | Trigger descriptions still consume attention |
| MCP | Rich integrations and structured tools | Can add many tool definitions and ambiguous choices |

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

| Task | Model | Reasoning |
|------|-------|-----------|
| File search, classification, placeholder scanning, simple transforms | Haiku 4.5 | Cheapest ($1/$5), fastest. Deterministic checks, low ambiguity. |
| Feature work, code review, exploration, daily coding | Sonnet 4.6 | Balance of capability and cost ($3/$15). |
| Complex architecture, subtle bugs, multi-file refactors, orchestration | Opus 4.6 | Strongest reasoning ($5/$25). High-ambiguity work. |

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

## Key Numbers With Correct Scope

| Number | Correct Scope |
|--------|---------------|
| Output 5x input price | Anthropic Claude API pricing as checked 2026-04-11 |
| Cache read 10% of input price | Anthropic 5-minute prompt caching as checked 2026-04-11 |
| Cache write 125% of input price | Anthropic 5-minute prompt caching as checked 2026-04-11 |
| 5 min / 60 min cache TTL | Anthropic prompt caching docs as checked 2026-04-11 |
| Up to 4 cache breakpoints | Anthropic prompt caching docs as checked 2026-04-11 |
| Min cacheable: 2,048 (Sonnet), 4,096 (Haiku/Opus) | Anthropic prompt caching docs as checked 2026-04-11 |
| 80% variance from token usage | Anthropic BrowseComp analysis, multi-agent Research system only |
| 90.2% multi-agent improvement | Anthropic internal Research eval, not universal coding |
| ~15x tokens vs chat (multi-agent) | Anthropic multi-agent Research system |
| ~4x tokens vs chat (single agent) | Anthropic multi-agent Research system |
| +80.9% multi-agent on parallelizable | Google Research (Kim & Liu, Jan 2026), Finance-Agent benchmark |
| 39-70% degradation on sequential | Google Research (Kim & Liu, Jan 2026), PlanCraft benchmark |
| 10-32x CLI vs MCP token efficiency | Scalekit benchmark, GitHub operations |
| 28% MCP failure rate vs 0% CLI | Scalekit benchmark, GitHub operations |
| ~4% improvement with human AGENTS.md | ETH Zurich (arxiv 2602.11988), 138 Python tasks |
| LLM-generated AGENTS.md hurts 5/8 | ETH Zurich (arxiv 2602.11988), 138 Python tasks |
| 9.6% to 1.4% sycophancy reduction | Silicon Mirror (arxiv 2604.00478), Claude Sonnet 4, 437 scenarios |
| ~65% output savings (caveman) | JuliusBrussee/caveman, 10 benchmarks |
| 59.4% tokens in code review phase | Tokenomics paper (Concordia, arxiv 2601.14470), MSR '26 |
| 3-5 parallel sessions | Claude help-center recommendation and heuristic. See §10 (Git Worktrees). |

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

Use non-official sources as prompts for local experiments, not as policy by themselves.
