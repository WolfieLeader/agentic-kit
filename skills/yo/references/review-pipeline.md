# REVIEW Pipeline Reference

REVIEW composes existing pieces -- no new skill needed.

## Procedure

1. **Scope** -- determine what to review (module path, PR number, file list).
2. **Explore** -- dispatch framework explorers (see Pass 5 disambiguation in
   the main skill) for context. For umbrella projects, include
   **inter-service communication paths** as an explicit exploration dimension:
   HTTP clients, shared contracts, message queues between repos.
3. **Review** -- dispatch the code-reviewer agent with exploration findings +
   diff/scope as its input bundle.
4. **Persist** -- write the review artifact to `wiki/reviews/<slug>.md` with
   YAML frontmatter (module, tags, date, finding counts by severity).
5. **Present** -- show findings to user. Offer transition to FIX if actionable
   bugs were found.

## Input patterns

- **PR review**: `gh pr diff <number>` -> pass the diff as input to code-reviewer.
- **Module review**: explorers provide the context, code-reviewer reviews the code.

## Phase handoff checkpoints in REVIEW

REVIEW still honors the Pass 6 step 20 handoff checkpoint -- after Explore,
after Review, and after Persist. Silence is not consent; auto-advance only if
the user opted into "run it all" at dispatch. The checkpoint is what keeps the
orchestrator's context from accumulating review findings, diff text, and
persistence output simultaneously.
