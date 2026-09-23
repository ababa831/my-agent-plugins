# my-agent-plugins

[日本語版](README.md)

A personal repository that consolidates agent configurations (skills and MCP servers) shared across Cursor, Codex, and Claude Code, adhering to the [Agent Plugins specification 1.0.0](https://agent-plugins.org/) ([agentplugins/agent-plugins-spec](https://github.com/agentplugins/agent-plugins-spec)).

---

## Key Features

- **Multi-Client Support**: Seamlessly distributes plugins to the three major agent environments: Cursor, Codex, and Claude Code.
- **Specification-Compliant Clean Architecture**: Strictly separates portable components (Agent Skills / MCP) from client-specific extensions (rules / hooks).
- **Practical Skills Included**: Bundled with Git development conventions, frontend UI guardrails, Japanese writing norms, and common MCP servers.

---

## Included Plugins

| Plugin | Overview | Key Features / Skills |
| :-- | :-- | :-- |
| [`development-rules`](plugins/development-rules/) | Shared Git development rules & evidence-driven verification | `git-development-rules`, `evidence-driven-engineering` |
| [`frontend-ui-development`](plugins/frontend-ui-development/) | Frontend GUI/UI development guardrails | `frontend-ui-development`, Cursor rules, template |
| [`japanese-writing`](plugins/japanese-writing/) | Japanese writing norms & common conventions | `japanese-tech-writing`, `cognitive-rhythm-writing`, `semantic-generation`, shared rules |
| [`shared-mcp`](plugins/shared-mcp/) | Shared MCP server definitions | Chrome DevTools, BigQuery, Hugging Face |

For detailed documentation and specifications for each plugin, see [Plugin Specifications (docs/plugins.en.md)](docs/plugins.en.md).

---

## Quick Start

Minimal installation instructions for each client. For detailed setup, hook behavior, and update procedures, refer to the [Client-Specific Installation Guide (docs/installation.en.md)](docs/installation.en.md).

### Cursor

Use symlinks only if the target resolves inside `~/.cursor/plugins/local/`. For external paths, copy the directory instead, then restart Cursor:

```bash
mkdir -p ~/.cursor/plugins/local
cp -R /path/to/my-agent-plugins/plugins/<plugin-name> ~/.cursor/plugins/local/
```

### Codex

Register the repository root as a local marketplace and install via CLI:

```bash
cd /path/to/my-agent-plugins
codex plugin marketplace add .
codex plugin add <plugin-name>@my-agent-plugins
```

### Claude Code

Register the repository root as a local marketplace and install:

```bash
claude plugin marketplace add /path/to/my-agent-plugins
claude plugin install <plugin-name>@my-agent-plugins
```

---

## Repository Layout

```text
my-agent-plugins/
├── docs/                # Detailed documentation (architecture, install guides, specs, guidelines)
├── plugins/             # Plugin implementations (skills, rules, hooks, mcp)
├── .cursor-plugin/      # Cursor marketplace manifest
├── .claude-plugin/      # Claude Code marketplace manifest
└── .agents/plugins/     # Codex marketplace manifest
```

For design principles and manifest management policies, see [Architecture and Design Principles (docs/architecture.en.md)](docs/architecture.en.md).

---

## Documentation

- [Architecture and Design Principles](docs/architecture.en.md) - Design philosophy, boundaries, and complete directory tree
- [Client-Specific Installation Guide](docs/installation.en.md) - Detailed setup, hook behavior, and update workflows
- [Plugin Specifications](docs/plugins.en.md) - Comprehensive documentation of bundled plugins and skills
- [Operating Guidelines and Rules](docs/guidelines.en.md) - Development procedures, checklist, and terminology standards

---

## License and Credits

- For license details and author credits (k16shikano, Lauren Tan, etc.), see individual plugin directories and [Plugin Specifications (docs/plugins.en.md)](docs/plugins.en.md).
- For repository operating and contribution guidelines, see [Operating Guidelines and Rules (docs/guidelines.en.md)](docs/guidelines.en.md).
