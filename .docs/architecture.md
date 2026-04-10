# Framework Architecture

> Core design principles and structure that govern the entire framework.

## Relationship with Existing Plugins

**Incremental replacement of Superpowers.** These 3 skills + 2 agents are the first phase. For everything not yet covered (execution, code review, debugging, worktrees, finishing branches), continue using Superpowers temporarily. Once all skills are built, uninstall Superpowers entirely. The custom framework is fully standalone — no dependency on Superpowers internals.

## Design Principles

1. **Context window is gold — use the disk.** Every skill writes its output to disk before completing. Handoff between skills is always via persisted artifacts. Concrete rule: every phase that produces output MUST write to disk; every phase that consumes input MUST read from disk. Never relay data between skills via conversation context. This means skills are session-independent — you can `/compact` between phases, start a new conversation, or come back days later and pick up from the persisted artifact.
2. **One entry point, three workflows.** `/letsgo` is the universal entry point. It classifies work as BUILD, FIX, or EXPLORE and routes to the appropriate workflow skill. Users can bypass the router and invoke workflow skills directly.
3. **Trust the implementing agent.** Plans describe *what* to build and the architectural decisions that constrain it, but trust the implementing agent to figure out *how*.
4. **Right-size ceremony to scope.** Lightweight changes get lightweight process. Deep features get full design treatment. But every change gets *something*.

## Workflows & Skills

See [workflow-design.md](workflow-design.md) for the full workflow architecture.

### User-invocable skills

| Skill | Purpose | Status |
|-------|---------|--------|
| `/letsgo` | Router — classifies type (BUILD/FIX/EXPLORE) + tier, routes to workflow | Refactor needed |
| `/brainstorm` | BUILD workflow entry — design & brainstorm | Extract from current /letsgo |
| `/plan` | Planning — turns brainstorm into executable tasks | Not built |
| `/fix` | FIX workflow — triage, investigate, TDD fix | Not built |
| `/explore` | EXPLORE workflow — research, analyze, report | Not built |
| `/batch` | Orchestrate multiple tasks across worktrees | Not built |

### Internal skills (not user-invocable)

| Skill | Purpose | Source to fork |
|-------|---------|---------------|
| TDD | Test-Driven Development discipline | Superpowers' TDD + Matt Pocock + ECC |
| Verification | Per-task + final verification checkpoints | Superpowers + CC10X |
| Retro | Post-work capture: technical knowledge + process reflection (CE compound + retro merged) | CE's ce:compound (adapted) |
| Review | Conditional reviewer personas | CE's multi-persona review |

## Agents (`.claude/agents/`)

| Agent | Purpose | Source to fork |
|-------|---------|---------------|
| `code-explorer.md` | Scans code, module READMEs, git history. **Excluded:** `.docs/` | ECC's `code-explorer.md` |
| `docs-explorer.md` | Scans `.docs/work/` (brainstorms, retros), project docs, CLAUDE.md, AGENTS.md. **Escalation heuristic:** escalates to external sources (context7 MCP, web search) when the topic involves third-party services, SDKs, or frameworks your team doesn't control; stays internal for architecture decisions, business logic, and codebase patterns. **Excluded:** source code, in-progress work items (brainstorm without plan) | Custom, inspired by CE's `learnings-researcher` |

Both agents return **light structured output**:
```
## Key Findings
...
## Relevant Files
...
## Open Questions
...
```

## Artifact Directory Structure

```
.docs/
  work/
    YYMMDD-<slug>/
      brainstorm.md    — WHAT/WHY (pre-work)
      plan.md          — HOW (pre-work, BUILD/FIX only)
      retro.md         — EVERYTHING post-work (technical knowledge + process reflection)
  research/
    <topic>.md         — reusable topic knowledge (living documents)
  MAP.md               — dynamic project navigation index
```

Three things: `work/`, `research/`, and `MAP.md`.

### All files use YAML frontmatter

Every `.md` file under `.docs/` has YAML frontmatter with structured metadata for grep-first retrieval. The frontmatter is the index, not the folder structure. Universal fields across work artifacts: `module`, `tags`, `type`. Research files share `module` and `tags`.

#### brainstorm.md

```yaml
---
title: "Payment Webhook Handling"
date: 2025-04-10
type: build                              # build | fix | explore
scope: standard                          # lightweight | standard | deep
status: complete                         # draft | complete
module: payments
tags: [payments, webhooks, stripe]
affected_systems: [payments, api]
---
```

Template: `skills/letsgo/references/brainstorm-template.md`

#### plan.md

```yaml
---
title: "Payment Webhook Handling"
date: 2025-04-11
source_brainstorm: 250410-payment-webhooks
scope: standard                          # lightweight | standard | deep
status: complete                         # draft | complete | blocked
overall_confidence: GREEN                # GREEN | YELLOW | RED
module: payments
tags: [payments, webhooks, stripe]
unit_count: 5
---
```

Template: see [skill-specs.md](skill-specs.md) section 2

#### retro.md

