# References

Platform compatibility, installation methods, and ecosystem tools for SKILL.md-based plugins.

## Platform Compatibility

### Tier 1 — Native SKILL.md Support

These tools read SKILL.md files directly with no conversion needed.

| Tool                 | Type          | Skills | Hooks/Agents/Commands |
| -------------------- | ------------- | ------ | --------------------- |
| Claude Code          | CLI + IDE     | Native | Full plugin system    |
| OpenAI Codex CLI     | CLI + Desktop | Native | Own system            |
| Gemini CLI           | CLI           | Native | Extensions            |
| GitHub Copilot       | VS Code       | Native | —                     |
| Kiro (AWS)           | IDE           | Native | Specs system          |
| Antigravity (Google) | IDE           | Native | —                     |
| OpenCode             | CLI           | Native | JS plugins            |

### Tier 2 — Needs Conversion

These tools require SKILL.md to be converted to their native format.

| Tool     | Converts to    |
| -------- | -------------- |
| Cursor   | `.mdc` rules   |
| Windsurf | `.md` rules    |
| Cline    | Plain markdown |
| Roo      | Plain markdown |
| Trae     | Plain markdown |

Use `npx skills install` to auto-convert (see [Ecosystem Tools](#ecosystem-tools)).

### Other

| Tool     | Extension method       |
| -------- | ---------------------- |
| Aider    | Convention files       |
| Amp      | Composable tool system |
| Grok CLI | MCP servers            |

## Platform Registration

How each platform discovers and loads plugins.

### Claude Code

- Manifest: `.claude-plugin/plugin.json`
- Auto-discovers `skills/`, `agents/`, `hooks/`, `commands/` directories
- Full component support: skills, agents, hooks, commands, MCP servers
- Install: `claude plugin add ./plugins/scaffolding` or `claude plugin add github:WolfieLeader/agentic-kit/plugins/scaffolding`

### Cursor

- Manifest: `.cursor-plugin/plugin.json`
- Explicit paths in manifest
- Supports skills, agents, hooks, commands

### Gemini CLI

- Skills in `.gemini/skills/` or `.agents/skills/` directories
- Three tiers: Workspace > User > Extension (precedence order)
- At session start, scans all tiers and injects name+description into system prompt
- When a task matches a skill description, calls `activate_skill` tool
- Install via symlink: `ln -s ./plugins/scaffolding/skills ~/.agents/skills/scaffolding`

### OpenAI Codex CLI

- Skills in `~/.agents/skills/` directory
- Install via symlink: `ln -s ./plugins/scaffolding/skills ~/.agents/skills/scaffolding`

### OpenCode

- Plugins in `.opencode/plugins/*.js` (JS modules)
- System prompt injection for skill content
- Tool mapping: `TodoWrite` → `update_plan`

### Grok CLI

- Extensions via MCP servers (primary extension mechanism)
- Supports up to 400 tool execution rounds for multi-step tasks

## Installation Methods

### Direct (Claude Code)

```bash
# Local plugin
claude plugin add ./plugins/scaffolding

# From GitHub
claude plugin add github:WolfieLeader/agentic-kit/plugins/scaffolding
```

### Symlink (Gemini CLI, Codex)

```bash
# Link skills into the shared skills directory
ln -s ./plugins/scaffolding/skills ~/.agents/skills/scaffolding
```

### Auto-Convert (any platform)

```bash
# Vercel Skills CLI auto-converts SKILL.md for the target platform
npx skills install ./plugins/scaffolding/skills/node-project
```

## Tool Name Mappings

Most platforms use the same tool names. Known differences:

| Standard Name | OpenCode      |
| ------------- | ------------- |
| `TodoWrite`   | `update_plan` |

## Ecosystem Tools

| Tool                | Description                              | Link                                                  |
| ------------------- | ---------------------------------------- | ----------------------------------------------------- |
| Vercel Skills CLI   | Auto-converts SKILL.md for any platform  | https://github.com/vercel-labs/skills                 |
| skillport           | Skill conversion tool                    | (not yet public)                                      |
| SkillsMP            | Skills marketplace                       | (not yet public)                                      |
| Agent Skill Creator | Create skills for 14+ tools              | https://github.com/FrancyJGLisboa/agent-skill-creator |
| Agent Skills Spec   | Universal specification for agent skills | https://agentskills.io/specification                  |

## Official Documentation

| Platform     | Docs                                              |
| ------------ | ------------------------------------------------- |
| Gemini CLI   | https://geminicli.com/docs/cli/skills/            |
| OpenAI Codex | https://developers.openai.com/codex/skills/       |
| Windsurf     | https://docs.windsurf.com/windsurf/cascade/skills |

## Reference Implementations

The superpowers plugin is the largest official Claude Code plugin (16+ skills). It uses multi-adapter directories for maximum cross-platform reach:

- `.claude-plugin/` — with `plugin.json` and `marketplace.json`
- `.codex/` — with `INSTALL.md`
- `.cursor-plugin/` — with `plugin.json`
- `.opencode/` — with `plugins/superpowers.js` and `INSTALL.md`

**This monorepo intentionally avoids that complexity.** We use `.claude-plugin/` only and rely on the Vercel Skills CLI for conversion to other platforms when needed.

## Further Reading

- [Tembo: 15 CLI Tools Compared](https://www.tembo.io/blog/coding-cli-tools-comparison) — comprehensive comparison of AI coding CLI tools
