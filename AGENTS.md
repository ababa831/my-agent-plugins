# Repository Instructions

## Purpose

This repository is the source of truth for personal agent plugins shared across Cursor, Codex, and Claude Code.
Keep portable Agent Plugins components separate from client-specific extensions.

## Compatibility boundary

- Agent Plugins v1 portable components are `skills/` and `mcp.json`.
- Cursor-specific rules belong in a plugin's `rules/` directory and are exposed by `.cursor-plugin/plugin.json`.
- Codex-specific manifest details belong in `.codex-plugin/plugin.json`.
- Claude Code-specific manifest details belong in `.claude-plugin/plugin.json`. Claude Code-only hooks live in the plugin's `claude/` directory and are referenced only from that manifest. A hook may read a Cursor rule file so that shared always-on rules have a single file.
- Claude Code auto-loads a plugin-root `.mcp.json`, which is in Codex format here. Declare Claude Code MCP servers inline in `.claude-plugin/plugin.json` (`type`: `stdio` / `http`).
- Do not invent a portable representation for rules, hooks, commands, or other client-specific components.
- Repository-specific instructions belong in `AGENTS.md`; reusable project templates may live in a skill's `assets/` directory.

## Plugin layout

For a plugin that supports Cursor, Codex, and Claude Code, prefer this shape:

```text
plugins/<plugin-name>/
├── plugin.json
├── .cursor-plugin/plugin.json
├── .codex-plugin/plugin.json
├── .claude-plugin/plugin.json
├── skills/
│   └── <skill-name>/
│       ├── SKILL.md
│       ├── references/        # optional detail loaded only when useful
│       └── assets/            # optional reusable templates/resources
├── rules/                     # Cursor-only, when needed
│   └── <rule-name>.mdc
└── claude/                    # Claude Code-only hooks and injected rules, when needed
```

The root `plugin.json` is the source of truth for portable plugin metadata.
Keep plugin names, versions, and descriptions aligned across client manifests unless a client-specific difference is intentional.

## Skill rules

- Follow the Agent Skills specification.
- The `name` in `SKILL.md` must match its parent directory.
- Descriptions must explain both what the skill does and when it should activate.
- Keep `SKILL.md` focused; move optional detail to `references/` and reusable templates/resources to `assets/`.
- Prefer goals, invariants, and decision criteria over long mandatory step-by-step checklists; preserve the agent's ability to choose an efficient path.
- State broad defaults once instead of repeating the same guidance across `SKILL.md`, rules, and `AGENTS.md` templates.
- Prefer framework-agnostic guidance unless a skill explicitly targets a framework.
- Do not let a reusable skill introduce unnecessary approval gates, excessive validation, or scope expansion.
- Create or change a skill in response to an observed agent failure, and state the behavior it should improve.
- When evaluating a skill change, follow `evidence-driven-engineering`'s `references/evaluating-instructions.md`: include a routine small task to detect unnecessary process, and judge tool calls and diffs rather than the agent's confidence. If you could not run an evaluation, say the change is untested.

## Cursor rule rules

- Put plugin rules under `rules/` as `.mdc` files.
- Include `description`, `alwaysApply`, and `globs` when file scoping is appropriate.
- Rules should be short, persistent constraints rather than full tutorials.
- Scope globs narrowly enough to avoid activating rules for unrelated code.
- Do not add a Cursor-only rule to the portable root `plugin.json`.

## Change checklist

When adding or changing a plugin:

1. Update the plugin files.
2. Bump the plugin version when an existing released plugin changes.
3. Keep root, Cursor, Codex, and Claude Code manifests aligned.
4. Add or update entries in all three marketplace manifests (`.cursor-plugin/`, `.agents/plugins/`, `.claude-plugin/`) when the plugin catalog changes.
5. Update both `README.md` and `README.en.md` when user-facing behavior or installation changes.
6. Validate JSON and Agent Skills frontmatter, and run `claude plugin validate .`.
7. Never commit secrets, credentials, private keys, tokens, or personal data.

## Wording

Do not use the word 「正本」 in Japanese text; it is unfamiliar to most readers. Rephrase with 「定義元」「管理元」「元データ」「基準」 or similar.
The only mechanical check for this is the Claude Code PreToolUse hook in `japanese-writing`; do not add CI or lint checks for it unless repeated failures show the rule and hook are insufficient.

## Git workflow

Also follow the installed `git-development-rules` skill: use a feature branch, keep changes focused, and merge through a Pull Request rather than committing directly to `main`.
