# Skill Stack Decisions — Strategic Notes

> Companion to `SKILLS-ECOSYSTEM-RESEARCH.md` (the inventory) and `RESEARCH.md` (the citations). This doc captures *strategic decisions* that came out of the field survey: which skills to adopt, why, what to skip, and the open questions about agentic-kit's positioning.

> Compiled 2026-04-25 from a deep-research session against the broader Claude Code skill ecosystem (mattpocock, obra/superpowers, EveryInc compound-engineering, addyosmani/agent-skills, anthropics/skills, JuliusBrussee/caveman, agentic-kit itself).

## Table of contents

1. [Core thesis](#core-thesis)
2. [Harness specificity is a moat](#harness-specificity-is-a-moat)
3. [Addy Osmani's actual contribution to RESEARCH.md](#addy-osmanis-actual-contribution-to-researchmd)
4. [Recommended skill stack for a TS company on Opus 4.7](#recommended-skill-stack-for-a-ts-company-on-opus-47)
5. [Honest assessment: "do we have a chance?"](#honest-assessment-do-we-have-a-chance)
6. [Risks specific to agentic-kit at v0.1](#risks-specific-to-agentic-kit-at-v01)
7. [Patterns to steal from each collection](#patterns-to-steal-from-each-collection)
8. [Patterns to skip](#patterns-to-skip)
9. [What to do during a tight migration (not a steady state)](#what-to-do-during-a-tight-migration-not-a-steady-state)
10. [Open questions for v0.2 design](#open-questions-for-v02-design)

---

## Core thesis

**"First-pass success over per-token cost" is the right Opus-4.7 economic argument, and agentic-kit is the only framework in the ecosystem that names it explicitly.**

Anthropic's published numbers (Opus 4.5 launch): Opus 4.5 uses 48% fewer tokens than Sonnet 4.5 at matched quality, and 76% fewer output tokens at medium effort on SWE-bench Verified. At Opus 4.7 prices ($5/MTok input, $25/MTok output per RESEARCH.md §3), retries are catastrophically expensive. Frameworks tuned for "save tokens by using cheaper models" are solving the wrong problem; the right problem is "spend the tokens on getting it right the first time, with structured ceremony to maximize first-pass success."

EveryInc's 80/20 plan/execute split is adjacent but not the same — they're optimizing for *human review surface*, not for *first-pass model success*. obra's Iron Laws fight a different problem (model sycophancy and shortcuts). agentic-kit is the only framework that targets the model-economics question directly.

This is the framework's defensible positioning. Lean into it. Stop hedging with multi-harness adapters or "compatible with Sonnet" disclaimers. agentic-kit is for teams who have decided Claude Code + Opus 4.7 is the production harness and want to extract maximum value.

---

## Harness specificity is a moat

The portable-everywhere skill collections (Addy's, parts of obra, parts of EveryInc) trade Claude Code-specific power for cross-harness portability. The full Claude Code frontmatter has 14 fields:

```
name, description, when_to_use, argument-hint, arguments,
disable-model-invocation, user-invocable, allowed-tools,
model, effort, context, agent, hooks, paths, shell
```

Multi-harness skills can only use `name` + `description`. Everything else is Claude Code-specific. **They're prompts; Claude Code-specific skills are programs.**

Capabilities multi-harness skills cannot use:
- `disable-model-invocation: true` (slash-only triggering — no auto-fire)
- `context: fork` + `agent: Plan|Explore|general-purpose` (forked subagent execution)
- `allowed-tools` (per-skill permission grants)
- `paths` glob (auto-activation only on matching files)
- `hooks` (skill-scoped lifecycle events)
- `model` / `effort` overrides (per-skill model routing — `claude-haiku-4-5` for mechanical, `claude-opus-4-7` for high-judgment)
- `${CLAUDE_SESSION_ID}` / `${CLAUDE_SKILL_DIR}` substitutions
- `` !`<command>` `` dynamic context injection
- The `ultrathink` keyword for extended thinking

**Estimated leverage gap: 40-60% of available power.** Multi-harness skills work everywhere but extract less from each. Claude Code-only skills work in one place but extract everything.

For a company that has standardized on Claude Code + Opus 4.7, the multi-harness positioning is a *defensive* bet (hedging against Anthropic). The harness-specific positioning is an *offensive* bet (compounding on Anthropic's investment). At Opus 4.7 prices, defensive bets are mispriced — you're already paying for offensive economics.

**Action**: agentic-kit should be openly Claude-Code-first, with no apology. Document the harness-specific features used. Make the "Claude Code only, by design" positioning load-bearing in marketing.

---

## Addy Osmani's actual contribution to RESEARCH.md

A pattern worth being honest about: Addy gets cited in §18.2 as one of nine framework observations, but **he is not the source of most of the research**. Verified by re-reading RESEARCH.md:

| RESEARCH.md section | Source | Addy's role |
|---|---|---|
| Lost in the middle (§2.2) | Liu et al. 2023 (arxiv 2307.03172) | None |
| Context rot (§2.3) | Chroma research | None |
| Prompt caching mechanics (§3) | Anthropic official docs | None |
| AGENTS.md study (§5.1) | Gloaguen et al. ETH Zurich (arxiv 2602.11988) | Cites it (he's one of many citing it) |
| Multi-agent token consumption (§9) | Anthropic BrowseComp + practitioner heuristics | Source for unsourced "three focused agents" claim — flagged by RESEARCH.md as practitioner opinion without empirical backing |
| 4-handoff boundary | NeurIPS 2025 + Google Research Jan 2026 | None |
| Karpathy LLM Wiki (§18.1) | Karpathy's gist | None |
| Spec-driven development (§18.2 + §18.7) | GitHub Spec-Kit + Addy's good-spec post | One of two sources |
| Code Agent Orchestra (§18.2) | Addy's blog | Primary |

**RESEARCH.md line 1097:** *"Addy's / obra's 'MUST invoke skill if match' (§18.2, §18.3) — this is the pattern that caused the auto-invocation bug fixed in v0.3.1. Opt-in ceremony is load-bearing here. Rigid must-invoke rules produce silent auto-starts."*

Addy's pattern actively caused an agentic-kit bug. We rejected his discipline rule.

**Conclusion**: Addy is a high-quality *index* into the research, not the primary source. His blog posts (`good-spec`, `code-agent-orchestra`) are worth absorbing. His SKILLS are deliberately less Claude-specific (multi-harness portability) and don't fit our positioning. His orchestration claims ("three focused agents outperform one generalist", "3-5 teammates is the sweet spot", "linear token costs") are practitioner heuristics RESEARCH.md flags as unsourced.

Don't over-anchor on Addy. The framework's research grounding is independent.

---

## Recommended skill stack for a TS company on Opus 4.7

Tiered by urgency and maintainer commitment.

### Tier 1 — Foundation (mandatory)

- **anthropics/skills** — install via `/plugin marketplace add anthropics/skills` for the document-skills bundle (`docx`, `pdf`, `pptx`, `xlsx`). Free, official, no debate.
- **anthropics/skill-creator** — for any team-internal skill creation, keep spec-aligned.

### Tier 2 — The compounding spine (pick one)

**Option A (safe, larger teams):** EveryInc compound-engineering-plugin, restricted to:
- `ce-brainstorm`, `ce-plan`, `ce-work`, `ce-code-review`, `ce-compound`, `ce-compound-refresh`
- Skip the other 30 utility skills

**Option B (ambitious, smaller teams with a champion):** agentic-kit. The `/yo` → pipeline → `/propose` → `/evolve` loop is more sophisticated than EveryInc's compound mechanism. But requires single-maintainer commitment. **For a company adoption, this only works if the maintainer is staked.**

### Tier 3 — Cherry-pick disciplinary skills

From obra/superpowers, add **only**:
- `verification-before-completion` — forbidden-words list ("Perfect!", "Done!", "Great!") is the single highest-leverage anti-sycophancy pattern in the ecosystem.
- `systematic-debugging` — 3-failures → architecture rule.

Skip the rest of obra. The `<HARD-GATE>` tone is too aggressive for most teams.

### Tier 4 — Domain-specific (per project, not org-wide)

Each team adds 3-5 skills per their stack. Don't try to standardize this layer — leads to 80-skill bloat that exhausts the description-listing budget (8,000 chars or 1% of context window).

For TS teams: Pocock's `tdd/` reference files (`deep-modules.md`, `interface-design.md`, `mocking.md`, `refactoring.md`, `tests.md`) loaded into a `wiki/research/typescript/` directory — as reference material your skills cite, not as standalone skills.

---

## Honest assessment: "do we have a chance?"

**Yes, conditional on three things:**

1. **Solve bus factor before company adoption.** v0.1 with one maintainer is a coin flip for any team larger than 3. Recruit one co-maintainer who could ship a v0.2 without you. Not a contributor — a *co-maintainer*. Until that exists, every adoption answer has a footnote.

2. **Set the right week-1 expectations.** The compound loop pays off after 30-50 features, not after 8. Features 1-8 with full ceremony are *slower* than ad-hoc Claude usage. Teams that bail at feature 8 ("this ceremony is slowing us down") never get the compound payoff. Lock in a 6-week minimum pilot before evaluating.

3. **Don't hedge on harness.** Decide Claude Code is *the* harness. Stop maintaining mental models for "what if we move to Codex." If Anthropic's pricing changes catastrophically, rewrite. Until then, extract every drop the harness offers.

**Why "yes":**

- The compounding loop is real moat. After 6 months of `/propose` + `/evolve` runs on a real codebase, the gap between an agentic-kit team and an ad-hoc team is 5-10×. After 12 months it's 20-50×. Same effect EveryInc reports for their 5+ products.
- Most engineering teams in 2026 use Claude Code with no skills, no compounding, no discipline. The bar is dramatically lower than discourse suggests. We don't need to beat optimal-everything teams; we need to beat the team running Claude with a 12-line CLAUDE.md.
- The TypeScript bet is strong (LSP depth, test ecosystem maturity, model training distribution).

---

## Risks specific to agentic-kit at v0.1

1. **Bus factor of 1.** Single maintainer.
2. **Concurrent multi-dev `wiki/` access untested.** Two devs running `/yo` on the same module simultaneously? Both invoking `/propose` against overlapping retros? Unknown. EveryInc's three-tier scratch/memory split (`.context/<plugin>/<workflow>/<run>/` for session-scoped, `mktemp -d` for throwaways, `docs/solutions/` for durable) is more mature here. **Steal their three-tier pattern.**
3. **Self-modification via `/evolve` is unproven.** A bad proposal accepted and applied could degrade the framework. Need: (a) human-in-the-loop on every accepted proposal, (b) CHANGELOG.md actually used as a rollback target, (c) dry-run mode that shows the diff before applying.
4. **Onboarding cost ~1 day per new dev.** Mitigation: `wiki/onboarding/<dev-name>.md` with a 30-minute pair-programming exercise that walks through one full BUILD pipeline. Actually do it.
5. **Stack-agnostic core has no TypeScript-specific skills.** Pocock's library has TS-flavored skills. Mixing is fine; means accepting Pocock's 14k stars + active maintenance for the TS layer.

---

## Patterns to steal from each collection

1. **EveryInc** — three-tier scratch/memory split (`.context/<plugin>/<workflow>/<run>/` vs `mktemp -d` vs `docs/solutions/`). More mature concurrency story than agentic-kit's `wiki/work/<slug>/`.
2. **EveryInc** — `ce-compound-refresh` keep/update/replace/archive cycle. Validates `/health` lint design, suggests adding archival semantics.
3. **obra** — `verification-before-completion` forbidden-words list ("Perfect!", "Done!", "Great!"). Direct counter to model sycophancy.
4. **obra** — 3-failures → architecture rule in `systematic-debugging`. Cleanly fits inside agentic-kit's existing 4-fix circuit breaker.
5. **obra** — Two-stage subagent review pattern (spec compliance ✅ THEN code quality). Already partially in agentic-kit's blueprint-reviewer + code-reviewer split — extend to two-stage on craft output.
6. **mattpocock** — Content of his `tdd/` reference files (`deep-modules.md`, `interface-design.md`, `mocking.md`, `refactoring.md`, `tests.md`) — load into `wiki/research/typescript/` as reference material agentic-kit's craft skill can cite.
7. **mattpocock** — `domain-model` + `ubiquitous-language` skills as a vocabulary substrate. Critical for migrations and domain-rich projects.
8. **Caveman** — Boundaries clause (Code/commits/PRs stay normal). Useful pattern for any output-style skills agentic-kit might add later.
9. **Anthropic official** — Minimalist 2-field frontmatter (`name`, `description`) + progressive disclosure. agentic-kit's skills are already lean; reinforce this discipline.

---

## Patterns to skip

1. **obra's `<HARD-GATE>` and "delete means delete" tone.** Coercive, fights team adoption.
2. **obra's "MUST invoke skill" pattern** (also in Addy). Caused agentic-kit v0.3.1 auto-invocation bug. Opt-in is load-bearing.
3. **EveryInc's 50+ agents.** Token-wasteful at Opus 4.7 prices. agentic-kit's single-Opus 3-pass review is the right optimization.
4. **Multi-harness adapters.** Sacrifices 40-60% of Claude Code's leverage.
5. **Caveman.** Fights precise/calibrated communication. For compression, use `effort: low` per-skill instead.
6. **Addy's lifecycle slash commands** (`/spec`, `/plan`, `/build`, `/test`, `/review`, `/code-simplify`, `/ship`). agentic-kit's `/yo` router is a superior single entry point.
7. **mattpocock's `obsidian-vault`.** Hardcoded path; personal not org tooling.

---

## What to do during a tight migration (not a steady state)

This section captures advice that's *different from* steady-state recommendations. Migrations are tactical projects, not platform investments.

**Don't adopt agentic-kit mid-migration.** The compound loop pays off after 30-50 features; a migration is one event. Ceremony cost in weeks 1-3 hurts the timeline. agentic-kit is for *post*-migration steady state.

**Use existing CLAUDE.md + skills, plus three additions:**

1. **Treat the legacy codebase as a behavior spec, not a code model.** Read-only reference. A doc that maps legacy screens/features → new implementation, with intents/edge cases/business rules, is worth its weight in gold.

2. **Pocock's `domain-model` and `ubiquitous-language` skills.** Highest-leverage skills for migrations specifically. If the two codebases use different terminology for the same thing, you'll have bugs. A `UBIQUITOUS_LANGUAGE.md` written once early saves 100× the time spent later.

3. **Lightweight EveryInc-style `docs/solutions/*.md` pattern.** As migration patterns are discovered (mapping legacy X → new Y), capture them as one-screen markdown files. Next 50 screens benefit. Cheapest compounding mechanism in the ecosystem.

**What NOT to adopt during a migration:**

- Full agentic-kit pipeline — too much ceremony.
- obra/superpowers — Iron Laws fight against the "find pragmatic mappings fast" mode you need.
- EveryInc compound-engineering-plugin — 36 skills is too much to onboard mid-crisis.
- New TDD discipline — if existing test setup works, don't change it.

**Retool the process AFTER the migration**, when there's time to invest in a 6-week pilot.

---

## Open questions for v0.2 design

1. **Concurrency model for `wiki/`.** What happens with two simultaneous `/yo` runs on overlapping modules? Need: explicit per-run subdirectories, file-locking story, or accept session-scoped temp dirs (EveryInc model).
2. **`/evolve` rollback.** Today: accepted proposals → applied → CHANGELOG. Need: dry-run mode showing diff, rollback command using CHANGELOG as undo log.
3. **TypeScript layer.** Stack-agnostic core is good. But TS-specific reference content (Pocock's deep-modules, refactoring patterns) needs a place. Proposal: `wiki/research/typescript/` as standard, optional, citeable from craft.
4. **Co-maintainer recruitment.** Bus factor blocks company adoption. Strategy?
5. **Public release timing.** v0.1 → v0.2 → v1.0 → public? Or earn community via early-adopter teams? Tradeoff: open early = potential community + risk of unstable design; open late = polish + miss the cycle.
6. **Marketplace positioning.** Should agentic-kit ship via `anthropics/claude-plugins-community` (Anthropic-hosted directory) or self-host? The former gets discoverability; the latter keeps full control over messaging.
7. **Onboarding skill.** Today: 1 day per new dev. Need: a `/onboard` skill that walks through one full BUILD pipeline interactively, leaving an artifact behind?
8. **Forbidden-words enforcement.** Steal from obra. As a hook? As a `verify` extension? As an `craft` post-condition?

---

## See also

- `RESEARCH.md` — citations, research findings, framework field observations
- `WHITEPAPER.md` — design spec, architecture, hard gates
- `SKILLS-ECOSYSTEM-RESEARCH.md` — full inventory of every skill in every researched collection (mattpocock, obra, EveryInc, addyosmani, anthropics, JuliusBrussee, agentic-kit)
