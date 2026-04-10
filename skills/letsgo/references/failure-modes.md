# Failure Mode Catalog for /letsgo

Every failure mode that can occur during brainstorming, organized by phase. Each entry describes what goes wrong, how to detect it, and how to recover.

## Phase 0: Resume & Route

### F0.1 — Corrupt or Unreadable Draft
**What:** A prior brainstorm.md exists but has corrupt YAML frontmatter, missing sections, or garbled content (from a crash during write).
**Detection:** YAML parse failure, missing `status` field, or sections that end mid-sentence.
**Recovery:** Warn the user: "Found a brainstorm at [path] but it appears incomplete or corrupt. Start fresh, or attempt to salvage what's readable?" If salvaging, read what exists, summarize it, and resume from the last complete section.

### F0.2 — Ambiguous Match
**What:** Multiple existing brainstorms match the feature description keywords.
**Detection:** Grep returns hits in 2+ brainstorm.md files.
**Recovery:** List matches with their titles and dates. Ask the user to pick one or confirm this is new work.

### F0.3 — Stale Draft (draft status but old date)
**What:** A draft brainstorm exists from weeks ago — the conversation context is long gone.
**Detection:** `status: draft` with a date more than 7 days old.
**Recovery:** "Found a draft brainstorm from [date]. The conversation context is gone. Review what exists and continue, or start fresh?"

## Phase 1: Research

### F1.1 — Single Agent Failure
**What:** One research agent returns empty, errors out, or times out.
**Detection:** Agent output is empty, contains an error message, or doesn't arrive.
**Recovery:** Note the gap explicitly in the conversation. Warn the user which context is missing. Proceed with the remaining agent's findings. Do not fabricate findings to fill the gap.

### F1.2 — Both Agents Fail
**What:** Neither agent returns useful results.
**Detection:** Both outputs are empty or error states.
**Recovery:** Ask the user: "Both research agents returned empty. (a) Proceed with dialogue only — you'll need to provide more context, (b) retry with different search terms, or (c) abort and investigate why agents aren't working."

### F1.3 — Agent Hallucination
**What:** An agent reports finding code or documentation that doesn't actually exist.
**Detection:** Hard to detect during brainstorming. Most often caught when the user says "that file doesn't exist" or when /plan can't find referenced code.
**Recovery:** The brainstorm template's Research Context section requires naming specific files and search terms. If /plan discovers a hallucinated finding, it should flag it and return to /letsgo for correction.

### F1.4 — Overly Broad Agent Results
**What:** Agents return 15 files of tangentially related code, burying the actually relevant findings.
**Detection:** Agent findings are long but don't answer the dispatch prompt's specific questions.
**Recovery:** Summarize the actually relevant subset and note: "Agent research was broad — I've focused on the findings directly relevant to [feature]. Full agent output available if needed."

## Phase 2: Scope Assessment

### F2.1 — Scope Misclassification
**What:** The agent classifies work as lightweight when it's actually standard/deep, or vice versa.
**Detection:** User overrides the proposed tier. Or: during Phase 3, the section dialogue consistently exceeds turn budgets, suggesting the work is more complex than classified.
**Recovery:** If user overrides: accept immediately. If detected during Phase 3: propose reclassification — "This is taking more exploration than a [tier] task. Upgrade to [higher tier]?"

### F2.2 — Slug Collision
**What:** The generated slug already exists as a folder in .docs/plans/.
**Detection:** Glob check when creating the folder.
**Recovery:** Append a numeric suffix (e.g., `250410-stripe-webhooks-2`) and inform the user.

## Phase 3: Collaborative Dialogue

### F3.1 — Sycophantic Collapse
**What:** The agent agrees with every user input without pushback, producing a brainstorm that reflects the user's initial assumptions without challenge.
**Detection:** Self-test from Interaction Rule 6: the agent has not disagreed or challenged anything in 4+ consecutive exchanges. Every section was confirmed in 1 exchange.
**Recovery:** Before locking the next section, deliberately probe: "I want to challenge one thing before we move on — [specific concern]." If you genuinely have no concerns, that's fine. But if you skipped concerns to keep things moving, voice them now.

### F3.2 — Scope Creep via Dialogue
**What:** In-scope items expand during the dialogue beyond what was locked in Section 2.
**Detection:** A section references work items not present in the locked Section 2 scope. The turn budget is consistently exceeded across multiple sections.
**Recovery:** Name the creep: "This adds [X] to scope beyond what we locked in Section 2. Should I unlock Section 2 to add it, or note it as follow-up work?"

### F3.3 — Decision Erosion (Retroactive Weakening)
**What:** A later section silently softens or narrows a decision from an earlier locked section.
**Detection:** The Contradiction Detection Protocol in section-guide.md catches hard conflicts. Soft erosion is harder — watch for qualifiers ("mostly", "where feasible", "when possible") appearing in later sections that weaken absolute commitments from earlier ones.
**Recovery:** Name it explicitly. "Section 5 says [qualified version] but Section 2 committed to [absolute version]. Which is correct?"

