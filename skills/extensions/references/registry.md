# Extension Registry

Reference for available extension types, integration points, and examples.

## Extension Categories

### Router Extensions (cap: 2)

Dispatch alongside the framework's code-explorer and docs-explorer agents
during Pass 5. (These are `Agent(subagent_type: "general-purpose")` with the
agent .md instructions — not the built-in `"Explore"` or the marketplace
`"feature-dev:code-explorer"`. See yo/SKILL.md Pass 5 disambiguation.)

**Purpose:** Surface domain-specific context the framework explorers miss.

**Output contract:** Key Findings, Relevant Files, Open Questions.

**Examples:**
- **infra-explorer** — Scan Terraform/Docker/CI configs for deployment context
- **api-explorer** — Trace API contracts (OpenAPI specs, GraphQL schemas, Postman collections)
- **dependency-explorer** — Analyze dependency graph, flag outdated/vulnerable packages

### Diagnose Extensions (cap: 2)

Dispatch during diagnose step 5, before routing decision.

**Purpose:** Specialized investigation for domain-specific bug classes.

**Output contract:** Investigation findings with classification support.

**Examples:**
- **perf-investigator** — Profile hot paths, check for N+1 queries, measure response times
- **env-investigator** — Check environment parity (local vs CI vs production configs)

### Craft Extensions (cap: 2 agents + 2 skills)

Run after each craft unit completes (step D).

**Purpose:** Domain-specific validation and transformation on fresh code.

**Agent output contract:** Structured findings (pass/fail per check).
**Skill output contract:** Standard skill format (procedure + output).

**Examples:**
- **lint-agent** — Run project linter, report violations
- **i18n-agent** — Check for hardcoded strings, missing translation keys
- **migration-skill** — Generate DB migration files for schema changes
- **api-docs-skill** — Update OpenAPI spec from route changes

### Verify Extensions (cap: 3)

Dispatch during verify Phase 2, alongside unified code-reviewer.

**Purpose:** Domain-specific review perspectives the core 3-pass review misses.

**Output contract:** Evidence-based findings with severity (P0-P3).

**Reference checklists available:**
- `references/security-checklist.md` — OWASP, auth, injection, data protection
- `references/performance-checklist.md` — DB, API, frontend, general
- `references/accessibility-checklist.md` — Keyboard, ARIA, forms, visual

**Examples:**
- **security-reviewer** — OWASP top 10, auth bypass, data exposure (use security-checklist.md)
- **perf-reviewer** — Query plans, bundle size, caching strategy (use performance-checklist.md)
- **a11y-reviewer** — WCAG 2.1 AA compliance, keyboard nav, ARIA (use accessibility-checklist.md)
- **api-contract-reviewer** — Breaking changes, versioning, backwards compatibility

## Creating an Extension

1. Write the agent/skill file in `.claude/agents/` or `.claude/skills/`
2. Run `/extensions` with the agent/skill name and target phase
3. The skill validates fit, checks caps, and registers in `.docs/extensions/<phase>.md`

Extensions are always-on once registered. No per-task toggling.
Lightweight craft skips extensions entirely.
