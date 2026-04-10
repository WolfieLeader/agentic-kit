# Source Repositories & Research

## Overview

I am a part of a new startup with small team, our product is a mobile app that we need to develop as fast as possible. Our current project structure and tech stack is the following:

- Project
  - Mobile - Kotlin/Compose Multiplatform
  - Backend - TypeScript + Fastify
  - Frontend - TypeScript + React
  - Backend for cryptography operations - Go
  - Infra - Docker, Kubernetes, Terraform, AWS

(3rd party services we use: PostgreSQL, Valkey, Stripe Pay-in + Borderless Pay-out + Supabase Auth + Firebase Crashlitics + Veriff KYC + Crisp Support + OneSignal + Singular + MixPanel + DataDog)

I need to come up with a framework / workflow / methodology to develop efficiently, in parallel (git worktrees), faster, with much more confidence, and better software overall.

## GitHub Repositories Which are Inside this Project

### Superpowers (Heart — automatic entry)

Battle-tested, official Claude Code marketplace plugin. Skill-chain architecture — each skill names the next via `REQUIRED SUB-SKILL`.

**Feature flow:**
Brainstorming → Writing Plans → Using Git Worktrees → Subagent-Driven Development → Finishing Branch

**Per-task loop (inside Subagent-Driven Development):**
Dispatch Implementer (fresh context, TDD: RED→GREEN→REFACTOR, commit) → Spec Reviewer (matches requirements?) → Code Quality Reviewer (well-built?) → if issues: re-implement → re-review → mark done → next task → after all tasks: Final Code Reviewer

**Bug fix flow:**
Systematic Debugging (root cause → pattern analysis → hypothesis → TDD fix) — simple bugs skip straight to TDD

**Parallelism:** Multi-feature via worktrees (one session per worktree). Tasks within a plan are strictly sequential with review between each (prevents context pollution).

### Compound Engineering (Add-on — manual entry)

Manual phase transitions. Artifacts in `docs/` are the glue between phases. Unique value: **compound knowledge loop** — every solution gets documented so the team gets smarter over time.

**Feature flow:**
`/ce:ideate` (optional) → `/ce:brainstorm` → `/ce:plan` (parallel research agents) → `/ce:work` (offers worktree, chooses inline/serial/parallel subagents) → `/ce:review` (automatic, parallel conditional reviewer personas: correctness + testing + maintainability always, security/performance/API-contract/data-migrations when relevant) → `/ce:compound` (document solution to `docs/solutions/`)

**Bug fix flow:**
No dedicated debugging skill. `/ce:work` with bug context (assesses complexity → direct fix or plan first) → auto review → `/ce:compound` to capture solution

**Parallelism:** Multi-feature via worktrees (worktree-manager.sh). Also parallel subagents for independent tasks within a single plan, and parallel reviewer personas in ce:review.

### CC10X (Reference — automatic router) - Created by a friend of mine

Full router-based orchestration. Router owns all state, agents return structured CONTRACT YAML, fail-closed validation.

**Feature flow (BUILD):**
Router detects intent → memory load (.claude/cc10x/v10/) → scope assessment (trivial→build, complex→plan first) → create task graph: `component-builder` (TDD with exit code evidence) → [`code-reviewer` ∥ `silent-failure-hunter`] (parallel, read-only) → `integration-verifier` → `memory-finalize` (inline). Remediation loop with circuit breaker (max 3 REM-FIX before asking user).

**Bug fix flow (DEBUG):**
Router detects ERROR keywords → `bug-investigator` (12 mandatory steps: symptom → git history → logs → variant scan → hypothesis H1/H2/H3 → RED → GREEN → blast radius scan → verify → prevention) → `code-reviewer` → `integration-verifier` → `memory-finalize`

**Parallelism:** No worktree management. Parallelism is within-workflow only (reviewer ∥ hunter). Notable ideas: variant scan (prevents hardcoded fixes), blast radius scan (catches duplicate bug patterns), structured contracts.

### Everything Claude Code (Toolkit library)

181 skills, 46 agents, 89 rules across 12+ languages. Cherry-pick for our stack: `kotlin-patterns`, `compose-multiplatform-patterns`, `frontend-patterns`, `backend-patterns`, `docker-patterns`, `api-design`, `database-migrations`, `security-review`, `deployment-patterns`. Language-specific reviewers: `typescript-reviewer`, `kotlin-reviewer`. Hooks: `block-no-verify`, `commit-quality`, `quality-gate`, `format-typecheck`.

### Matt Pocock's Skills (Design philosophy)

17 opinionated skills focused on software design. Key ideas to adopt: **deep modules** (small interface, rich implementation — Ousterhout), **vertical slicing** (thin end-to-end slices, not horizontal layers), **PRD→Issues pipeline** with durable descriptions (no file paths in issues, describe behavior/contracts), **DDD ubiquitous language** extraction, **design-an-interface** (parallel competing approaches), **grill-me** (relentless interview until shared understanding).
