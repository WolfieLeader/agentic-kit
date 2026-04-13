# Agent Dispatch Pattern

How to compose Agent tool calls with framework agent files. Referenced by
every skill that dispatches subagents.

## The Pattern

1. **Read** the agent's .md file to get its instructions
2. **Compose** a prompt that includes: the agent instructions, the input
   fields the agent expects, and the specific context for this dispatch
3. **Call** `Agent(subagent_type, prompt)` with the composed prompt

## Concrete Example: Dispatching code-explorer

```
# Step 1: Read the agent file
Read("agents/code-explorer.md")

# Step 2: Compose the prompt — agent instructions + inputs
Agent(
  subagent_type: "general-purpose",
  prompt: """
  You are a code explorer. Follow these instructions:

  [paste agents/code-explorer.md content here]

  ## Your inputs for this dispatch:
  - task_summary: "Find how auth tokens are refreshed and where the refresh
    endpoint is called"
  - search_terms: ["refreshToken", "token_refresh", "/auth/refresh"]
  - scope: "src/auth/, src/api/middleware/"
  """
)
```

## Agent Type Selection

| Agent file | subagent_type | Why |
|---|---|---|
| agents/code-explorer.md | `"general-purpose"` | Needs Bash, Read, Grep, git |
| agents/docs-explorer.md | `"general-purpose"` | Needs Read, Grep for .docs/ |
| agents/blueprint-reviewer.md | `"general-purpose"` | Needs Read for source files |
| agents/code-reviewer.md | `"general-purpose"` | Needs Read, Grep, 25-file budget |

All framework agents use `"general-purpose"` because they need full tool access.

**Do NOT use:**
- `"Explore"` — built-in fast agent, grep/glob only, no Bash/Read, no custom instructions
- `"feature-dev:code-explorer"` — marketplace plugin, different output format

## Input Fields

Each agent file has an `## Inputs` section defining what it expects. Map your
dispatch context to those fields:

| Agent | Required inputs |
|---|---|
| code-explorer | `task_summary`, `search_terms`, `scope` (optional) |
| docs-explorer | `task_summary`, `search_terms`, `topic` |
| blueprint-reviewer | `blueprint` (path), `sketch` (path), `exploration_results` (optional) |
| code-reviewer | `diff`, `sketch` (optional), `blueprint` (optional) |

## Parallel vs Sequential

- **Parallel**: code-explorer + docs-explorer (independent, no shared state)
- **Sequential**: craft units (dependency DAG ordering)
- **Single**: blueprint-reviewer, code-reviewer (one agent, full scope)

## Extension Agents

Extension agents follow the same pattern. Read the extension manifest
(`.docs/extensions/<phase>.md`), locate each agent file, dispatch using the
same compose-and-call pattern. Extension agents have the same output contract
as their phase requires (see `extensions/references/registry.md`).

## Common Mistakes

- Passing the agent file path instead of its content — the subagent can't
  read paths outside its prompt without an explicit Read call
- Using `"Explore"` for framework agents — wrong tool access, wrong output format
- Forgetting to include the specific inputs the agent expects — agent gets
  instructions but no context for what to investigate
- Dispatching without directed context — "explore the codebase" produces
  unfocused results; "find how auth tokens are refreshed in src/auth/" works
