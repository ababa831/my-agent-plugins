# my-agent-plugins

[日本語版](README.md)

A personal repository that consolidates configuration shared between Cursor and Codex, following the [Agent Plugins specification 1.0.0](https://agent-plugins.org/) ([agentplugins/agent-plugins-spec](https://github.com/agentplugins/agent-plugins-spec)).

Agent Plugins v1 defines exactly two portable component types: **skills ([Agent Skills specification](https://agentskills.io/specification))** and **MCP servers (`mcp.json`)**. Rules, hooks, and commands remain client-specific (extension namespaces), and this repository follows the same boundary.

## Layout

```
my-agent-plugins/
├── .cursor-plugin/
│   └── marketplace.json        # Marketplace manifest for Cursor
├── .agents/
│   └── plugins/
│       └── marketplace.json    # Marketplace manifest for Codex
└── plugins/
    ├── development-rules/      # Shared Git development rules
    │   ├── plugin.json
    │   ├── .cursor-plugin/plugin.json
    │   ├── .codex-plugin/plugin.json
    │   └── skills/git-development-rules/
    ├── japanese-writing/       # Japanese writing norm skills
    │   ├── plugin.json         # Agent Plugins standard manifest
    │   ├── .cursor-plugin/plugin.json
    │   ├── .codex-plugin/plugin.json
    │   └── skills/
    │       ├── japanese-tech-writing/SKILL.md
    │       ├── cognitive-rhythm-writing/SKILL.md
    │       └── semantic-generation/SKILL.md
    └── shared-mcp/             # Shared MCP server definitions
        ├── plugin.json
        ├── mcp.json            # Agent Plugins standard schema (explicit transport)
        ├── .cursor-plugin/plugin.json   # Cursor format (inline mcpServers)
        ├── .codex-plugin/plugin.json
        └── .mcp.json           # Codex format (wrapped mcp_servers)
```

Each plugin treats the standard root `plugin.json` as the source of truth and additionally ships client-specific manifests for Cursor (`.cursor-plugin/plugin.json`) and Codex (`.codex-plugin/plugin.json`). The skill format is identical across all three, so there is no duplication. Only MCP configuration has per-client files, to absorb schema differences (explicit vs. inferred transport, `mcpServers` vs. `mcp_servers`).

## Plugins

| Plugin | Contents |
| :-- | :-- |
| `development-rules` | Minimal shared Git development rules (Conventional Commits, TDD, pull request workflow, and related practices) |
| `japanese-writing` | `japanese-tech-writing` (writing norms for technical documents), `cognitive-rhythm-writing` (cognitive-rhythm design), `semantic-generation` (referent-table-first generation) |
| `shared-mcp` | `chrome-devtools` (stdio, npx), `bigquery` (streamable-http), `huggingface` (streamable-http) |

## Installation

### Cursor

Symlink (or copy) each plugin directory under `~/.cursor/plugins/local/`, then restart Cursor (or run **Developer: Reload Window**).

```bash
ln -s /path/to/my-agent-plugins/plugins/development-rules ~/.cursor/plugins/local/development-rules
ln -s /path/to/my-agent-plugins/plugins/japanese-writing ~/.cursor/plugins/local/japanese-writing
ln -s /path/to/my-agent-plugins/plugins/shared-mcp ~/.cursor/plugins/local/shared-mcp
```

To verify, open **Customize** in the sidebar and check that the skills and MCP servers appear.

For team distribution, use a Team Marketplace on the Teams / Enterprise plan (**Dashboard → Plugins**, then Import from Repo). The root `.cursor-plugin/marketplace.json` provides the plugin catalog.

### Codex

Register the repository root as a local marketplace, then install from the CLI.

```bash
cd /path/to/my-agent-plugins
codex plugin marketplace add .
codex plugin list --marketplace my-agent-plugins --json --available   # inspect the catalog
codex plugin add development-rules@my-agent-plugins
codex plugin add japanese-writing@my-agent-plugins
codex plugin add shared-mcp@my-agent-plugins
```

You can also install from `/plugins` (plugin browser) inside `codex`, or from the plugin screen in the ChatGPT desktop app. Bundled skills and MCP servers take effect **after starting a new session**.

Installed plugins are copies in the cache (`~/.codex/plugins/cache/`); after changing plugin contents, reinstall (`codex plugin remove` → `codex plugin add`) to pick up the changes. Note that `codex plugin marketplace upgrade` only applies to Git-sourced marketplaces, not local registrations.

## License and provenance

- `japanese-tech-writing` and `cognitive-rhythm-writing` are based on [public gists by k16shikano](https://gist.github.com/k16shikano/fd287c3133457c4fd8f5601d34aa817d) ([cognitive-rhythm edition](https://gist.github.com/k16shikano/eb2929f13ed19c97188393d297be8432)) with local adjustments. The author [declares that Unlicense (public-domain dedication) applies to all of their public gists](https://gist.github.com/k16shikano/67625f2a7d96e3bbdfae8d571a936063), so redistribution and modification in a public repository are unrestricted.
- `semantic-generation` is original work.

## Operating rules

- Update skills in this repository and distribute them to each client via plugins.
- Never place secrets or credentials inside a plugin (including `env` / `headers` in `mcp.json`). The specification also forbids this.
- Bump the `version` in the corresponding `plugin.json` whenever a plugin changes.
