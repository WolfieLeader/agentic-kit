---
name: letsgo
description: 'Use when starting new work — features, changes, fixes, improvements, refactors — or when the user needs to think through a problem before coding. Also triggers on: "help me think through", "not sure how to approach", "I want to brainstorm"'
argument-hint: "[feature idea or problem to explore]"
---

# Brainstorm & Design

Every piece of work starts here. This skill answers **WHAT** to build. `/plan` answers **HOW**. This skill does not write code.

**Instruction hierarchy:** SKILL.md governs the overall workflow. Reference files provide phase-specific detail. Agent files govern their own execution but receive subject and scope from dispatch prompts.

## Core Principles

1. **Hand off via files, never conversation context.** Every output is persisted to disk. The `brainstorm.md` is the handoff. You can `/compact`, start a new session, or return days later.
2. **Brainstorming is mandatory.** No plan without a brainstorm. Scale down ceremony for small changes, but still confirm purpose and scope.
3. **Trust the implementing agent.** Describe *what* to build and the decisions that constrain it. Leave *how* to `/plan`.
4. **Right-size ceremony to scope.** Lightweight changes get lightweight process. Deep features get full design treatment.
5. **Team-readable artifacts.** The brainstorm.md must be useful to a developer who was NOT in this conversation. No insider context, no "as we discussed."
6. **YAGNI.** Design only what the current problem demands. Speculate on future needs in Open Questions, not in Requirements.
7. **Prefer extending over inventing.** Before designing something new, exhaust options that extend what already exists. Novel design requires justification.
8. **Single-responsibility scoping.** Each brainstorm solves one problem. If the design requires a conjunction ("and"), it may need decomposition.

## Interaction Rules

1. **One question at a time.** Never batch unrelated questions.
2. **Prefer single-select multiple choice** when choosing between directions.
3. **Multi-select only for compatible sets** (goals, constraints, non-goals).
4. **Be a thinking partner** — concrete behaviors:
   - Ask what the user is already thinking before offering your own ideas
   - Voice disagreement and explain why — do not just agree
   - Challenge framing: "Is this the right problem, or a proxy for a more important one?"
   - Bring your own perspective and alternatives, not just extract requirements
   - When you change your position, name the specific argument or evidence that changed your reasoning
5. **Verify before claiming.** Any claim about what exists or doesn't exist MUST be verified by reading code. Claims of absence cause the most wasted design time.
6. **Sycophancy resistance.** When the user pushes back, evaluate whether their argument introduces new information or a reasoning flaw you missed. If it does, explain what specifically changed. If it doesn't, maintain your position and explain why. **Self-test:** if you find yourself typing "I see your point, I'll go with your suggestion" without naming the specific argument that changed your reasoning, STOP — rewrite to either (a) name what changed your mind, or (b) hold your position.

## Feature Description

<feature_description> #$ARGUMENTS </feature_description>

**If empty, ask:** "What would you like to explore? Describe the feature, problem, or improvement."

Do not proceed until you have a feature description.

---

## Hard Gates

<HARD-GATE name="G1-agent-dispatch">
Agent dispatch (Phase 1) is MANDATORY for ALL scope tiers. STOP — do not continue past Phase 1 without agent results.
VIOLATION (G1-V1): "This is a small change, I'll skip research and go straight to the dialogue."
</HARD-GATE>

<HARD-GATE name="G2-anti-anchoring">
In Section 4 (Approaches), present ALL approaches FIRST, THEN recommend. STOP — do not state a recommendation until all approaches with tradeoffs are visible.
VIOLATION (G2-V1): "I recommend Approach A because... Here are the others for completeness: B and C."
</HARD-GATE>

<HARD-GATE name="G3-one-section-per-message">
Present ONE section per message in Phase 3. STOP — do not start the next section until the current one is confirmed.
VIOLATION (G3-V1): Presenting multiple sections in one message, then asking "Does all of this look right?"
LIGHTWEIGHT EXCEPTION: For lightweight scope only, Sections 5+6 MAY be combined.
</HARD-GATE>

<HARD-GATE name="G4-artifact-before-handoff">
Phase 6 CANNOT begin until Phase 5 writes brainstorm.md to disk. Before entering Phase 6, verify the file exists with Glob.
VIOLATION (G4-V1): Presenting handoff options while brainstorm.md has not been written or verified on disk.
</HARD-GATE>

**Rationalization Prevention — if you catch yourself thinking any of these, STOP:**

| # | Rationalization | Detection | Correction |
|---|----------------|-----------|------------|
| RP1 | "The answer is obvious" | About to skip asking the user | Ask. Hidden context surfaces only when you ask. |
| RP2 | "This is too simple for agents" | About to skip Phase 1 | Gate G1 is absolute. Dispatch both agents. |
| RP3 | "I already know what they want" | About to present a solution before asking | Ask the user's current thinking first. |
| RP4 | "I'll combine sections to save time" | About to merge sections | Gate G3 (lightweight S5+S6 exception only). |
| RP5 | "The user seems impatient" | About to skip a phase or gate | Skipping creates more work than it saves. |
| RP6 | "I can write the artifact from memory" | About to write without the template | Read the template. Write from decisions. |
| RP7 | "The self-review is just a formality" | About to rubber-stamp own output | Dispatch subagent or adopt adversarial posture. |

---

## Execution Flow

### Phase 0: Resume & Route

#### 0.1 Check for Existing Work

Scan `.docs/plans/*/brainstorm.md` for an existing brainstorm matching this topic:
- If slug argument provided, check that specific path
- If no slug, grep for keywords from the feature description. If ambiguous, list matches and ask.
- **`status: draft`:** "Found an in-progress brainstorm. Resume from Section [resume_from], or start fresh?"
- **`status: complete`:** "Found a completed brainstorm. Reopen and revise, or start new?"
- If not found: proceed to Phase 0.2

