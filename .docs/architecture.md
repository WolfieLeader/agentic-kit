# Framework Architecture

> Core design principles and structure that govern the entire framework.

## Relationship with Existing Plugins

**Incremental replacement of Superpowers.** These 3 skills + 2 agents are the first phase. For everything not yet covered (execution, code review, debugging, worktrees, finishing branches), continue using Superpowers temporarily. Once all skills are built, uninstall Superpowers entirely. The custom framework is fully standalone — no dependency on Superpowers internals.

## Design Principles

1. **Skills hand off via files, never conversation context.** Every skill writes its output to disk before completing. Handoff between skills is always via persisted artifacts. This means skills are session-independent — you can `/compact` between phases (e.g., after `/letsgo`, before `/plan`), start a new conversation, or come back days later and pick up from the persisted artifact. `/compact` safety is the primary motivation for this principle.
2. **Brainstorming is mandatory.** No plan without a brainstorm. If `/plan` is invoked without a brainstorm, it tells the user to run `/letsgo` first.
3. **Trust the implementing agent.** Plans describe *what* to build and the architectural decisions that constrain it, but trust the implementing agent to figure out *how*.
4. **Right-size ceremony to scope.** Lightweight changes get lightweight process. Deep features get full design treatment. But every change gets *something*.

## Skills (user-invoked)

| Skill | Purpose | Source to fork |
|-------|---------|---------------|
| `/letsgo` | Brainstorming & Design | CE's `ce:brainstorm` |
| `/plan` | Planning | CE's `ce:plan` |

## Internal Skills (referenced by other skills, never user-invoked)

| Skill | Purpose | Source to fork |
|-------|---------|---------------|
| TDD | Test-Driven Development discipline | Superpowers' TDD + Matt Pocock layered in. Platform files forked from ECC |

## Agents (`.claude/agents/`)

| Agent | Purpose | Source to fork |
|-------|---------|---------------|
| `code-explorer.md` | Scans code, module READMEs, git history. **Excluded:** `.docs/` | ECC's `code-explorer.md` |
| `docs-explorer.md` | Scans `.docs/` (brainstorms, researches, solutions), project docs, ADRs, CLAUDE.md, AGENTS.md. **Escalation heuristic:** escalates to external sources (context7 MCP, web search) when the topic involves third-party services, SDKs, or frameworks your team doesn't control; stays internal for architecture decisions, business logic, and codebase patterns. Writes to `.docs/researches/` only when external research was conducted. **Excluded:** source code, `.docs/plans/` | Custom, inspired by CE's `learnings-researcher` |

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
  plans/
    YYMMDD-<slug>/
      brainstorm.md      — output of /letsgo
      plan.md            — output of /plan
  researches/            — shared, reusable knowledge (not tied to a single plan)
    payment-webhooks.md
    auth-provider.md
  solutions/             — (future: compound knowledge capture)
  MAP.md                 — dynamic project navigation index
```

- **Brainstorm and plan are co-located** in the same folder under `.docs/plans/<slug>/` because the brainstorm is part of the planning process
- **Researches are shared** — not tied to a single plan, reusable across future work
- **MAP.md** is a dynamic navigation index for the monorepo. Maintained by an agent after completed work. Generated via `rtk tree`. Format rules:
  - **Collapsed platform notation**: document the boilerplate path pattern once at the top (e.g., `> Paths follow: <module>/src/<platform>/<lang>/<org>/<module-package>/`), then show only the meaningful logical structure below
  - **`[README]` markers** on directories that have a README — signals the code-explorer where to dive deeper
  - **Comments only when not self-explanatory** — `repository/`, `model/`, `usecase/` need no comment; `di/` gets "dependency injection setup"
  - Example:
    ```
    feature/
      card/
        data/
          repository/
          model/
        domain/
          usecase/
        presentation/
          screen/
      auth/
        data/              — external-service integration [README]
    core/
      network/             [README]
      di/                  — dependency injection setup
    ```
- **Naming convention**: `YYMMDD-<slug>` (e.g., `250410-payment-webhooks`)
- **Folder creation is eager** — `/letsgo` creates the folder and `brainstorm.md` immediately. An incomplete folder (brainstorm.md without plan.md) signals "work started, not yet planned"

## Skill-to-Skill Handoff

Follows CE's artifact discovery pattern (session-independent):
1. If argument provided (`/plan 250410-payment-webhooks`) → use that directly
2. If no argument → scan `.docs/plans/*/` for folders with `brainstorm.md` but no `plan.md`
3. If exactly one match → propose it
4. If multiple matches → list them, ask user to pick
5. If no matches → tell user to run `/letsgo` first

## Skill-Writing Tool

Use **skill-creator** plugin for building and iterating on skills and agents. It has explicit "Improve Existing Skill" mode with version tracking, parallel eval runs, and quantitative metrics.
