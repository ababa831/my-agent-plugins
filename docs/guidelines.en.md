# Operating Guidelines and Rules

This document outlines the development, maintenance, and contribution guidelines for the plugins in this repository.

[日本語版](guidelines.md) | [Back to README](../README.en.md)

---

## Core Principles

1. **Centralized Management & Distribution**:
   - Updates and additions to skills happen within this repository and are distributed to clients (Cursor, Codex, Claude Code) via plugins.
2. **Strict Portable Boundaries**:
   - Never disguise client-specific extensions (Cursor rules, Claude Code hooks, etc.) as portable Agent Plugins components.
   - Place Cursor-only rules under `rules/` and Claude Code-only hooks under `claude/`.
3. **No Secrets or Credentials**:
   - Never commit secrets, API keys, tokens, or personal data inside any plugin (including `env` or `headers` in `mcp.json`). This is strictly prohibited by specification.
4. **Version Alignment**:
   - Whenever modifying a plugin, bump the `version` field across all manifests: the root `plugin.json` and client manifests (`.cursor-plugin/`, `.codex-plugin/`, `.claude-plugin/`).
5. **Terminology Standards**:
   - In Japanese text, avoid unfamiliar or unnatural literal translations. Instead, use intuitive phrasing such as "single source of truth", "canonical definition", "master data", or "baseline".
   - Automated enforcement is strictly limited to the PreToolUse hook in `japanese-writing` for Claude Code. Avoid adding unnecessary CI or lint overhead.

---

## Change Checklist

When adding or modifying a plugin, verify each step:

- [ ] Update plugin files within the target plugin directory.
- [ ] Bump the `version` across all manifests (`plugin.json`, `.cursor-plugin/`, `.codex-plugin/`, `.claude-plugin/`) if modifying an existing plugin.
- [ ] Update entries across all three marketplace manifests (`.cursor-plugin/`, `.agents/plugins/`, `.claude-plugin/`) if the catalog changes.
- [ ] Update both `README.md` and `README.en.md` whenever user-facing behavior or installation steps change.
- [ ] Run test scripts (e.g., `bash tests/development-rules-hook.sh`) and validate JSON files.
- [ ] Use a feature branch and follow Conventional Commits; submit changes via Pull Request rather than committing directly to `main`.