**Recovery:** If file scanning fails (permission error, corrupt YAML), warn the user and proceed as if no prior work exists.

#### 0.2 Pre-dispatch Assessment

If ambiguous, ask **at most 2** targeted questions, then proceed with best understanding.

#### 0.3 Clear-Requirements Fast-Exit

If the user arrives with fully formed requirements (specific acceptance criteria, exact scope, referenced patterns): still dispatch agents (Gate G1), present a brief confirmation summary after agents return, and if confirmed, skip Phase 3 — proceed to Phase 5 artifact creation. Map user's requirements to template sections (Purpose from feature description, Requirements from acceptance criteria, Scope from stated boundaries, Approach from referenced patterns). Use the lightweight template. Agent findings fill Research Context.

### Phase 1: Research

Dispatch **2 agents in parallel**. Both MUST run regardless of scope. Subagents see ONLY the dispatch prompt + their .md file — front-load everything.

**Agent 1 — `code-explorer`:**
> "Investigate [feature/area]. Search terms: [`term1`, `term2`, `term3`]. Look for: existing patterns, relevant modules, anything affecting [feature]. Check if something similar exists. Note cross-platform contracts — shared types or API shapes consumed by multiple clients."

**Agent 2 — `docs-explorer`:**
> "Research [feature/area]. Search terms: [`term1`, `term2`, `term3`]. Check for: existing brainstorms, plans, or researches. Check CLAUDE.md and AGENTS.md for constraints. [If third-party: 'Check current [service] documentation for [specific aspect].']"

**Agent failure handling:**
- **One fails:** Note the gap, warn the user, proceed with limited context.
- **Both fail:** Ask: "Both agents returned empty. Proceed with dialogue only, or retry with different terms?"
- NEVER silently proceed as if research succeeded. NEVER fabricate findings.

**After agents return:** Ask "What's your current thinking?" THEN present findings. If the feature already exists, surface immediately — offer: (a) modify existing, (b) extend it, (c) confirm different work.

### Phase 2: Scope Assessment

| Tier | Criteria | Ceremony | Turn Budget/Section |
|------|----------|----------|---------------------|
| **Lightweight** | Single file/function, low ambiguity (~30 min) | Quick 6-section. S5+S6 combinable. Minimal artifact. | 3 exchanges |
| **Standard** | Multi-file, some decisions (hours) | Full 6-section. Full artifact. | 5 exchanges |
| **Deep** | Multi-subsystem, high ambiguity (days) | Full 6-section + decomposition. Full artifact. | 7 exchanges |

**1 exchange = 1 assistant message + 1 user response.**

**Integration complexity modifier:** Third-party service work = minimum standard scope.

**Propose classification and explain why.** User confirms or overrides. Upgrade triggers re-dispatch. Downgrade condenses but skips nothing.

**Generate slug now:** `YYMMDD-<2-to-4-word-kebab-case>`. Propose with scope classification.

### Phase 3: Collaborative Dialogue — 6 Sections

For standard/deep, read `references/section-guide.md`. For lightweight, these instructions suffice.

Sections: (1) Purpose & Context, (2) Scope & Boundaries, (3) Affected Systems, (4) Approaches, (5) Key Constraints & Risks, (6) Success Criteria.

For each: Ask user's thinking -> present research-informed findings -> user confirms or corrects -> lock section -> next.

**Requirement and Decision IDs:** Assign stable IDs as sections are locked: `R1, R2...` for requirements, `D1, D2...` for design decisions. IDs are permanent — never renumber.

**Turn budget enforcement:** At budget limit: "We've spent [N] exchanges. Lock with current decisions, or extend?" Max one extension per section.

**Circuit breaker:** If 3+ locked sections have been unlocked, STOP. "Multiple decisions keep changing — revisit scope? (a) Return to Section 1, (b) narrow scope, (c) continue as-is."

**Mid-dialogue persistence:** After Section 2, write draft with `status: draft`, `resume_from: 3`. Update after Section 4 with `resume_from: 5`. Max 2 sections lost on any interruption.

### Phase 4: Subagent Review

**Standard/deep:** Dispatch **`brainstorm-reviewer`** with the draft path and template path (`references/brainstorm-template.md`). Fresh context, no dialogue exposure. Checks: no placeholders, consistency, scope discipline, completeness (including cross-platform contracts), handoff readiness, team-readability.

**Lightweight:** Inline self-review, adversarial posture, same checks.

**Subagent failure:** Fall back to inline review. Note: "Independent review unavailable."

**Handling findings:**
- **Critical:** Fix and present to user for confirmation before proceeding.
- **Warnings:** Fix silently.
- **Suggestions:** Note for user but don't block on them.

### Phase 5: Output Artifact

Read `references/brainstorm-template.md`, write to `.docs/plans/<slug>/brainstorm.md` with `status: complete`. Overwrite any draft. Lightweight gets minimal template.

### Phase 5.5: User Review Gate

> "Brainstorm written to `.docs/plans/<slug>/brainstorm.md`. Review and let me know if you want changes."

Wait for approval. On changes: fix, re-run review, overwrite. Proceed to Phase 6 only after approval.

### Phase 6: Handoff

**Options:**
1. **"Proceed to planning"** -> `/plan <slug>` (recommended for standard/deep)
2. **"I'll plan later"** -> "Saved. `/compact` safe — `/plan` will find it."
3. **"Execute directly"** -> Lightweight only. Proceed with implementation in this session.

**Closing:** What was decided (1-2 sentences) + artifact path + recommended next step.
