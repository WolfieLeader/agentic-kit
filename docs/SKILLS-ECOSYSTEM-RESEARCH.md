# Claude Code Skills Ecosystem — Deep Research

> Research compiled 2026-04-25. Inventories five major skill collections, compares them to Anthropic's official skills + Plan mode, and surveys what's actually measured vs. marketed in the ecosystem.

## Table of Contents

1. [Executive summary](#executive-summary)
2. [What a "skill" is, officially](#what-a-skill-is-officially)
3. [Plan mode vs. Plan subagent vs. Plan-as-skill](#plan-mode-vs-plan-subagent-vs-plan-as-skill)
4. [Skill collections side-by-side](#skill-collections-side-by-side)
5. [anthropics/skills — the official 17](#anthropicsskills--the-official-17)
6. [mattpocock/skills — TS-flavored DDD pipeline](#mattpocockskills--ts-flavored-ddd-pipeline)
7. [obra/superpowers — methodology-as-skills](#obrasuperpowers--methodology-as-skills)
8. [EveryInc/compound-engineering-plugin — phased SDLC + compounding artifacts](#everyinccompound-engineering-plugin--phased-sdlc--compounding-artifacts)
9. [addyosmani/agent-skills — uniform senior-staff playbook](#addyosmaniagent-skills--uniform-senior-staff-playbook)
10. [Caveman: Matt's vs. Julius's](#caveman-matts-vs-juliuss)
11. [Anthropic's frontmatter spec, in full](#anthropics-frontmatter-spec-in-full)
12. [Token efficiency — what's actually measured](#token-efficiency--whats-actually-measured)
13. [Opus 4.7 specifically](#opus-47-specifically)
14. [Skills currently installed in this repo](#skills-currently-installed-in-this-repo)
15. [Verdict — what's better when](#verdict--whats-better-when)
16. [Sources](#sources)

---

## Executive summary

- **Anthropic's `anthropics/skills` repo has 123,600 stars** — the most-starred skill collection by a wide margin. It ships 17 official skills + the open spec + a SKILL.md template.
- The community ecosystem splits into **four philosophical camps**: skill-as-reference (Anthropic, Pocock), skill-as-workflow-controller (obra/superpowers), skill-as-pipeline-stage (EveryInc compound engineering), and skill-as-technique-library (Pocock, Addy Osmani).
- **Plan mode in Claude Code is a permission mode** (Shift+Tab cycle), not a skill or sub-agent. It enforces read-only at the *tool level* — a guarantee no skill can replicate. The Plan **subagent** (`subagent_type=Plan`) is a separate construct used by plan mode internally.
- **Token-efficiency claims in the ecosystem are mostly unmeasured**. The cleanest skill-specific benchmark is Caveman's three-arm eval (10 tasks, 65% output reduction, methodology disclosed). Anthropic's own model-level data (Opus 4.5: 48% fewer tokens than Sonnet 4.5 at matched quality) swamps any per-skill optimization.
- **No public benchmark of skills on Opus 4.7 specifically exists** as of April 2026. Skill effectiveness is largely model-agnostic in the published claims; model choice matters ~10× more than skill choice for token cost.

---

## What a "skill" is, officially

From [code.claude.com/docs/en/skills](https://code.claude.com/docs/en/skills):

> Skills extend what Claude can do. Create a `SKILL.md` file with instructions, and Claude adds it to its toolkit. Claude uses skills when relevant, or you can invoke one directly with `/skill-name`.

> Create a skill when you keep pasting the same playbook, checklist, or multi-step procedure into chat, or when a section of CLAUDE.md has grown into a procedure rather than a fact. Unlike CLAUDE.md content, a skill's body loads only when it's used, so long reference material costs almost nothing until you need it.

Skills follow the [Agent Skills](https://agentskills.io) open standard (Anthropic-published, Dec 2025). The standard works across Claude Code, claude.ai, and the API; Claude Code extends it with invocation control, subagent execution, and dynamic context injection.

**Key lifecycle facts** (matter for token math):

- Skill descriptions are loaded into context up-front (so Claude knows what's available).
- Full SKILL.md body **only loads when invoked** — once invoked, it stays in context for the rest of the session.
- Default description-listing budget: **8,000 chars or 1% of context window**, raisable via `SLASH_COMMAND_TOOL_CHAR_BUDGET`. Each entry's combined `description` + `when_to_use` is hard-capped at 1,536 chars.
- Compaction re-attaches the most recent invocation of each skill (first 5,000 tokens; 25k combined budget). Older skills can be dropped entirely if many were invoked.
- Recommended: **keep SKILL.md under 500 lines**; move detailed reference into supporting files.

---

## Plan mode vs. Plan subagent vs. Plan-as-skill

Three architecturally distinct things share the word "plan" in Claude Code:

| Mechanism | What it is | Hard guarantee? | How triggered |
|---|---|---|---|
| **Plan mode** | Permission mode (`default → acceptEdits → plan` cycle) | Yes — Write/Edit tools physically denied | `Shift+Tab` to cycle, `/plan` prefix, or `--permission-mode plan` |
| **Plan subagent** | Built-in subagent type, read-only tools, used by plan mode | Yes — sandbox-level | `subagent_type=Plan` in Task tool; auto-invoked by plan mode |
| **Planning skill** | Prompt-level instruction to plan first | No — model can defect | `disable-model-invocation` or auto-trigger; produces durable artifacts |

**Plan mode finishes with a five-option dialog**: Approve+auto / Approve+acceptEdits / Approve+manual review / Keep planning / Refine with [Ultraplan](https://code.claude.com/docs/en/ultraplan) (browser-based section comments). Each approve option offers to clear planning context first.

**[Ultraplan](https://code.claude.com/docs/en/ultraplan)** (research preview, Claude Code v2.1.91+) hands the planning task to a Claude Code on the web session. The plan is drafted in the cloud while the terminal stays free; you review with inline comments and emoji reactions in the browser, then "teleport back to terminal" to execute or run on the web with a PR.

**Planning skills** like obra's `writing-plans`, EveryInc's `ce-plan`, mattpocock's `to-prd`/`request-refactor-plan` produce durable artifacts (specs, plans, GitHub issues) but cannot prevent the model from writing code if it decides to defect. They're soft guarantees backed by `<HARD-GATE>` tags and rationalization tables (obra) or pure prompt-level discipline (mattpocock, EveryInc).

**The honest tradeoff**: use Plan mode when you don't trust the model not to start coding. Use a planning skill when you want the plan checked into `docs/plans/` for the next session to find.

---

## Skill collections side-by-side

| Collection | Stars | # skills | Philosophy | Trigger style |
|---|---|---|---|---|
| **anthropics/skills** | 123.6k | 17 + spec + template | Reference implementation, mostly artifact creators (docx, pdf, pptx, xlsx) | Mixed |
| **JuliusBrussee/caveman** | 46k | 1 | Output compression, viral | Slash + auto on token-efficiency cues |
| **addyosmani/agent-skills** | 22.8k | 21 | Senior-staff lifecycle playbook (DEFINE→PLAN→BUILD→VERIFY→REVIEW→SHIP) | All auto-invocable |
| **obra/superpowers** | ~94-120k (search-conflicting) | 14 | Methodology-as-skills with hard gates and Iron Laws | Auto + intercepts EnterPlanMode |
| **mattpocock/skills** | (medium) | 18 | DDD-shaped TS pipeline: glossaries → grilling → tracer-bullet GitHub issues → TDD | Auto + a few `disable-model-invocation` |
| **EveryInc/compound-engineering-plugin** | (medium) | 36 + 50 agents | Compound engineering — 80% plan/review, 20% execute; durable artifacts at every stage | Phase-separated; chained via `lfg` |
| **WolfieLeader/agentic-kit** | 0 (v0.1 draft) | 12 + 4 agents | Synthesis: compounding loop + TDD discipline + grep-first wiki + 4-handoff boundary. Explicit Opus-first economics. | `/yo` router + opt-in pipeline phases |

---

## anthropics/skills — the official 17

Repo: [github.com/anthropics/skills](https://github.com/anthropics/skills) (123.6k stars). Structure:
- `skills/` — 17 skills
- `spec/agent-skills-spec.md` — the open Agent Skills spec
- `template/SKILL.md` — starter template
- `.claude-plugin/` — plugin manifest

**Distribution.** `anthropics/skills` is **not bundled into Claude Code by default** — it's a plugin marketplace. Install with:

```
/plugin marketplace add anthropics/skills
```

The repo ships two installable plugins via the `anthropic-agent-skills` marketplace:
- `document-skills` — the four artifact creators (`pdf`, `docx`, `pptx`, `xlsx`). Same code that backs Claude.ai's native file-creation feature.
- `example-skills` — the rest (Apache-2.0 licensed examples).

Adjacent distribution channels: [`anthropics/claude-plugins-official`](https://github.com/anthropics/claude-plugins-official) (Anthropic-managed plugin directory) and [`anthropics/claude-plugins-community`](https://github.com/anthropics/claude-plugins-community).

**Frontmatter philosophy** in Anthropic's own skills: minimalist — only `name` and `description` are used in most skills. The 14-field schema documented in the [Claude Code docs](https://code.claude.com/docs/en/skills) is the *full* surface area; Anthropic's own examples use a small subset, leaning hard on **progressive disclosure** (link out to subfiles only loaded when needed). This is markedly leaner than community packs (mattpocock, obra, EveryInc, addyosmani) which often add tags/versions/allowed-tools/embedded examples.

### The 17 official skills

**Artifact creators** (the big ones — most ship Python scripts Claude orchestrates):

| Skill | What it does |
|---|---|
| `docx` | Read/edit/produce Microsoft Word documents |
| `xlsx` | Read/edit/produce Excel spreadsheets |
| `pptx` | Read/edit/produce PowerPoint presentations |
| `pdf` | Read/extract/produce PDFs |
| `canvas-design` | Design layouts and canvas-style visuals |
| `web-artifacts-builder` | Build interactive HTML/JS artifacts (the codebase-visualizer pattern from the docs) |
| `slack-gif-creator` | Generate animated GIFs for Slack |
| `algorithmic-art` | Generative art via code |
| `theme-factory` | Produce theme tokens / palettes |

**Engineering reference**:

| Skill | What it does |
|---|---|
| `claude-api` | Build/debug/optimize Claude API + Anthropic SDK apps; covers caching, thinking, tool use; migrates between model versions |
| `frontend-design` | Production-grade frontend with distinctive design quality (avoids "AI aesthetic") |
| `webapp-testing` | End-to-end webapp testing patterns |
| `mcp-builder` | Build MCP servers |

**Meta-tooling**:

| Skill | What it does |
|---|---|
| `skill-creator` | Anthropic's official "create new skills" skill — spec-aligned scaffold |

**Org/comms**:

| Skill | What it does |
|---|---|
| `brand-guidelines` | Apply brand voice/visual rules to outputs |
| `internal-comms` | Internal communications drafting |
| `doc-coauthoring` | Long-form document collaboration |

**Bundled-with-Claude-Code skills** (separate from the repo, shipped in the CLI):

`/simplify`, `/batch`, `/debug`, `/loop`, `/claude-api` (referenced in the docs). These are prompt-based playbooks Claude orchestrates with its tools.

---

## mattpocock/skills — TS-flavored DDD pipeline

Repo: [github.com/mattpocock/skills](https://github.com/mattpocock/skills). Author: Matt Pocock (TypeScript educator). 18 skills.

### Planning & Design

| Skill | Trigger | What it does |
|---|---|---|
| `github-triage` | Slash | Triage GitHub issues through a label-based state machine. Bug reproduction step. AFK-agent-suitable issues get an agent-brief comment. `.out-of-scope/` knowledge base across sessions. AI disclaimer required on all comments. |
| `improve-codebase-architecture` | Slash | Find "deepening opportunities" — refactors turning shallow modules into deep ones (Ousterhout). Glossary forces vocabulary (forbids "component"/"service"/"boundary"). Deletion test heuristic. ADR conflict handling. |
| `ubiquitous-language` | Slash-only (`disable-model-invocation: true`) | Extract DDD-style glossary from current conversation into `UBIQUITOUS_LANGUAGE.md`. Flags ambiguities and synonyms. Includes example dialogue between dev and domain expert. |
| `domain-model` | Slash-only | Grilling session that challenges the plan against the domain model, sharpens terminology, updates `CONTEXT.md` and `docs/adr/NNNN-*.md` lazily. Templates in `CONTEXT-FORMAT.md` and `ADR-FORMAT.md`. |
| `design-an-interface` | Auto | Generate 3+ radically different interface designs via parallel sub-agents (minimal API / max flexibility / common-case / paradigm-borrowed), then compare. Built on Ousterhout's "Design It Twice." |
| `grill-me` | Auto | Pure grilling loop — interview-one-question-at-a-time. Ancestor pattern for `domain-model`, `request-refactor-plan`, `to-prd`. |
| `request-refactor-plan` | Auto | Interview → tracer-bullet decomposition → file plan as a GitHub issue with Fowler-style tiny commits. |
| `to-prd` | Auto | Synthesize current conversation into a PRD and submit as a GitHub issue. Embedded `<prd-template>`. Explicit anti-pattern: no questions. |
| `to-issues` | Auto | Break a plan/spec/PRD into independently-grabbable GitHub issues using tracer-bullet vertical slices. HITL/AFK tagging, dependency graph, issues created in dependency order. |

### Development

| Skill | Trigger | What it does |
|---|---|---|
| `tdd` | Auto | RED→GREEN→REFACTOR state machine. Anti-pattern callout against horizontal slicing. Supporting files: `deep-modules.md`, `interface-design.md`, `mocking.md`, `refactoring.md`, `tests.md` — the richest support set in the repo. |
| `triage-issue` | Auto | Investigate bug → find root cause → file GitHub issue with TDD-based fix plan. Uses `subagent_type=Explore` for codebase recon. Issues describe behaviors, not file paths/line numbers. |
| `qa` | Auto | Interactive QA session — user reports bugs conversationally, agent files GitHub issues. Reads `UBIQUITOUS_LANGUAGE.md` for vocabulary. |
| `migrate-to-shoehorn` | Auto | Mechanical codemod: TS test files migrate from `as` type assertions to `@total-typescript/shoehorn`. Most opinionated/single-purpose. |
| `scaffold-exercises` | Auto | Create exercise directory structures with sections/problems/solutions/explainers. Runs `pnpm ai-hero-cli internal lint` as the verification oracle. Specific to Matt's `ai-hero` course repo. |

### Tooling & Setup

| Skill | Trigger | What it does |
|---|---|---|
| `setup-pre-commit` | Auto | Set up Husky pre-commit hooks with lint-staged, Prettier, type checking, tests. Auto-detects package manager. |
| `git-guardrails-claude-code` | Auto | Set up Claude Code hooks to block dangerous git commands. Copies bundled `scripts/block-dangerous-git.sh`, edits `settings.json`. |

### Writing & Knowledge

| Skill | Trigger | What it does |
|---|---|---|
| `write-a-skill` | Auto | Meta-skill / template generator with embedded SKILL.md template and progressive-disclosure rules (>500 lines → split files). |
| `edit-article` | Auto | Restructure article sections, improve clarity, tighten prose. DAG-based section reorderer. Hard rule: 240 chars/paragraph max. |
| `obsidian-vault` | Auto | Search/create/manage Obsidian vault notes with wikilinks. Hardcoded path `/mnt/d/Obsidian Vault/AI Research/`. |
| `zoom-out` | Slash-only | Two-sentence skill — tells the agent to zoom out for broader context. Smallest skill in the repo. |
| `caveman` | Slash-only | Ultra-compressed communication mode (~75% output reduction claimed). Single intensity. Auto-clarity exception for security warnings. |

### Synthesis (mattpocock)

The system is an opinionated software-design pipeline rooted in Ousterhout's *A Philosophy of Software Design* and Fowler's refactoring discipline. Skills compose into a chain: `grill-me`/`domain-model`/`ubiquitous-language` produce shared language → `to-prd`/`request-refactor-plan` produce design artifacts → `to-issues` decomposes into tracer-bullet issues → `triage-issue`/`tdd` execute with durable, behavior-only tests. Repeated vocabulary ("deep modules," "vertical slices," "tracer bullets," "durable artifacts") is the connective tissue.

Implicit philosophy: *durability beats specificity*. Issues describe behaviors, not files. Tests verify external contracts, not internals. Glossaries fight terminology drift. Plans break into "tiny commits that leave the codebase working." The four "interlocking" skills (`github-triage`, `improve-codebase-architecture`, `ubiquitous-language`, `caveman`) are: two artifact-producing investigators, one glossary substrate, one prompt-macro sibling of `zoom-out`.

---

## obra/superpowers — methodology-as-skills

Repo: [github.com/obra/superpowers](https://github.com/obra/superpowers). Author: Jesse Vincent + Prime Radiant. Released Oct 9 2025 ([blog.fsck.com/2025/10/09/superpowers/](https://blog.fsck.com/2025/10/09/superpowers/)). 14 skills.

Distributed via Anthropic's official marketplace, the Superpowers marketplace, Codex, Cursor, OpenCode, Copilot CLI, and Gemini CLI.

| Skill | Trigger | What it does |
|---|---|---|
| `using-superpowers` | Every conversation start | Meta-router. Establishes how to find and use skills. Mandates `Skill` tool invocation BEFORE any response, including clarifying questions. Instruction-priority ladder (User CLAUDE.md > Superpowers > default system prompt). 12-row rationalization table ("This is just a simple question," "I'll just do this one thing first"). `<EXTREMELY-IMPORTANT>` and `<SUBAGENT-STOP>` tags. Intercepts `EnterPlanMode`. |
| `brainstorming` | Hard gate before code | Required before any creative work. `<HARD-GATE>` forbids implementation. 9-step checklist with TodoWrite todos. Process drawn as `digraph`. Optional Visual Companion for browser-based mockups. Saves spec to `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md` and commits. |
| `writing-plans` | Invoked by brainstorming | Multi-step plan with bite-sized steps (2-5 min each). Explicit RED-GREEN-REFACTOR-COMMIT pattern per step. Forbids placeholders ("TBD", "TODO", "similar to Task N"). Self-review pass. Ends with execution-mode choice. |
| `subagent-driven-development` | Selected from writing-plans handoff | **The headline trick.** Fresh subagent per task with two-stage review (spec compliance ✅ THEN code quality). Status protocol: `DONE` / `DONE_WITH_CONCERNS` / `NEEDS_CONTEXT` / `BLOCKED`. Controller extracts full task text up-front so subagents never read the plan file. Three sub-prompts: `implementer-prompt.md`, `spec-reviewer-prompt.md`, `code-quality-reviewer-prompt.md`. |
| `executing-plans` | Linear in-session executor | Alternative for platforms without subagents. Critical-review-first step. Stop-and-ask on blockers. |
| `dispatching-parallel-agents` | When 2+ truly independent failures exist | Decision graph — only parallel if no shared state. Agent-prompt template (focused, self-contained, specific output). Anti-patterns: "Fix all the tests", "Fix it." |
| `test-driven-development` | Implementing any feature/bugfix | Iron Law: "NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST." If you wrote code first, **delete it** — "delete means delete." 12-row rationalization table. Mandatory verify-RED and verify-GREEN steps. |
| `systematic-debugging` | Any bug, before proposing fixes | Iron Law: "NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST." 4 phases (Root Cause → Pattern → Hypothesis → Implementation). After 3 failed fixes → "STOP and question architecture" rule. Sub-skills `root-cause-tracing.md`, `defense-in-depth.md`, `condition-based-waiting.md`. |
| `verification-before-completion` | Before any completion claim | Iron Law: "NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE." Bans words: "should", "probably", "Great!", "Perfect!", "Done!" until evidence shown. |
| `using-git-worktrees` | Before any feature work | Set up isolated workspace. Directory priority: existing `.worktrees/` > `worktrees/` > CLAUDE.md > ask. Mandatory `git check-ignore` verification (auto-fixes .gitignore + commits). Auto-detects `package.json` / `Cargo.toml` / `requirements.txt` / `go.mod` for setup. |
| `finishing-a-development-branch` | Implementation complete, all tests pass | Test-pass gate. Exactly 4 options: merge / PR / keep / discard. Discard requires typed "discard" confirmation. |
| `requesting-code-review` | Code review needed | Dispatches a `superpowers:code-reviewer` subagent with curated context (NOT session history). Severity bins: Critical / Important / Minor. |
| `receiving-code-review` | Reviewing review feedback | Bans "You're absolutely right!", "Great point!", and ALL gratitude expressions ("If you catch yourself about to write 'Thanks': DELETE IT"). Mandates verify-then-evaluate-then-respond loop. |
| `writing-skills` | Meta | Skills authored via TDD — pressure-test scenarios with subagents are RED, the SKILL.md is the production code. Explicit "Claude Search Optimization" rules: descriptions must be "Use when..." triggers, NOT process summaries; max 1024 chars. Sub-doc: `anthropic-best-practices.md`. |

### Synthesis (obra)

*Methodology-as-skills, not techniques-as-skills.* Superpowers is a single opinionated SDLC (brainstorm → worktree → plan → subagent-driven TDD with two-stage review → finish) where every step is a hard gate that triggers automatically. Each skill has an "Iron Law", a rationalization table to defeat agent self-talk, and a `digraph` flow to remove judgment. Heavy use of `<HARD-GATE>` / `<EXTREMELY-IMPORTANT>` / `<SUBAGENT-STOP>` pseudo-XML.

**vs. mattpocock**: Pocock's are *technique libraries* (TS/Effect how-to docs you opt into); Superpowers is a *workflow controller* that overrides default Claude behavior end-to-end. Pocock teaches the model facts; Jesse constrains the model's process.

**Tricks worth stealing**:
1. **Two-stage review** (spec compliance ✅ THEN code quality) — catches over/under-building before quality nits dominate.
2. **Controller extracts full task text** and curates context per subagent instead of having subagents re-read the plan file.
3. **3-failures rule** in `systematic-debugging` — forces architectural questioning instead of fix #4.
4. **Forbidden words** in `verification-before-completion` and `receiving-code-review` ("Perfect!", "You're absolutely right!", "Thanks") — direct counter to model sycophancy.
5. **Worktree skill auto-fixes .gitignore + commits** before creating a worktree (defensive default).
6. **`writing-skills` itself is TDD** — pressure-test scenarios with subagents serve as failing tests for documentation. Genuinely original take.

---

## EveryInc/compound-engineering-plugin — phased SDLC + compounding artifacts

Repo: [github.com/EveryInc/compound-engineering-plugin](https://github.com/EveryInc/compound-engineering-plugin). Authors: Dan Shipper + Kieran Klaassen (Every.to). 36 skills + 50+ agents. Canonical methodology essay: [every.to/chain-of-thought/compound-engineering-how-every-codes-with-agents](https://every.to/chain-of-thought/compound-engineering-how-every-codes-with-agents).

### Core workflow loop

| Skill | Trigger | What it does |
|---|---|---|
| `ce-ideate` | Slash + model | Generate + critique grounded big ideas; route the best into brainstorm. Front-loads divergence before convergence. |
| `ce-brainstorm` | Slash + model ("let's brainstorm", vague feature) | Q&A dialogue → right-sized requirements doc (WHAT). Resolves product decisions early so plans don't invent them. |
| `ce-plan` | Slash + model | Requirements → detailed implementation plan (HOW). 80% planning/review, 20% execution. Refuses to implement code. |
| `ce-work` | Slash | Execute plan via worktrees, task tracking. Disciplined execution. |
| `ce-debug` | Slash + model (stack traces, "why failing") | Reproduce → trace causal chain → test-first fix. Investigate-before-fix; one-change-at-a-time. |
| `ce-code-review` | Slash + model | Tiered persona sub-agents w/ confidence-gated findings, dedup pipeline. Multi-perspective leverage; calibrated confidence. |
| `ce-compound` | Slash | **The literal compounding loop.** Document solved problems → `docs/solutions/` w/ YAML frontmatter for grep-first retrieval. Codify learnings. |
| `ce-compound-refresh` | Slash | Keep/update/replace/archive stale learnings. Maintain the compound knowledge base. |
| `ce-optimize` | Slash | Iterative optimization loop with parallel experiments + LLM-as-judge gates. Measurement-gated improvement. |

### Research & context

| Skill | What it does |
|---|---|
| `ce-sessions` | Query past Claude/Codex/Cursor sessions |
| `ce-slack-research` | Org context from Slack |

### Git workflow

| Skill | What it does |
|---|---|
| `ce-commit` | Create a commit |
| `ce-commit-push-pr` | Commit, push, open PR |
| `ce-pr-description` | Generate PR descriptions |
| `ce-clean-gone-branches` | Clean up [gone] branches and worktrees |
| `ce-worktree` | Worktree operations |

### Workflow utilities

| Skill | What it does |
|---|---|
| `ce-setup` | Env diagnose + bootstrap |
| `ce-update` | Update plugin |
| `ce-release-notes` | Generate release notes |
| `ce-report-bug` | File a bug report |
| `ce-resolve-pr-feedback` | Parallel PR feedback resolution |
| `ce-test-browser` | Browser testing |
| `ce-test-xcode` | Xcode testing |
| `ce-demo-reel` | Demo recording helpers |

### Frameworks/style

| Skill | What it does |
|---|---|
| `ce-agent-native-architecture` | Build prompt-native agents |
| `ce-agent-native-audit` | Audit prompt-native agents |
| `ce-dhh-rails-style` | DHH-style Rails conventions |
| `ce-frontend-design` | Frontend design conventions |

### Review/quality

| Skill | What it does |
|---|---|
| `ce-doc-review` | Parallel persona doc reviewers |

### Content & tools

| Skill | What it does |
|---|---|
| `ce-proof` | Proof editor |
| `ce-gemini-imagegen` | Gemini image generation |
| `ce-session-extract` | Extract session content |
| `ce-session-inventory` | Inventory sessions |

### Beta / pipeline

| Skill | What it does |
|---|---|
| `ce-polish-beta` | HITL polish post-review |
| `lfg` | Full autonomous workflow — chains plan→work→code-review→autofix→push. Explicitly non-model-invokable (`disable-model-invocation: true`). |

### Synthesis (EveryInc)

The philosophy inverts the typical entropy curve of software. Where ordinary work accumulates technical/cognitive debt — each feature making the next one harder — the thesis is that *each unit of engineering work should make subsequent units easier*. The lever is allocation: **80% planning + review, 20% execution**, with every cycle producing durable, retrievable artifacts (requirements docs, plans, learnings) that sharpen the next cycle.

Operational implementation:
1. **Phase separation as named skills** — `ce-brainstorm` (WHAT) vs `ce-plan` (HOW) vs `ce-work` (execute). Each refuses to do the others' job.
2. **Durable artifacts at every phase** — `docs/brainstorms/*-requirements.md`, `docs/plans/`, `docs/solutions/` with YAML frontmatter, `docs/specs/`. The artifact is the handoff.
3. **Parallel persona sub-agents** — `ce-code-review` and `ce-doc-review` dispatch tiered reviewers (security, correctness, maintainability, performance, project-standards, ~28 specialized agents) returning structured JSON merged through a dedup pipeline with confidence gates.
4. **Knowledge codification as a first-class skill** — `ce-compound` and `ce-compound-refresh` are explicit ceremonies for converting fresh problem-solving into searchable team memory.
5. **Pipelines that chain skills** — `lfg` automates plan→work→review→autofix→push as a non-model-invokable command.

Most skill libraries are *capability bundles*. Compound Engineering is an **opinionated workflow with phases**: every skill belongs to a stage of one feedback loop, refuses to overstep, and is paired with a persisted artifact. The collection bets that *process structure* (not just tool capability) is what compounds.

---

## addyosmani/agent-skills — uniform senior-staff playbook

Repo: [github.com/addyosmani/agent-skills](https://github.com/addyosmani/agent-skills). Author: Addy Osmani (Director of Eng, Google Chrome). **22,822 stars**. 21 skills + 3 agent personas + 7 slash commands. Multi-platform: Claude Code, Cursor, Gemini CLI, Windsurf, OpenCode, Copilot, Kiro, plain Codex.

Skills are organized along a 6-phase lifecycle (DEFINE → PLAN → BUILD → VERIFY → REVIEW → SHIP) shown as ASCII art in the README.

### DEFINE

| Skill | What it does |
|---|---|
| `idea-refine` | Divergent/convergent ideation; trigger "ideate"/"refine"; outputs `docs/ideas/[idea].md` one-pager (Problem, Direction, Assumptions, MVP, Not Doing). |
| `spec-driven-development` | Gated 4-phase flow (Specify → Plan → Tasks → Implement). "Surface assumptions" prompt template. 3-tier boundaries (Always/Ask first/Never). |

### PLAN

| Skill | What it does |
|---|---|
| `planning-and-task-breakdown` | Decompose specs into atomic tasks with acceptance criteria + dependency ordering. |

### BUILD

| Skill | What it does |
|---|---|
| `incremental-implementation` | Vertical slices, ~100-line cap before testing; vertical/contract-first/risk-first slicing strategies. |
| `test-driven-development` | Red-Green-Refactor with code samples; cites Beyoncé Rule, 80/15/5 pyramid, DAMP-over-DRY, "Prove-It Pattern" for bugs. |
| `context-engineering` | 5-level context hierarchy (rules → spec → source → errors → history); CLAUDE.md templates. |
| `source-driven-development` | DETECT → FETCH → IMPLEMENT → CITE; reads `package.json`/`go.mod`/`Cargo.toml` to pin versions, mandates citing official docs. |
| `frontend-ui-engineering` | Colocation file structure, composition-over-configuration, WCAG 2.1 AA, "no AI aesthetic" mandate. |
| `api-and-interface-design` | Hyrum's Law, One-Version Rule, contract-first. |

### VERIFY

| Skill | What it does |
|---|---|
| `browser-testing-with-devtools` | Wraps Chrome DevTools MCP; tools table for Screenshot/DOM/Console/Network/Performance. |
| `debugging-and-error-recovery` | 5-step triage: reproduce, localize, reduce, fix, guard. Stop-the-line rule. |

### REVIEW

| Skill | What it does |
|---|---|
| `code-review-and-quality` | 5-axis review (correctness, readability, architecture, security, perf). "Approve if it improves health" standard. Severity labels Nit/Optional/FYI. ~100-line PR norm. |
| `code-simplification` | 5 principles: preserve behavior, follow conventions, clarity over cleverness, Chesterton's Fence, Rule of 500. **Credits Anthropic's official code-simplifier plugin as inspiration.** |
| `security-and-hardening` | OWASP Top 10, three-tier boundary system. |
| `performance-optimization` | Measure-first; Core Web Vitals targets table; LCP/INP/CLS thresholds; symptom-routed measurement decision tree. |

### SHIP

| Skill | What it does |
|---|---|
| `git-workflow-and-versioning` | Trunk-based, atomic commits, "commit-as-save-point", ~100-line norm, DORA citation. |
| `ci-cd-and-automation` | Shift Left, "Faster is Safer", feature flags. |
| `deprecation-and-migration` | Code-as-liability, compulsory vs advisory deprecation. |
| `documentation-and-adrs` | ADRs, document the *why*. |
| `shipping-and-launch` | Pre-launch checklists, staged rollouts, rollback procedures. |

### Meta

| Skill | What it does |
|---|---|
| `using-agent-skills` | Onboarding doc explaining how to invoke skills. |

### Agent personas (separate from skills)

`code-reviewer`, `test-engineer`, `security-auditor`.

### Slash commands (entry points)

`/spec`, `/plan`, `/build`, `/test`, `/review`, `/code-simplify`, `/ship`.

### Synthesis (Addy Osmani)

- **Domain**: Despite Addy's frontend/perf reputation, the repo is deliberately **generic full-lifecycle engineering** — only 3 of 21 skills are frontend-specific. The rest are language- and stack-agnostic process skills covering spec → plan → build → test → review → ship. Closer to a "senior staff engineer playbook" than a frontend toolkit.
- **Design quality**: Markedly more **structured and uniform** than mattpocock's TS-tip-style or obra's narrative-philosophical skills. Every skill follows the same template: frontmatter + Overview + When/Not-When + ASCII workflow + numbered phases + concrete code snippets + tables of thresholds. Easier to onboard a team to, but less idiosyncratic and less suited to deep one-off problems. Cites real engineering literature (DORA, Hyrum's Law, Chesterton's Fence, Beyoncé Rule, OWASP) which gives them more authority than typical skill repos.
- **Unique patterns**: (1) Skills explicitly chain into a **lifecycle graph** with 7 slash-command entry points. (2) **Multi-platform first-class support** (8 install paths in README). (3) **"Anti-rationalization tables"** and explicit "When NOT to use" sections in every skill. (4) Includes **agent personas** layered on top of skills. (5) Honest attribution: `code-simplification` openly credits Anthropic's official plugin as the source.
- **Community traction**: 22.8k stars is exceptional. Reflects (a) Addy's existing 100k+ developer following, (b) multi-platform install story expanding the addressable audience, (c) lifecycle framing matching how teams already think.

---

## Caveman: Matt's vs. Julius's

Two skills with the same lineage. Same opening sentence ("Respond terse like smart caveman..."), same `Persistence` section header, same React re-render and DB pooling examples, same destructive-op auto-clarity demo with the same `DROP TABLE users;` example. Julius's is a fork/extension of Matt's, not an independent design.

| Aspect | Matt | Julius |
|---|---|---|
| Stars | (part of mattpocock/skills) | 46k |
| Intensity levels | One fixed level | Six: `lite`, `full` (default), `ultra`, plus three `wenyan-*` (classical Chinese) modes |
| Mode switching | None — on/off only | `/caveman lite\|full\|ultra` runtime dial |
| Trigger phrases | Only explicit ("caveman mode", "/caveman") | Same, plus *auto-triggers when token efficiency is requested* |
| Boundaries | Code blocks unchanged, errors quoted exact | All Matt's rules + explicit `Code/commits/PRs: write normal` |

### Where Julius wins
- **The `Boundaries` section is genuinely better.** Matt's says code blocks stay verbatim, but is silent on commit messages and PR bodies — and a caveman commit message ("fix bug auth") is a real failure mode in a project that follows conventional commits. Julius blocks that explicitly.
- **The intensity dial** addresses a real complaint: "full" caveman is too aggressive for some tasks; `lite` ("no filler, keep articles, keep full sentences") is closer to what most people actually want when they say "be brief."

### Where Matt wins
- **No auto-trigger.** Julius's "auto-triggers when token efficiency is requested" is dangerous — the model decides it's saving you tokens without you asking. Matt's only fires on explicit phrases, which is the right default for a mode that fundamentally changes voice.
- **No wenyan.** The `wenyan-*` modes are a stunt. Classical Chinese is genuinely the densest natural-language compression possible (a 文言文 sentence can compress 80%+ vs. modern Chinese), but it only works if (a) the model's classical Chinese is solid, and (b) the *user* reads classical Chinese. For 99% of users it's just garbled output. It also bloats the SKILL.md context budget for a feature most people will never use.
- **Smaller surface area.** Six modes = six failure modes. Matt's single mode is harder to misuse.

### Caveman's measured efficiency

Caveman is the only skill in the ecosystem with a real benchmark: 10 tasks, output tokens averaged **1214 → 294 (65% reduction)**. Methodology disclosed: *"Caveman only affects output tokens — thinking/reasoning tokens are untouched."* They tested "verbose vs. caveman skill" AND "terse vs. caveman skill" as a control. n=10 is small but the methodology is genuinely serious.

### Verdict

Julius's caveman is Matt's caveman + intensity dial + wenyan + an explicit boundaries clause. The boundaries clause is the only piece worth merging back; the rest is flair that trades safety for flexibility. The 46k stars on Julius reflect virality and a great repo description ("why use many token when few token do trick"), not necessarily that it's the better-designed skill.

---

## Anthropic's frontmatter spec, in full

From [code.claude.com/docs/en/skills](https://code.claude.com/docs/en/skills):

| Field | Required | Description |
|---|---|---|
| `name` | No | Display name for the skill. If omitted, uses the directory name. Lowercase letters, numbers, and hyphens only (max 64 chars). |
| `description` | Recommended | What the skill does and when to use it. Combined `description` + `when_to_use` is **truncated at 1,536 characters** in the skill listing. |
| `when_to_use` | No | Additional context for when Claude should invoke the skill. Counts toward the 1,536-char cap. |
| `argument-hint` | No | Hint shown during autocomplete. Example: `[issue-number]` or `[filename] [format]`. |
| `arguments` | No | Named positional arguments for `$name` substitution. |
| `disable-model-invocation` | No | `true` = only you can invoke (slash-only). Also prevents preloading into subagents. |
| `user-invocable` | No | `false` = hide from `/` menu (background knowledge users shouldn't invoke). |
| `allowed-tools` | No | Tools Claude can use without permission while skill is active. |
| `model` | No | Model override for this skill: `sonnet`, `opus`, `haiku`, full ID, or `inherit`. |
| `effort` | No | Effort level: `low`, `medium`, `high`, `xhigh`, `max`. |
| `context` | No | Set to `fork` to run in a forked subagent context. |
| `agent` | No | Which subagent type to use when `context: fork` is set. |
| `hooks` | No | Lifecycle hooks scoped to this skill. |
| `paths` | No | Glob patterns limiting auto-activation to matching files. |
| `shell` | No | `bash` (default) or `powershell` for `` !`command` `` blocks. |

### String substitutions in skill content

| Variable | Description |
|---|---|
| `$ARGUMENTS` | All arguments passed when invoking the skill |
| `$ARGUMENTS[N]` / `$N` | Specific argument by 0-based index |
| `$name` | Named argument from `arguments` frontmatter list |
| `${CLAUDE_SESSION_ID}` | Current session ID |
| `${CLAUDE_SKILL_DIR}` | Directory containing the skill's SKILL.md |

### Dynamic context injection

The `` !`<command>` `` syntax runs shell commands before content is sent to Claude. Multi-line variant uses fenced ` ```! ` blocks. Disabled per-policy via `"disableSkillShellExecution": true` in settings.

### Forked subagent execution

`context: fork` runs the skill in an isolated subagent context. Pair with `agent: Explore` for read-only research, `agent: Plan` for planning, `agent: general-purpose` for full capabilities, or any custom subagent.

### Skill content lifecycle

When invoked, the rendered SKILL.md content enters the conversation as a single message and stays there for the rest of the session. Claude Code does not re-read the skill file on later turns. Compaction re-attaches the most recent invocation: **first 5,000 tokens of each, 25k combined budget**, filling from most recently invoked first.

### "ultrathink" trigger

Including the word "ultrathink" anywhere in skill content enables [extended thinking](https://code.claude.com/docs/en/common-workflows#use-extended-thinking-thinking-mode).

---

## Token efficiency — what's actually measured

### The cleanest data

**Caveman's three-arm eval** (the only honest skill-specific benchmark): 10 tasks, output tokens averaged 1214 → 294 (65% reduction). Methodology disclosed: output-only, reasoning tokens untouched. Three-arm: verbose vs. caveman skill vs. terse system prompt. n=10 is small but methodology is serious.

**Anthropic's model-level data** ([Opus 4.5 launch](https://www.anthropic.com/news/claude-opus-4-5)): *"Opus 4.5 exceeds Sonnet 4.5 performance by 4.3 percentage points—while using 48% fewer tokens"* and at medium effort *"matches Sonnet 4.5's best score on SWE-bench Verified, but uses 76% fewer output tokens."* These are about *the model*, not skills.

**Prompt caching** (orthogonal, real): Anthropic-published 20-40% normal, 70-90% on repetitive sessions.

**Simon Willison's MCP comparison** ([simonwillison.net/2025/Oct/16/claude-skills/](https://simonwillison.net/2025/Oct/16/claude-skills/)): *"Each skill only takes up a few dozen extra tokens, with the full details only loaded in should the user request a task"* contrasted with *"GitHub's official MCP on its own famously consumes tens of thousands of tokens of context."* This is the token-economics argument for skills over MCP.

### Marketing claims to discount

| Claim | Source | Why discount |
|---|---|---|
| "97% fewer characters injected" | Token Savior | Measures injection chars, not end-to-end cost |
| "1 dev = 5 devs" | Every | n=1 company, anecdotal |
| "10.4M → 3.7M tokens (~3x)" | Insforge | Vendor-published, single workload |
| "82% improvement" | ClaudeFast | Vendor blog, no methodology |

### What's NOT measured (April 2026)

- Controlled "skill vs. equivalent CLAUDE.md prose" comparison.
- Per-model (Opus 4.6 vs. Sonnet 4.6 vs. Haiku 4.5) skill-effectiveness differential.
- Independent before/after on a fixed task suite.
- Any peer-reviewed study of skill effectiveness.

Simon Willison's central question — *"is a skill meaningfully different from putting the same content in CLAUDE.md?"* — remains unanswered.

---

## Opus 4.7 specifically

**Direct answer: there is no public benchmark of skills on Opus 4.7** as of April 2026. The model is current; the [Opus 4.5 paper](https://www.anthropic.com/news/claude-opus-4-5) is the most recent published efficiency data. None of the skill libraries — including Anthropic's own — claim Opus-4.7-specific tuning.

### What can be inferred

- Skills *do* trigger reliably from descriptions on Opus 4.7 (verified empirically in this session).
- The `effort` and `model` skill frontmatter fields are honored — a skill could pin itself to `claude-opus-4-7` or downgrade to `haiku` for cheap tasks. None of the four researched community collections use this.
- Long-context handling (1M tokens on Opus 4.7) means skill content lifecycle matters less than on a 200k-token model. Auto-compaction is much rarer, so the "first 5k tokens of each invoked skill, 25k combined" rule kicks in less often.

### The math

Anthropic's data: **Opus 4.7 (≈Opus 4.5 baseline) is 48% more output-token-efficient than Sonnet 4.5 at matched quality**. This swamps any per-skill optimization. **If you care about token cost, picking the right model matters ~10× more than picking the right skill collection.**

---

## Skills currently installed in this repo

Verified in `/Users/koren/Dev/lets-go/mobile-new/.claude/skills/` (mirrored to `.codex/skills/`):

### Project skills (this repo)

| Skill | Source/Origin |
|---|---|
| `building-native-ui` | Custom — Expo Router native UI guide |
| `coding-standards` | Custom — TS/JS/React/Node standards |
| `design-an-interface` | **mattpocock/skills** — Ousterhout-style parallel design |
| `expo-api-routes` | Custom — Expo Router API routes |
| `expo-cicd-workflows` | Custom — EAS workflow YAML |
| `expo-deployment` | Custom — App Store/Play Store/web/API |
| `expo-dev-client` | Custom — local + TestFlight builds |
| `expo-module` | Custom — Swift/Kotlin/TS native modules |
| `expo-ui-jetpack-compose` | Custom — `@expo/ui/jetpack-compose` |
| `expo-ui-swiftui` | Custom — `@expo/ui/swift-ui` |
| `improve-codebase-architecture` | **mattpocock/skills** (with `REFERENCE.md` instead of `LANGUAGE.md`) |
| `lets-cook` | **mattpocock-style** — stress-test plans through grilling |
| `native-data-fetching` | Custom — fetch/React Query/SWR/loaders |
| `react-native-best-practices-cs` | Custom (Callstack-style perf) |
| `react-native-best-practices-swm` | Custom (Software Mansion-style) |
| `react-native-ease-refactor` | Custom — Animated → EaseView migration |
| `stripe-best-practices` | Custom — Stripe integration guide |

### User-level Anthropic plugin skills

From `~/.claude/plugins/cache/claude-plugins-official/`:

| Plugin | Skill(s) |
|---|---|
| `claude-plugins-official/code-review` | `code-review` |
| `claude-plugins-official/code-simplifier` | `code-simplifier` |
| `claude-plugins-official/feature-dev` | `feature-dev` (also exposes `code-architect`, `code-explorer`, `code-reviewer` agents) |
| `claude-plugins-official/commit-commands` | `commit`, `commit-push-pr`, `clean_gone` |
| `claude-plugins-official/frontend-design` | `frontend-design` |
| `claude-plugins-official/context7` | `context7` (docs fetcher) |
| `claude-plugins-official/playwright` | playwright tools |
| `claude-plugins-official/typescript-lsp` | LSP integration |
| `claude-plugins-official/security-guidance` | security review |
| `claude-plugins-official/explanatory-output-style` | this output style |
| `claude-plugins-official/gopls-lsp` | Go LSP |
| `firecrawl` | `firecrawl`, `skill-gen` |

### Bundled Claude Code skills (CLI built-ins)

`/simplify`, `/batch`, `/debug`, `/loop`, `/claude-api`, `/init`, `/review`, `/security-review`, `/update-config`, `/keybindings-help`, `/fewer-permission-prompts`, `/schedule`, `/skill-creator`.

### Sister project (../mobile/)

KMP project at `/Users/koren/Dev/lets-go/.claude/skills/`: 15 skills covering Android/Kotlin/Compose Multiplatform: `android-clean-architecture`, `api-design`, `coding-standards`, `compose-multiplatform-patterns`, `database-migrations`, `deployment-patterns`, `design-an-interface`, `docker-patterns`, `improve-codebase-architecture`, `kotlin-coroutines-flows`, `kotlin-patterns`, `kotlin-testing`, `lets-cook`, `postgres-patterns`, `security-review`.

---

## WolfieLeader/agentic-kit — your own framework

Repo: [github.com/WolfieLeader/agentic-kit](https://github.com/WolfieLeader/agentic-kit). Author: Koren Yairi (you). 12 skills + 4 agents. Status: v0.1 draft, last updated 2026-04-13. The most ambitious framework in this research because it explicitly synthesizes the best ideas from the other five collections.

**Self-described thesis** (from `docs/WHITEPAPER.md`):

> Converge toward one-shot task execution through project-specific learning. Each task produces structured reflection. Reflections surface patterns. Patterns become tighter instructions, better skills, and sharper guardrails. **Individual task quality is a side effect of the feedback loop.**

> **First-pass success over per-token cost.** Use the strongest model for high-judgment work. Retries are more expensive than getting it right the first time.

Acknowledged sources: Compound Engineering (lifecycle, agents, artifacts), Superpowers (discipline, gates, TDD, verification), CC10X (circuit breakers, routing), Matt Pocock (TDD philosophy, deep modules, behavioral testing), ECC (agent design, file budgets, grep-first search).

### The 12 skills

**User-facing entry points:**

| Skill | What it does |
|---|---|
| `/yo` | Universal entry point. Two-pass routing (self-look → classify) → BUILD/FIX/EXPLORE/REVIEW. Generates slug `YYMMDD-NNN-kebab-topic`. Detects monorepo umbrellas, runs git status across all repos. Resume check via `wiki/sketches/` + `wiki/blueprints/` YAML frontmatter grep. |
| `/health` | Project diagnostic + onboarding. Initializes new projects (creates `wiki/` + MAP.md). Lints the wiki: finds contradictions, stale claims, orphans, missing cross-references. |
| `/extensions` | Add project-specific agents/skills to pipeline phases. Phase caps prevent token bloat. |
| `/propose` | Mine all data points (retros, diagnoses, reviews, health reports) for recurring patterns. Drafts change proposals to `wiki/evolve/<slug>-proposals.md`. |
| `/evolve` | Execute accepted proposals. Order: claude-md → skill → process → research → docs → code → tests. Updates `wiki/CHANGELOG.md`. **The compounding mechanism.** |
| `/navigate` | Wiki traversal helper. |

**Pipeline phases** (invoked by `/yo`, not directly):

| Skill | What it does |
|---|---|
| `diagnose` | FIX gate. Reproduce → classify → hypothesize → severity. No artifact (in-context only). Routes to craft (light) or sketch (std/deep). |
| `sketch` | BUILD/FIX std/deep. Captures **what** + **why**. BUILD-mode and FIX-mode templates. Anti-anchoring: ask user's instinct first, THEN show options, THEN recommend. |
| `blueprint` | Defines **how**. Implementation units as vertical slices, each with goal + dependencies (DAG, no circles) + confidence GREEN/YELLOW/RED + test scenarios. **No code or shell commands** — "trust the crafting agent." 4-check fail-closed gate (dep coherence / completeness via blueprint-reviewer / no placeholders / testability). Max 3 retries. |
| `craft` | Implements with TDD guardrails + exception protocol. Light = inline; std/deep = sequential subagent-per-unit. RED-GREEN-REFACTOR per test scenario. 4-fix circuit breaker. |
| `verify` | Single step that scales by tier. Evidence-based verification + unified code review (std/deep). |
| `retro` | Per-task reflection. Living document during session, finalized at end. Feeds `/propose`. **The data point that compounds.** |

### The 4 agents

| Agent | Model | Role |
|---|---|---|
| `code-explorer` | Sonnet | Scans source code, patterns, dependencies, git history. First stop: MAP.md. Budget: 15 files max. Grep-first narrowing. Attributes findings (file:line evidence vs model knowledge). |
| `docs-explorer` | Sonnet | Searches `wiki/` artifacts via YAML frontmatter grep. External escalation to Context7 MCP / official docs / GitHub if knowledge gap. Persists external research to `wiki/research/<topic>.md`. |
| `blueprint-reviewer` | Sonnet | Validates blueprint coherence (internal consistency, terminology drift), feasibility (will it survive contact with reality?), scope (challenges unjustified complexity). Findings require file/line. **Orchestrator (Opus) defends false positives.** |
| `code-reviewer` | **Opus** | 3 sequential passes (Correctness / Testing / Maintainability). Each pass writes "No findings." if clean — forces explicit consideration. Severity P0-P3. **Threshold defense:** orchestrator defends findings that contradict the blueprint. |

### Key design decisions (from README + WHITEPAPER)

1. **Knowledge graph via filesystem** — All `wiki/` artifacts use YAML frontmatter for grep-first retrieval. `module:` and `tags:` are edges, `grep` is traversal. Inspired by Karpathy's LLM Wiki: persistent compilation over runtime retrieval.
2. **4-handoff boundary** — Research (NeurIPS 2025, Google Research Jan 2026) shows >4 agent handoffs degrade in production due to compounding per-step failure rates. The std/deep pipeline has 6 phases but only 4 disk-based handoffs: sketch.md → blueprint.md → craft output → retro.md.
3. **TDD by default** — RED-GREEN-REFACTOR mandatory with exception protocol for non-testable changes. 4-fix circuit breaker stops runaway debugging.
4. **Extension system with caps** — Projects add domain-specific agents/skills via `/extensions`. Phase caps prevent token bloat.
5. **Lint as first-class operation** — `/health` is the wiki's lint: finds contradictions, stale claims, orphans, missing cross-references.
6. **Right-size ceremony to scope** — Lightweight (single file, low ambiguity) skips sketch + blueprint + explorers. Std/deep gets full pipeline. Every change gets *something*.
7. **Hard ban on placeholders** — TBD/TODO/FIXME/HACK/XXX prohibited in artifacts (PostToolUse hook enforced).
8. **Slug discipline** — `YYMMDD-NNN-kebab-topic`, NNN resets daily at 001.

### Hard gates (from CLAUDE.md)

1. DESIGN-THEN-CODE
2. OPTIONS-THEN-RECOMMEND (anti-anchoring)
3. ARTIFACT-BEFORE-HANDOFF
4. EXPLORE-BEFORE-IMPLEMENT
5. EVIDENCE-BEFORE-CLAIMS
6. INVESTIGATE-THEN-FIX
7. TEST-THEN-CODE (with documented exception protocol)

### Synthesis (agentic-kit)

This is the **most ambitious and most explicitly Opus-4.7-tuned** framework in the entire research set. The "first-pass success over per-token cost" thesis is precisely the economic argument Opus 4.7 enables: the model is expensive enough that paying 1.5× for one good attempt beats 0.7× × 3 attempts with cheaper models. None of the other five collections make this thesis explicit.

**What it copies, well:**
- Compounding loop (EveryInc's `/ce-compound` pattern → `/propose` + `/evolve`)
- TDD with rationalization defense (obra's Iron Laws → exception protocol)
- 3-pass code review (EveryInc's persona reviewers, simplified to one Opus agent doing 3 passes — "more coherent and 3× cheaper")
- Grep-first retrieval (Karpathy + ECC)
- 4-fix circuit breaker (CC10X)

**What it does novel:**
- Explicit 4-handoff boundary with research citation (NeurIPS 2025)
- `/health` as wiki lint (finds contradictions/stale/orphans — none of the others have this)
- Threshold defense — orchestrator (Opus) defends findings against blueprint, prevents reviewer flip-flop
- Slug-based daily counter for traceability
- Hard ban on placeholders enforced via PostToolUse hook (orthogonal to obra's "delete means delete")
- Single-Opus 3-pass code review instead of multiple persona agents (token-economy optimization specific to high-end models)

**Risks:**
- v0.1 draft, 0 stars — no community validation
- Single maintainer (you)
- Higher onboarding cost than addyosmani's uniform templates
- Unproven at multi-developer scale — `wiki/` filesystem could become a contention point with concurrent writes from multiple devs/sessions
- Self-modification via `/evolve` is powerful but potentially unstable — a bad proposal accepted and applied could degrade the framework itself

---

## Verdict — what's better when

| If you want… | Use… |
|---|---|
| Hard read-only guarantee before editing | **Plan mode** (Shift+Tab). Nothing else gives tool-level enforcement. |
| Process discipline against shortcuts | **obra/superpowers**. Iron Laws + rationalization tables = strongest anti-sycophancy harness. |
| Knowledge that compounds across sessions | **EveryInc compound-engineering** (proven, active) or **WolfieLeader/agentic-kit** (more ambitious, unproven). |
| Generic SDLC playbook for a team | **addyosmani/agent-skills**. Most uniform, most transferable, multi-platform. |
| TS-flavored DDD with grilling loops | **mattpocock/skills**. Great if you live in the Ousterhout/Fowler tradition. |
| Output token reduction | **JuliusBrussee/caveman** (with the Boundaries clause merged in from Julius's version). |
| Producing real artifacts (xlsx, docx, pdf, slides) | **anthropics/skills** — these are the official ones. |
| Building your own skill | **anthropics/skill-creator** (or mattpocock/`write-a-skill`, or obra/`writing-skills`). |
| Single framework explicitly tuned for Opus 4.7 | **agentic-kit** — the only one that names the "first-pass success > per-token cost" thesis. |

### Most novel patterns worth stealing

1. obra's **two-stage subagent review** (spec compliance ✅ THEN code quality)
2. obra's **3 failed fixes → question architecture** rule in `systematic-debugging`
3. obra's **forbidden words** list ("Perfect!", "You're absolutely right!", "Thanks")
4. mattpocock's **deletion test** for shallow modules
5. EveryInc's **`docs/solutions/*.md` with YAML frontmatter** for grep-first retrieval
6. Caveman's **Boundaries clause** (Code/commits/PRs stay normal)

### Most overhyped claims

- "65%/75%/97% token savings" headlines mostly measure different things (output tokens vs. injected chars vs. end-to-end cost) and conflate them.
- Productivity claims ("1 dev = 5 devs", "10x performance") are anecdotal with no controls.
- Star counts and install counts are vanity metrics; OpenAIToolsHub admits marketplace numbers are inflated.

### Recommendations specific to this repo (`mobile-new`)

1. **Adopt EveryInc's `docs/solutions/*.md` pattern** — your Stripe + Veriff + Supabase + Borderless integration patterns are high-value compounding knowledge that should survive `/clear`. Minimal infrastructure, high leverage.
2. **Steal obra's `verification-before-completion` forbidden-words list** for your project — adding "Perfect!", "Done!", "Great!" to the no-go list directly counters Claude's sycophancy without installing the full superpowers harness.
3. **Don't install caveman.** Your CLAUDE.md prizes precise, calibrated communication; caveman fights that. If you want compression, set `effort: low` on specific skills instead.
4. **Audit overlap** between your custom `coding-standards` and Addy's `code-review-and-quality` / `code-simplification` — likely redundant, costing description-budget chars.
5. **Plan mode > planning skills** for sensitive work in this repo (payments, auth, ledger). The tool-level read-only guarantee is what you want.

---

## Sources

### Anthropic primary
- [Skills documentation](https://code.claude.com/docs/en/skills)
- [Permission modes (Plan mode section)](https://code.claude.com/docs/en/permission-modes)
- [Subagents (Plan subagent)](https://code.claude.com/docs/en/sub-agents)
- [Ultraplan (cloud planning)](https://code.claude.com/docs/en/ultraplan)
- [Anthropic engineering: Equipping agents with Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)
- [Anthropic news: Introducing Agent Skills](https://claude.com/blog/skills) (Oct 16, 2025)
- [Claude Opus 4.5 launch (token efficiency data)](https://www.anthropic.com/news/claude-opus-4-5)
- [agentskills.io — Open spec](https://agentskills.io)

### Skill collection repos
- [anthropics/skills](https://github.com/anthropics/skills) — 123.6k stars
- [mattpocock/skills](https://github.com/mattpocock/skills)
- [obra/superpowers](https://github.com/obra/superpowers)
- [EveryInc/compound-engineering-plugin](https://github.com/EveryInc/compound-engineering-plugin)
- [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) — 22.8k stars
- [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) — 46k stars

### Articles & analysis
- [Simon Willison: Claude Skills bigger than MCP](https://simonwillison.net/2025/Oct/16/claude-skills/)
- [Jesse Vincent: Superpowers blog post (Oct 9, 2025)](https://blog.fsck.com/2025/10/09/superpowers/)
- [Every: Compound Engineering canonical essay](https://every.to/chain-of-thought/compound-engineering-how-every-codes-with-agents)
- [Decrypt: Devs make Claude talk like a caveman](https://decrypt.co/363440/devs-claude-talk-like-caveman-cut-costs-work-better)
- [Resolve: Matt Pocock TDD skill](https://resolvewith.me/blog/tdd-skill-claude-code-matt-pocock)
- [SiliconAngle: Anthropic makes Agent Skills open standard (Dec 2025)](https://siliconangle.com/2025/12/18/anthropic-makes-agent-skills-open-standard/)

### Related ecosystem
- [Composio: Top 10 Claude Skills 2026](https://composio.dev/content/top-claude-skills)
- [VoltAgent: awesome-agent-skills](https://github.com/VoltAgent/awesome-agent-skills) — 1000+ skills index
- [OpenAIToolsHub: 349 skills ranked by stars](https://www.openaitoolshub.org/en/blog/best-claude-code-skills-2026)
- [mibayy/token-savior](https://github.com/mibayy/token-savior) — character-injection metric (caveat: different unit from token savings)
