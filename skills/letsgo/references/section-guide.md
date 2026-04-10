# Section Guide: 6-Section Brainstorm Progression

Detailed guidance for each section of the collaborative dialogue (Phase 3). Loaded for standard and deep scope only.

## General Rules

- Walk through sections **in order** — each builds on the previous
- **Interaction Rules from SKILL.md apply throughout** — especially: ask user's thinking first (Rule 4), sycophancy resistance (Rule 6)
- **Lock each section** before moving to the next. Locked = decision made, no revisit unless explicitly unlocked
- **Turn budget** per section is set by scope tier (SKILL.md Phase 2 table). When reached, trigger the overflow protocol below
- For **deep** scope: allow sub-questions within each section

### Section Lock & Unlock

**Lock when:** The user confirms the section's decisions.

**Unlock only when:**
1. User explicitly requests revisiting a locked section
2. A later section's findings invalidate an earlier decision — use the Contradiction Detection protocol
3. Agent research returns information that changes the premise

**When unlocking:** State what changed and which downstream sections need re-evaluation.

**Circuit breaker:** If 3+ sections have been unlocked during this dialogue, the SKILL.md Phase 3 circuit breaker fires. Follow the reassessment protocol there.

### Contradiction Detection Protocol

When working on Section N and you notice a potential conflict with locked Section M:
1. **Name it:** "Section [N] finding X appears to conflict with Section [M] decision Y."
2. **Assess severity:** Hard conflict (cannot both be true) or soft tension (can coexist with clarification)?
3. **Hard conflicts:** Propose unlocking Section M. State what would change.
4. **Soft tensions:** Propose a clarification that resolves without unlocking. User decides.

NEVER silently accommodate a contradiction by weakening a locked decision. That is the most common form of decision erosion.

### Turn Budget Overflow Protocol

When a section reaches its turn budget:
1. Summarize the section's current decisions
2. Identify what remains unresolved
3. Ask: "We've spent [N] exchanges on [section]. (a) Lock with current decisions, (b) extend by 2 more exchanges, (c) flag unresolved items as Open Questions and move on."
4. If extended once, it cannot be extended again — lock or flag.

### Rationalization Prevention

The canonical Rationalization Prevention table is in SKILL.md. Review it before starting the dialogue. During the dialogue, if you catch yourself rationalizing a shortcut, STOP — check the table.

---

## Section 1: Purpose & Context

**Goal:** Shared understanding of what we're building and why.

**Open:** "What's your current thinking about this? What problem are you solving?" Then supplement with agent findings: "Based on my research: [summary]. Is this accurate? What am I missing?"

**Questions to resolve:**
- What user or business problem does this solve?
- What triggered this work? (bug report, feature request, tech debt, opportunity, compliance)
- Is this the right problem, or a proxy for a more important one?
- What happens if we do nothing?
- Are we duplicating something that already exists?

**Failure mode -- Premature Agreement:** User says "yeah, that sounds right" without articulating their own understanding. Detection: user's confirmation is shorter than the agent's proposal. Correction: ask a follow-up requiring new information: "What's the most important thing this changes for the end user?"

**Lock when:** Both sides agree on the problem statement and motivation.

---

## Section 2: Scope & Boundaries

**Goal:** Clear lines around what's in and what's out.

**Present agent-informed scope proposal:** "Based on the codebase, this touches [X, Y, Z]. Here's what I'd include and exclude: [proposal]."

**Questions to resolve:**
- What's explicitly in scope?
- What's explicitly out of scope? (name specific adjacent items excluded)
- Are there adjacent concerns that should be separate work?
- Does the scope tier still feel right?

**Assign requirement IDs:** As each in-scope item is confirmed, assign a stable ID (R1, R2, R3...). These IDs are permanent — they trace forward into success criteria, open questions, and `/plan` implementation units.

**For deep scope:** If work spans multiple independent subsystems, propose decomposition. Each sub-project gets its own `/letsgo` -> `/plan` cycle.

**Failure mode -- Scope Creep via "While We're At It":** User adds adjacent items during scoping. Detection: an in-scope item not in the original feature description that doesn't directly serve Section 1's purpose. Correction: "That's valid but adjacent to the core problem. Add it as in-scope (adjust tier if needed), or note as follow-up?"

**Lock when:** In/out boundaries stated, scope tier confirmed, and R-IDs assigned to all in-scope items.

**After locking Section 2:** Write first mid-dialogue draft to disk (SKILL.md Phase 3 persistence instructions).

---

## Section 3: Affected Systems

**Goal:** Which platforms, services, and contracts are touched, and how.

**Present agent-informed assessment:** "This change affects: [list]. Here's how each is involved: [summary]."

**Systems to evaluate:** Use agent findings from Phase 1. If gaps remain, check CLAUDE.md or MAP.md for the project's system inventory.

**Work through three categories:**

### 3a. Direct Changes
Which systems are directly modified by this work? Present as a table: System | Role in This Change.

### 3b. Cross-Platform Contracts
For each system with direct changes, ask: **"Who consumes this system's output?"**

If a backend API is changing, identify which clients (mobile, frontend, Go service) consume that endpoint. If a mobile data model changes, does the backend need to know? If a shared type changes, which systems break?

Present as: Contract | Producer | Consumer(s) | Impact.

This is the most commonly skipped analysis in multi-platform work. A backend developer changes an API response shape and doesn't realize the Kotlin mobile app parses that exact shape. The framework forces this question.

If no cross-platform contracts are affected, state that explicitly: "Change is contained within [system]."