```yaml
---
title: "Payment Webhook Handling"
date_completed: 2025-04-12
source_brainstorm: 250410-payment-webhooks
type: build                              # build | fix | explore | adhoc
outcome: success                         # success | partial | failed
module: payments
tags: [payments, webhooks, idempotency, stripe]
# FIX-only fields:
severity: high                           # critical | high | medium | low
root_cause: missing_validation           # enum per project
---
```

Template and examples: see [workflow-design.md](workflow-design.md) retro section

#### research files (`.docs/research/<topic>.md`)

```yaml
---
title: "Stripe Webhooks"
date_created: 2025-04-10
date_updated: 2025-04-15
module: payments
tags: [stripe, webhooks, payments, idempotency]
---
```

Reusable topic knowledge — not tied to any work item. Living documents that agents check before doing fresh research and update when they learn something new. The dates tell agents about freshness: a `date_updated` from months ago warrants verification before relying on the content.

Template: `skills/letsgo/references/research-template.md`

### Folder state signals progress

| Contents | Meaning |
|----------|---------|
| `brainstorm.md` only | Designed, not yet planned |
| `brainstorm.md` + `plan.md` | Planned, not yet executed |
| `brainstorm.md` + `plan.md` + `retro.md` | Full BUILD/FIX cycle complete |
| `brainstorm.md` + `retro.md` | EXPLORE workflow complete (no plan needed) |
| `retro.md` only | Ad-hoc knowledge capture, no formal workflow (`type: adhoc`) |

### Conventions

- **Naming**: `YYMMDD-<slug>` (e.g., `250410-payment-webhooks`)
- **Folder creation is eager** — `/brainstorm` creates the folder and `brainstorm.md` immediately
- **MAP.md** is a dynamic navigation index for the project codebase (not `.docs/`). Maintained by an agent after completed work. Generated via `rtk tree`. Format rules:
  - **Collapsed platform notation**: document the boilerplate path pattern once at the top, then show only the meaningful logical structure below
  - **`[README]` markers** on directories that have a README
  - **Comments only when not self-explanatory**

### retro.md — the single post-work artifact

Adapted from CE's `ce:compound`. Combines technical knowledge capture (what we learned) with process reflection (how it went) in ONE file. Like CE, the primary output is one file — we just co-locate it with the brainstorm and plan that produced it.

```yaml
---
title: Payment Webhook Handling
date_completed: 2025-04-12
source_brainstorm: 250410-payment-webhooks
type: build                         # build | fix | explore | adhoc
outcome: success                    # success | partial | failed
module: payments
tags: [payments, webhooks, idempotency, stripe]
---
```

**Sections adapt to workflow type:**
- **BUILD/FIX**: Result, What We Learned, What Went Well, What Went Wrong (categorized root causes), Action Items, Prevention
- **EXPLORE**: Findings, Sources, Open Questions, What Went Well/Wrong (optional)

**Root cause categories** for "What Went Wrong" (check all that apply):
- Poor user description · Incorrect scope/tier · Poor brainstorm decisions
- Stale research/docs · Poor CLAUDE.md · Poor code patterns/structure
- Poor test coverage · Poor enforcement · Poor skill behavior (→ GitHub issue)

**The feedback loop:** Retros accumulate. The team reviews them to find patterns and decide what needs fixing. Bad input doesn't change the framework unilaterally — the team discusses and decides where the fix belongs (codebase, docs, CLAUDE.md, agentic-kit, or team process).

## Skill-to-Skill Handoff

Follows CE's artifact discovery pattern (session-independent):
1. If argument provided (`/plan 250410-payment-webhooks`) → use that directly
2. If no argument → scan `.docs/work/*/` for folders with `brainstorm.md` but no `plan.md`
   - **Status gate**: Skip brainstorms with `status: draft` — they're incomplete. Tell user to finish the brainstorm first or explicitly override.
   - **Type filter**: Skip brainstorms with `type: explore` — EXPLORE workflow doesn't produce a plan. These are not "unplanned" work.
3. If exactly one match → propose it
4. If multiple matches → list them, ask user to pick (sort by date descending, show 5 most recent if 10+)
5. If no matches → tell user to run `/letsgo` first

## Knowledge Retrieval

Agents discover past knowledge by grepping YAML frontmatter across two locations:

```bash
# Past work — retros
grep -rl "module: payments" .docs/work/*/retro.md
grep -rl "type: fix" .docs/work/*/retro.md
grep -rl "tags:.*stripe" .docs/work/*/retro.md

# Reusable research
grep -rl "module: payments" .docs/research/*.md
grep -rl "tags:.*stripe" .docs/research/*.md
```

**Search order:** Check `.docs/research/` first (curated topic knowledge), then `.docs/work/*/retro.md` (work-specific learnings). Research files are living documents — if `date_updated` is stale, verify before relying on content.

The `docs-explorer` agent uses grep-first retrieval: extract keywords → grep frontmatter fields → read frontmatter of matches → score relevance → full-read of top hits. CLAUDE.md instructs agents to check `.docs/research/` and `.docs/work/` before designing new approaches.

## Skill-Writing Tool

Use **skill-creator** plugin for building and iterating on skills and agents. It has explicit "Improve Existing Skill" mode with version tracking, parallel eval runs, and quantitative metrics.
