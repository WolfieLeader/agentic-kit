# Inspirations & Design Decisions

> What agentic-kit takes from each source, what it rejects, and what it invents. Reference for understanding why the framework works the way it does.

## Sources

| Source | Role | Location |
|--------|------|----------|
| **Compound Engineering (CE)** | Primary structural influence — lifecycle, agents, artifacts | `.inspiration/core/compound-engineering/` |
| **Superpowers** | Discipline layer — gates, TDD, verification, rationalization prevention | `.inspiration/core/superpowers/` |
| **CC10X** | Rigor patterns — confidence scoring, DAG rules, circuit breakers | `.inspiration/other/cc10x/` |
| **Matt Pocock** | TDD philosophy — behavioral testing, vertical slicing, trust the agent | `.inspiration/other/matt-pococks-skills/` |
| **Everything Claude Code (ECC)** | Agent design — file budgets, grep-first search, platform-specific testing | `.inspiration/other/everything-claude-code/` |

**The synthesis:** CE gives us the lifecycle, Superpowers gives us the discipline, and the others fill specific gaps.

---

## From Compound Engineering (CE)

### Adopted

- **6-section brainstorm dialogue** — Purpose → Scope → Systems → Approaches → Constraints → Success
- **Implementation units** — Vertical slicing, behavioral goals, test scenarios
- **Artifact discovery handoff** — Scan for incomplete work, propose, session-independent
- **Anti-anchoring** — All options before recommendation
- **Blocking vs. deferred questions** split
- **Stable requirement IDs** — R1, R2 permanent, never renumbered
- **Grep-first retrieval** — Keywords → grep frontmatter → score → full-read
- **Confidence check and plan deepening** workflow
- **Multi-persona code review** — Conditional reviewer selection based on diff content

### Modified

| CE Pattern | Our Modification | Why |
|-----------|-----------------|-----|
| Files preferred, context fallback allowed | Files ONLY — no context fallback | `/compact` safety. Context-based handoff loses state. |
| Agent dispatch trimmed for lightweight | Mandatory for ALL scopes (Hard Gate G1) | 30-second parallel agents catch "already exists." Flagged as untested on throughput. |
| `ce:compound` → `docs/solutions/` with bug/knowledge tracks | Merged into `retro.md` in same work folder | Combine technical knowledge + process reflection in one file. |
| 3 separate dirs (brainstorms/, plans/, solutions/) | 1 dir: `.docs/work/YYMMDD-slug/` + `.docs/research/` | Co-location makes work units atomic. YAML frontmatter handles search. |
| 222-line `schema.yaml` with project-specific enums | Lightweight YAML frontmatter — examples, no formal validation | CE's schema is Rails-specific and high-maintenance. Ours is stack-agnostic. |
| Research consumed in conversation, lost after session | `.docs/research/<topic>.md` — living documents | Research done in January shouldn't be re-done in March. |
| Scope classification suggested | Mandatory user confirmation | Misclassification wastes time in both directions. |
| BUILD only (brainstorm→plan→work→compound) | BUILD + FIX + EXPLORE, each with distinct phases | Debugging and research have different needs than building features. |

### Rejected

- **Proof sharing** — Platform-specific, not a framework concern
- **Session historian agent** — Searches prior Claude/Codex/Cursor sessions. Platform-dependent.
- **Project-specific component enums** (rails_model, stimulus, hotwire_turbo) — We stay stack-agnostic

---

## From Superpowers

### Adopted

- **Hard gates** — `<HARD-GATE>` tags for non-negotiable rules
- **Rationalization prevention tables** — Named rationalizations with detection + correction
- **TDD discipline** — RED→GREEN→REFACTOR with git checkpoint commits
- **Placeholder bans** — Two-tier: hard-ban auto-reject + soft-ban flag-and-justify
- **Boundary-only mocking** — Mock at system boundaries, real code internally
- **80% coverage minimum** — Not 100% (that incentivizes testing trivial code)
- **Verification-before-completion** — Evidence before claims, always
- **Two-stage review** concept — Spec compliance, then code quality
- **"Delete code written before its test"** policy
- **Receiving code review protocol** — Push back on bad feedback with reasoning

### Modified

| Superpowers Pattern | Our Modification | Why |
|--------------------|-----------------|-----|
| Uniform ceremony for all work | Scope-tiered (lightweight/standard/deep) | A 5-line config change doesn't need payment-system ceremony. But it still gets something. |
| Context-based handoff | Disk-only artifacts | Superpowers loses everything on `/compact`. |
| Passive routing (auto-detect from signals) | Active `/letsgo` router, confirms with user | Passive routing misses when signals are ambiguous. |
| No knowledge accumulation | Retros accumulate, research persists, agents check past work | Superpowers' biggest gap — no institutional memory. |
| Plans with exact file paths and complete code | Behavioral goals, no code, trust the implementing agent | Code in plans goes stale the moment you refactor. |
| No research phase | Mandatory agent dispatch | We don't assume the developer knows the codebase. |

### Rejected

- **Visual Companion** (browser mockups) — Scope creep for now
- **"Writing skills with TDD"** meta-skill — Useful for building agentic-kit itself, not for the framework

---

## From CC10X

Cherry-picked specific patterns, rejected the architecture (too complex):