### F3.4 — Cascading Unlock Instability
**What:** Multiple sections keep getting unlocked as new information surfaces, and the brainstorm never converges.
**Detection:** Circuit breaker: 3+ sections unlocked during this dialogue.
**Recovery:** STOP section progression. The underlying cause is usually one of: (a) the feature description was too vague — return to Purpose, (b) the scope is too broad — narrow it, (c) the user is discovering requirements in real-time — this is normal for deep scope, but may need decomposition.

### F3.5 — Session Crash or /compact Mid-Dialogue
**What:** The conversation is lost partway through the 6-section dialogue.
**Detection:** On next invocation, Phase 0.1 finds a draft with `status: draft` and `resume_from: N`.
**Recovery:** The mid-dialogue draft preserves Sections 1 through (N-1). Resume from Section N. The user should verify the draft's decisions still hold, since they may have had additional thoughts since the crash.

### F3.6 — Contradictory User Input
**What:** The user confirms a decision in Section 2 and then states something contradictory in Section 4.
**Detection:** Contradiction Detection Protocol in section-guide.md.
**Recovery:** Name the contradiction. Do not silently accommodate it. Ask the user which statement represents their actual intent. Unlock the earlier section if needed.

## Phase 4: Review

### F4.1 — Subagent Review Failure
**What:** The brainstorm-reviewer agent errors, times out, or returns empty.
**Detection:** Agent output is empty or error state.
**Recovery:** Fall back to inline self-review. Note: "Independent review unavailable — ran inline review only." This is a degraded mode, not a skip.

### F4.2 — Review Finds Critical Issues
**What:** The reviewer returns a FAIL verdict with Critical findings.
**Detection:** Structured output contains `## Verdict: FAIL`.
**Recovery:** Present the Critical findings to the user. For each: propose a fix, apply it to the draft, then re-run review. If 3 review cycles fail, surface to the user: "The brainstorm has persistent issues I can't resolve automatically: [list]. Would you like to address these manually?"

### F4.3 — Review Rubber-Stamp (False Pass)
**What:** The reviewer returns PASS but the brainstorm clearly has issues (e.g., the user spots problems after approval).
**Detection:** User flags issues during Phase 5.5 review gate.
**Recovery:** The user review gate (Phase 5.5) is the safety net. Incorporate user feedback, re-run Phase 4 review, and overwrite the artifact.

## Phase 5: Output Artifact

### F5.1 — Write Failure
**What:** The file write fails (disk full, permission error, path doesn't exist).
**Detection:** Write tool returns an error.
**Recovery:** Create the directory structure first (mkdir -p). Retry the write. If it still fails, present the brainstorm content in the conversation and instruct the user to save it manually.

### F5.2 — Template Drift
**What:** The artifact doesn't match the template structure because the agent wrote from memory instead of reading the template.
**Detection:** Rationalization Prevention RP6. Also caught by the brainstorm-reviewer in Check 4 (Completeness).
**Recovery:** Read the template. Rewrite the artifact. This is why RP6 exists — "write from decisions, not memory" means reading the template every time.

## Phase 6: Handoff

### F6.1 — Missing Artifact at Handoff
**What:** Phase 6 begins but brainstorm.md doesn't exist on disk.
**Detection:** Gate G4 requires Glob verification before entering Phase 6.
**Recovery:** STOP. Write the artifact (Phase 5). Then enter Phase 6.

### F6.2 — /plan Discovers Brainstorm is Insufficient
**What:** After handoff, /plan reads the brainstorm and finds it can't proceed — missing decisions, ambiguous scope, or unresolved blocking questions.
**Detection:** /plan raises a "brainstorm insufficient" error or asks questions the brainstorm should have answered.
**Recovery:** /plan redirects back to /letsgo with specific questions. /letsgo resumes from Phase 0.1 (finds the existing brainstorm), unlocks the relevant sections, resolves the issues, re-runs review, and overwrites the artifact.

---

## Cross-Phase Failure Modes

### FC.1 — Context Window Exhaustion
**What:** The conversation grows so long that the model starts losing earlier context.
**Detection:** The model starts contradicting its own earlier statements. Section decisions don't align with each other.
**Recovery:** The mid-dialogue draft persistence mechanism is the primary defense. If you notice degradation: write the current draft to disk immediately, then suggest the user `/compact` and resume. The draft preserves all locked decisions.

### FC.2 — User Disengagement
**What:** The user stops providing substantive input — "sure", "yeah", "whatever you think" on every question.
**Detection:** 3+ consecutive single-word confirmations with no pushback or additions.
**Recovery:** Pause and check: "You've agreed with everything so far. Is this matching your vision, or would you prefer to skip ahead? I want to make sure we're building the right thing, not just going through the motions."

### FC.3 — Agent-User Alignment Failure
**What:** The agent and user are talking past each other — using the same words to mean different things.
**Detection:** Frequent unlocks, contradictory confirmations, or the user saying "that's not what I meant" repeatedly.
**Recovery:** Stop the section progression. Summarize your understanding of the entire feature in 3-4 sentences. Ask: "Is this what we're building? If not, where does it diverge?"
