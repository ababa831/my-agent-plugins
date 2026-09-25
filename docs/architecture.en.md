# Architecture and Design Principles

This document explains the design philosophy, directory structure, and client-specific boundary management of this repository.

[日本語版](architecture.md) | [Back to README](../README.en.md)

---

## Core Philosophy

This repository consolidates configurations shared across Cursor, Codex, and Claude Code under a single repository, adhering to the [Agent Plugins specification 1.0.0](https://agent-plugins.org/) ([agentplugins/agent-plugins-spec](https://github.com/agentplugins/agent-plugins-spec)).

### Compatibility Boundary

The Agent Plugins v1 specification defines exactly two portable component types:

1. **skills**: Skills following the [Agent Skills specification](https://agentskills.io/specification) (`skills/`)
2. **MCP servers**: Shared MCP server configurations (`mcp.json`)

Rules, hooks, commands, and other workflow configurations remain client-specific (extension namespaces). This repository preserves that boundary strictly rather than inventing pseudo-portable abstractions:

- **Portable components**: Shared identically across clients.
- **Client-specific extensions**: Placed strictly in client manifests and designated directories (such as `rules/` for Cursor or `claude/` for Claude Code).

---

## Directory Layout

The complete directory structure of this repository is as follows:

```text
my-agent-plugins/
├── AGENTS.md                   # Instructions for agents editing this repository
├── README.md                   # Japanese overview & quick start
├── README.en.md                # English overview & quick start
├── docs/                       # Detailed documentation
│   ├── architecture.md         # Architecture & design principles (Japanese)
│   ├── architecture.en.md      # This document
│   ├── installation.md         # Detailed installation guide (Japanese)
│   ├── installation.en.md      # Detailed installation guide (English)
│   ├── plugins.md              # Detailed plugin documentation (Japanese)
│   ├── plugins.en.md           # Detailed plugin documentation (English)
│   ├── guidelines.md           # Operating guidelines (Japanese)
│   └── guidelines.en.md        # Operating guidelines (English)
├── .cursor-plugin/
│   └── marketplace.json        # Marketplace manifest for Cursor
├── .claude-plugin/
│   └── marketplace.json        # Marketplace manifest for Claude Code
├── .agents/
│   └── plugins/
│       └── marketplace.json    # Marketplace manifest for Codex
└── plugins/
    ├── development-rules/      # Shared Git development rules & evidence-driven verification
    │   ├── plugin.json
    │   ├── .cursor-plugin/plugin.json
    │   ├── .codex-plugin/plugin.json
    │   ├── .claude-plugin/plugin.json
    │   ├── claude/hooks.json              # Claude Code SessionStart hook
    │   └── skills/
    │       ├── git-development-rules/
    │       └── evidence-driven-engineering/
    ├── frontend-ui-development/ # GUI/UI development guardrails
    │   ├── plugin.json
    │   ├── .cursor-plugin/plugin.json
    │   ├── .codex-plugin/plugin.json
    │   ├── .claude-plugin/plugin.json
    │   ├── rules/frontend-ui-guardrails.mdc   # Cursor-specific persistent rule
    │   └── skills/frontend-ui-development/
    │       ├── SKILL.md
    │       └── assets/AGENTS.frontend.md
    ├── japanese-writing/       # Japanese writing norm skills
    │   ├── plugin.json
    │   ├── .cursor-plugin/plugin.json
    │   ├── .codex-plugin/plugin.json
    │   ├── .claude-plugin/plugin.json
    │   ├── rules/common-rules.mdc         # Shared rules (Cursor rule & Claude Code hook)
    │   ├── rules/readme-writing.mdc       # README writing conventions (Cursor rule & Claude Code hook)
    │   ├── claude/hooks.json              # Claude Code hooks (SessionStart / PreToolUse)
    │   ├── claude/check_banned_words.py   # Detector script invoked by PreToolUse hook
    │   ├── claude/inject_readme_rule.py   # Injects README conventions on README writes
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

---

## Manifest Management Policy

Each plugin treats its standard root `plugin.json` as the source of truth for portable metadata.

Client-specific manifests (Cursor: `.cursor-plugin/plugin.json`, Codex: `.codex-plugin/plugin.json`, Claude Code: `.claude-plugin/plugin.json`) coexist side by side and follow these principles:

1. **Metadata Alignment**:
   - Plugin names, versions, and descriptions stay aligned across all manifests unless a client-specific difference is intentional.
2. **Skill Sharing**:
   - Portable skills under `skills/` are shared in standard format across all clients.
3. **Client-Specific Separation**:
   - **Cursor**: Specific rules live under `rules/*.mdc` and are exposed only via `.cursor-plugin/plugin.json`.
   - **Claude Code**: Specific hooks live under `claude/` and are exposed only via `.claude-plugin/plugin.json`.
   - **Codex / MCP**: Different format files are maintained where schemas differ (e.g., inlined definitions for Claude Code).