### 3c. Integration Points
Third-party services, SDKs, or external APIs involved. These have fundamentally different risk profiles — you don't control their versioning, uptime, or behavior.

Present as: Service | How It's Involved | Key Constraints (rate limits, API version, webhook behavior).

If no third-party integrations, state that explicitly.

**Failure mode -- Missing Indirect Dependencies:** Agent research found direct changes but missed downstream consumers. Detection: a system listed as "directly modified" has consumers in other systems not listed. Correction: for each modified system, ask "Who consumes this system's output?"

**Lock when:** All affected systems identified with their role. Cross-platform contracts identified where applicable. Each affected system linked to at least one R-ID.

---

## Section 4: Approaches

**Goal:** Explore solution options and select one.

### Anti-anchoring (HARD GATE G2 -- enforced)

Present ALL approaches first, THEN recommend. The sequence is always: options -> tradeoffs -> recommendation. Gate G2 is non-negotiable.

**Why:** When the AI leads with "I recommend X," the developer evaluates that pick instead of genuinely considering alternatives.

### For Standard/Deep Scope

Present **2-3 approaches** at the architecture level. Per-platform implementation details are deferred to `/plan`.

For each approach:
- Brief description (2-3 sentences)
- Pros and cons
- Key risks or unknowns
- When this approach is the right choice
- Which requirements (R1, R2...) it addresses well vs. poorly

**Mandatory challenge approach:** At least one approach must come from a fundamentally different solution axis:
- Inversion: what if we did the opposite?
- Constraint removal: what if [limitation] weren't a factor?
- Analogy: how does another domain solve this?
- Simplification: what if we did the minimal version that still delivers the core value?

If the chosen approach is "build a new service," the challenge should be "use an existing library" or "extend an existing service" — not "build a slightly different new service."

After ALL approaches are presented, state your recommendation and explain why.

**Call out** whether the chosen approach is reusing an existing pattern, extending an existing capability, or building something net new.

### For Lightweight Scope

Present 1 approach: "Here's what I'd do — any concerns?" Show 2 only if agent research surfaced a competing pattern or the user expressed a conflicting preference.

**Failure mode -- Sham Alternatives:** Approaches B and C are presented as obviously inferior to make A look good. Detection: B and C have only cons and no pros, or their "when best suited" scenario is unrealistic. Correction: every approach must have at least one genuine scenario where it would be the right choice. If you cannot construct one, it is not a real alternative — replace it.

**Lock when:** Approach selected and developer confirms.

**After locking Section 4:** Update mid-dialogue draft on disk with Sections 1-4 and `resume_from: 5`.

---

## Section 5: Key Constraints & Risks

**Goal:** Surface anything that could derail implementation.

**Categories to evaluate:**
- Technical limitations (platform constraints, performance budgets)
- Third-party dependencies (API behavior, webhooks, rate limits, pricing)
- Breaking changes to existing APIs or data contracts
- Data migration concerns (schema changes, backfills)
- Security (auth boundaries, data exposure)
- Cross-platform compatibility (do all consumers handle the change?)
- Deployment concerns (feature flags, rollback, infra changes)

**For each:** State constraint, assess impact, name affected requirements (R1, R2...), propose mitigation if one exists.

**For deep scope, additionally:**
- Data loss scenarios?
- Third-party service downtime impact?
- Regulatory or compliance implications?

**Failure mode -- Optimism Bias:** Constraints are listed but rated as low-impact without justification. Detection: every constraint is rated "low risk" or has a mitigation described as "straightforward." Correction: for each constraint, ask "What's the worst realistic outcome if this mitigation fails?" If the answer is serious, the risk is not low.

**Cross-platform contradiction check:** Review the cross-platform contracts from Section 3 against the chosen approach from Section 4. If the approach changes a contract's shape, does every consumer in the contracts table handle the change? If not, that is a constraint — name it here.

**Lock when:** All material constraints/risks identified. Unmitigated constraints are acceptable if acknowledged.

---

## Section 6: Success Criteria

**Goal:** Define how we know the work is done.

**Questions to resolve:**
- Concrete, testable conditions for "done"?
- User experience after this ships?
- Measurable outcomes (latency, error rate, cost)?
- Edge cases: must-handle vs. out-of-scope?

**Criteria must be:**
- **Concrete** — not "the system performs well" but "webhook processes within 5 seconds"
- **Testable** — verifiable by automated test or specific manual check
- **Complete** — covering all affected systems from Section 3
- **Traceable** — each criterion must reference the R-ID(s) it verifies
- **Prioritized** — must-have vs. nice-to-have when many criteria exist

VIOLATION: "The system handles errors gracefully" — this tells an implementing agent nothing. Replace with: "Failed webhook deliveries retry 3 times with exponential backoff, then write to a dead-letter queue."

**Completeness checks:**
1. Does every R-ID from Section 2 have at least one success criterion? If not, add the missing criteria or explain why that requirement needs no explicit verification.
2. If Section 3 lists cross-platform consumers, does at least one criterion verify consumer behavior? (e.g., "Mobile app correctly parses the updated API response" or "Frontend gracefully handles the new error code.")

**Failure mode -- Criteria That Restate Scope:** Success criteria that just say "R1 is implemented" without defining what "implemented" looks like. Detection: the criterion could be satisfied by a no-op stub. Correction: add observable behavior — what a user or test would see.

**Lock when:** Criteria are specific enough that an implementing agent can verify each one without follow-up questions.
