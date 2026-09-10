# Repository Instructions

## Purpose

This repository is the source of truth for personal agent plugins shared across Cursor and Codex.
Keep portable Agent Plugins components separate from client-specific extensions.

## Compatibility boundary

- Agent Plugins v1 portable components are `skills/` and `mcp.json`.
- Cursor-specific rules belong in a plugin's `rules/` directory and are exposed by `.cursor-plugin/plugin.json`.
- Codex-specific manifest details belong in `.codex-plugin/plugin.json`.
- Do not invent a portable representation for rules, hooks, commands, or other client-specific components.
- Repository-specific instructions belong in `AGENTS.md`; reusable project templates may live in a skill's `assets/` directory.

## Plugin layout

For a plugin that supports both Cursor and Codex, prefer this shape:

```text
plugins/<plugin-name>/
├── plugin.json
├── .cursor-plugin/plugin.json
├── .codex-plugin/plugin.json
├── skills/
│   └── <skill-name>/
│       └── SKILL.md
└── rules/                  # Cursor-only, when needed
    └── <rule-name>.mdc
```

The root `plugin.json` is the source of truth for portable plugin metadata.
Keep plugin names, versions, and descriptions aligned across client manifests unless a client-specific difference is intentional.

## Skill rules

- Follow the Agent Skills specification.
- The `name` in `SKILL.md` must match its parent directory.
- Descriptions must explain both what the skill does and when it should activate.
- Keep `SKILL.md` focused; move optional detail to `references/` and reusable templates/resources to `assets/`.
- Prefer framework-agnostic guidance unless a skill explicitly targets a framework.
- Do not duplicate the same long instruction text across portable skills and client-specific rules. Keep the skill as the complete portable workflow and rules as concise persistent guardrails.

## Cursor rule rules

- Put plugin rules under `rules/` as `.mdc` files.
- Include `description`, `alwaysApply`, and `globs` when file scoping is appropriate.
- Rules should be short, persistent constraints rather than full tutorials.
- Do not add a Cursor-only rule to the portable root `plugin.json`.

## Change checklist

When adding or changing a plugin:

1. Update the plugin files.
2. Bump the plugin version when an existing plugin changes.
3. Keep root, Cursor, and Codex manifests aligned.
4. Add or update entries in both marketplace manifests when the plugin catalog changes.
5. Update both `README.md` and `README.en.md` when user-facing behavior or installation changes.
6. Validate JSON and Agent Skills frontmatter.
7. Never commit secrets, credentials, private keys, tokens, or personal data.

## Git workflow

Also follow the installed `git-development-rules` skill: use a feature branch, keep changes focused, and merge through a Pull Request rather than committing directly to `main`.