| Adopted Pattern | Original CC10X Form | Our Form |
|----------------|--------------------|----|
| Traffic light confidence | 0-100 numerical with convergence state machine | `[GREEN]` / `[YELLOW]` / `[RED]` — simpler, no false precision |
| DAG dependency rule | Phase contracts with `phase_cursor` | Unit N depends only on prior units, no circular deps |
| Zero-finding halt | Multi-signal review methodology | If reviewer finds zero issues, re-examine (prevents rubber-stamping) |
| Risk assessment | Workflow artifact with remediation history | Probability × Impact matrix, mandatory for standard/deep |
| 3-circuit breaker | Remediation loops with cycle limits | After 3 failed fix attempts → escalate to architectural problem |
| Structural verification | Phase exit criteria with evidence arrays | Stub scan, wiring check, build check |

### Rejected

- **Hook-based Python audit scripts** (11 hook points) — Heavy infrastructure, fragile
- **Workflow UUID artifact as state source** — We use the filesystem
- **Numerical confidence scoring** — False precision
- **Fully automatic routing** — We want human agency

---

## From Matt Pocock

Adopted as principles encoded in our TDD and planning specs:

- **Test behavior through public interfaces** — Never test implementation details
- **Vertical tracer bullets** — First test proves full path end-to-end
- **"Trust the implementing agent"** — Plans describe WHAT, not HOW. No code in plans.
- **Deep modules** — Small interface + deep implementation
- **Never refactor while RED** — If tests fail, you're in GREEN mode
- **Behavioral contracts** — Combined with schema precision in our "durable decisions"
- **One-test-one-implementation cycles** — RED for one behavior → GREEN → next

Nothing rejected — his patterns are principles, not framework. We adopt all of them.

---

## From Everything Claude Code (ECC)

Took agent design patterns, rejected the broader architecture:

- **code-explorer agent** — Forked: file budget (15 files), grep-first narrowing, search protocol, coverage reporting
- **Platform-specific TDD files** — Per-platform testing skills (JS, Python, Go, etc.) forked from ECC's language-specific skills
- **File budget for agents** — 15-file cap prevents reading the entire codebase
- **"Verify claims of absence"** — Agent says "nothing found" → must show grep results
- **Repo-relative paths only** — Absolute paths break portability

### Rejected

- **GAN feedback loop** (Planner→Generator→Evaluator→Iterate) — Designed for creative/design work, not enterprise development
- **50+ specialized reviewers** — Too many. CE's conditional persona approach scales better.
- **Silent-failure-hunter as separate agent** — Should be part of the review system, not standalone

---

## Unique to Agentic-Kit

Patterns we invented because no source solved them:

### 1. Root Cause Categorization

10 enumerated categories in retros: poor user description, incorrect scope/tier, poor brainstorm decisions, stale research/docs, poor CLAUDE.md, poor code patterns/structure, poor test coverage, poor enforcement, poor skill behavior, stale docs. No source tracks WHY things went wrong systematically.

### 2. The Feedback Loop

Retros accumulate → team reviews patterns → decides where fix belongs (codebase, docs, CLAUDE.md, agentic-kit, team process). Bad input doesn't trigger framework changes unilaterally. The team discusses and decides.

### 3. Research as Living Documents

`.docs/research/<topic>.md` — Reusable topic knowledge not tied to any work item. Agents check before doing fresh research, update when they learn something new. CE persists solutions, not research. Superpowers persists nothing.

### 4. EXPLORE as First-Class Workflow

Not build, not fix. Pure research with its own lifecycle (brainstorm→research→retro). No plan needed. No source has this.

### 5. Artifact Traceability Chain

`source_brainstorm` field in plan.md and retro.md. Full chain is machine-traversable via grep.

### 6. Handoff Edge Case Handling

Status gate (reject draft brainstorms) + type filter (skip EXPLORE in /plan discovery) + overflow handling (cap at 5 most recent when 10+ matches). No source handles these edge cases.

### 7. Cross-Platform Contracts Table

Formal brainstorm section: when a backend API changes, which clients consume it? Forced blast-radius consideration across platforms.

### 8. Stack Agnosticism

CE has `rails_model`, `hotwire_turbo`. We have `module` and `tags`. Works regardless of tech stack. Skills and agents never hardcode project-specific systems.

---

## Comparative Summary

| Concern | CE | Superpowers | CC10X | Matt Pocock | ECC | Agentic-Kit |
|---------|-----|-------------|-------|-------------|-----|-------------|
| Entry point | Flexible | Rigid ceremony | Auto-routing | N/A | Flexible | Active router, confirming |
| Scope tiers | Yes, flexible | Uniform | N/A | N/A | N/A | Yes, hard-enforced |
| Research agents | Optional | None | None | None | code-explorer | Mandatory, parallel |
| Artifact handoff | File + context | Context | N/A | N/A | File | File ONLY |
| Anti-anchoring | Strong pattern | Implicit | N/A | N/A | N/A | HARD-GATE |
| TDD | Behavioral tests | RED→GREEN→REFACTOR | Verification | Public interface | Platform-specific | Superpowers + Matt Pocock |
| Knowledge capture | ce:compound (technical) | None | None | None | None | retro (technical + process) |
| Research persistence | None | None | None | None | None | `.docs/research/` living docs |
| Root cause tracking | None | None | None | None | None | 10 categories in retros |
| Code review | 17+ personas | Two-stage | Zero-finding halt | N/A | 50+ reviewers | Planned: CE personas + CC10X halt |
| Debugging | Bug classification | Systematic 4-phase | 12-step | N/A | Build resolvers | Planned: CC10X + Superpowers |
| Stack-specific | Rails enums | No | No | No | Language agents | Stack-agnostic |
