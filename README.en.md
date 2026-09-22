# my-agent-plugins

[日本語版](README.md)

A personal repository that consolidates configuration shared between Cursor, Codex, and Claude Code, following the [Agent Plugins specification 1.0.0](https://agent-plugins.org/) ([agentplugins/agent-plugins-spec](https://github.com/agentplugins/agent-plugins-spec)).

Agent Plugins v1 defines exactly two portable component types: **skills ([Agent Skills specification](https://agentskills.io/specification))** and **MCP servers (`mcp.json`)**. Rules, hooks, and commands remain client-specific (extension namespaces), and this repository follows the same boundary.

## Layout

```text
my-agent-plugins/
├── AGENTS.md                   # Instructions for agents editing this repository
├── .cursor-plugin/
│   └── marketplace.json        # Marketplace manifest for Cursor
├── .claude-plugin/
│   └── marketplace.json        # Marketplace manifest for Claude Code
├── .agents/
│   └── plugins/
│       └── marketplace.json    # Marketplace manifest for Codex
└── plugins/
    ├── development-rules/      # Shared Git development rules and evidence-driven verification
    │   ├── plugin.json
    │   ├── .cursor-plugin/plugin.json
    │   ├── .codex-plugin/plugin.json
    │   ├── .claude-plugin/plugin.json
    │   └── skills/
    │       ├── git-development-rules/
    │       └── evidence-driven-engineering/   # details and evaluation examples in references/
    ├── frontend-ui-development/ # GUI/UI development guardrails
    │   ├── plugin.json
    │   ├── .cursor-plugin/plugin.json
    │   ├── .codex-plugin/plugin.json
    │   ├── .claude-plugin/plugin.json
    │   ├── rules/frontend-ui-guardrails.mdc   # Cursor-specific persistent rule
    │   └── skills/frontend-ui-development/
    │       ├── SKILL.md
    │       └── assets/AGENTS.frontend.md      # Template for target repositories
    ├── japanese-writing/       # Japanese writing norm skills
    │   ├── plugin.json
    │   ├── .cursor-plugin/plugin.json
    │   ├── .codex-plugin/plugin.json
    │   ├── .claude-plugin/plugin.json
    │   ├── rules/common-rules.mdc         # Always-on shared rules (Cursor rule; also read by the Claude Code hook)
    │   ├── claude/hooks.json              # Claude Code-only SessionStart hook
    │   └── skills/
    │       ├── japanese-tech-writing/SKILL.md
    │       ├── cognitive-rhythm-writing/SKILL.md
    │       └── semantic-generation/SKILL.md
    └── shared-mcp/             # Shared MCP server definitions
        ├── plugin.json
        ├── mcp.json
        ├── .cursor-plugin/plugin.json
        ├── .codex-plugin/plugin.json
        ├── .claude-plugin/plugin.json   # MCP servers inlined for Claude Code
        └── .mcp.json
```

Each plugin treats the standard root `plugin.json` as the source of truth and additionally ships client-specific manifests for Cursor (`.cursor-plugin/plugin.json`), Codex (`.codex-plugin/plugin.json`), and Claude Code (`.claude-plugin/plugin.json`). Skills remain shared in the portable format. Cursor-specific rules live in `rules/` and are distributed only through `.cursor-plugin/plugin.json`. Claude Code-only hooks live in `claude/` and are distributed only through `.claude-plugin/plugin.json`. MCP keeps per-client files where schemas differ.

## Plugins

| Plugin | Contents |
| :-- | :-- |
| `development-rules` | `git-development-rules` (minimal Git development rules: Conventional Commits, TDD, pull request workflow, and related practices) and `evidence-driven-engineering` (back diagnoses with code and observations, verify running behavior, make verification repeatable, prevent recurring corrections with types, lint, CI, and similar mechanisms, and guidance for delegation and skill evaluation) |
| `frontend-ui-development` | Guardrails for GUI/UI implementation, prototyping, stabilization, and visual bug fixes; prioritizes existing components, design tokens, and layout structure. Cursor also receives an `.mdc` rule |
| `japanese-writing` | `japanese-tech-writing` (writing norms for technical documents), `cognitive-rhythm-writing` (cognitive-rhythm design), `semantic-generation` (referent-table-first generation). Also ships always-on shared rules (reply in Japanese; do not use the word 「正本」), loaded as a rule in Cursor and via a SessionStart hook in Claude Code |
| `shared-mcp` | `chrome-devtools` (stdio, npx), `bigquery` (streamable-http), `huggingface` (streamable-http) |

## Installation

### Cursor

Symlink (or copy) each plugin directory under `~/.cursor/plugins/local/`, then restart Cursor (or run **Developer: Reload Window**).

```bash
ln -s /path/to/my-agent-plugins/plugins/development-rules ~/.cursor/plugins/local/development-rules
ln -s /path/to/my-agent-plugins/plugins/frontend-ui-development ~/.cursor/plugins/local/frontend-ui-development
ln -s /path/to/my-agent-plugins/plugins/japanese-writing ~/.cursor/plugins/local/japanese-writing
ln -s /path/to/my-agent-plugins/plugins/shared-mcp ~/.cursor/plugins/local/shared-mcp
```

To verify, open **Customize** in the sidebar and check that rules, skills, and MCP servers appear.

The shared rules in `japanese-writing` (`rules/common-rules.mdc`) are an `alwaysApply: true` rule and are always loaded.

`frontend-ui-development` distributes the portable `SKILL.md` plus the Cursor-specific `rules/frontend-ui-guardrails.mdc`. Project-specific details should be adapted into the target repository's `AGENTS.md` using the bundled `assets/AGENTS.frontend.md` as a starting point.

For team distribution, use a Team Marketplace on the Teams / Enterprise plan (**Dashboard → Plugins**, then Import from Repo). The root `.cursor-plugin/marketplace.json` provides the plugin catalog.

### Codex

Register the repository root as a local marketplace, then install from the CLI.

```bash
cd /path/to/my-agent-plugins
codex plugin marketplace add .
codex plugin list --marketplace my-agent-plugins --json --available   # inspect the catalog
codex plugin add development-rules@my-agent-plugins
codex plugin add frontend-ui-development@my-agent-plugins
codex plugin add japanese-writing@my-agent-plugins
codex plugin add shared-mcp@my-agent-plugins
```

You can also install from `/plugins` (plugin browser) inside `codex`, or from the plugin screen in the ChatGPT desktop app. Bundled skills and MCP servers take effect **after starting a new session**.

Codex receives the portable Agent Plugins skill. The Cursor-specific `.mdc` rule is not distributed to Codex; use `AGENTS.md` for persistent project-specific instructions when needed.

Codex plugins cannot distribute always-on instructions. To apply the `japanese-writing` shared rules (such as replying in Japanese) in Codex, append the body of `plugins/japanese-writing/rules/common-rules.mdc` (without the frontmatter) to the global instructions file `~/.codex/AGENTS.md`.

Installed plugins are copies in the cache (`~/.codex/plugins/cache/`); after changing plugin contents, reinstall (`codex plugin remove` → `codex plugin add`) to pick up the changes. Note that `codex plugin marketplace upgrade` only applies to Git-sourced marketplaces, not local registrations.

### Claude Code

Register the repository root as a local marketplace, then install the plugins.

```bash
claude plugin marketplace add /path/to/my-agent-plugins
claude plugin install development-rules@my-agent-plugins
claude plugin install frontend-ui-development@my-agent-plugins
claude plugin install japanese-writing@my-agent-plugins
claude plugin install shared-mcp@my-agent-plugins
```

You can do the same from `/plugin` inside `claude`. Installing at the default user scope makes the skills available in every project.

Claude Code receives the portable skills as-is. `japanese-writing` additionally ships a SessionStart hook (`claude/hooks.json`) that adds `rules/common-rules.mdc` to the context of every session, so those rules apply even when no skill is triggered. For `shared-mcp`, Claude Code uses the servers declared inline in `.claude-plugin/plugin.json` (the plugin-root `.mcp.json` is in Codex format).

Installed plugins are copies in the cache (`~/.claude/plugins/cache/`). After changing plugin contents and bumping `version`, run `claude plugin marketplace update my-agent-plugins` and then `claude plugin update <plugin>@my-agent-plugins`.

## License and provenance

- `japanese-tech-writing` and `cognitive-rhythm-writing` are based on [public gists by k16shikano](https://gist.github.com/k16shikano/fd287c3133457c4fd8f5601d34aa817d) ([cognitive-rhythm edition](https://gist.github.com/k16shikano/eb2929f13ed19c97188393d297be8432)) with local adjustments. The author [declares that Unlicense (public-domain dedication) applies to all of their public gists](https://gist.github.com/k16shikano/67625f2a7d96e3bbdfae8d571a936063), so redistribution and modification in a public repository are unrestricted.
- `semantic-generation` is original work.
- `evidence-driven-engineering` is a Japanese translation and general-purpose restructuring of [unicodef1wn/lauren-poteto-rules](https://github.com/unicodef1wn/lauren-poteto-rules) (MIT License, Copyright (c) 2026 unicodef1wn). The underlying principles come from talks by [Lauren Tan (@poteto)](https://x.com/poteto) about working with coding agents. The full license text is in the skill's `LICENSE` file.
- `frontend-ui-development` is original work.

## Operating rules

- Update skills in this repository and distribute them to each client via plugins.
- Do not disguise client-specific components as portable Agent Plugins components. Cursor rules stay on the Cursor plugin side, and Claude Code hooks stay on the Claude Code plugin side.
- Never place secrets or credentials inside a plugin (including `env` / `headers` in `mcp.json`). The specification also forbids this.
- Bump the `version` in the corresponding `plugin.json` whenever a plugin changes.
