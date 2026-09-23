# Client-Specific Installation Guide

This document provides detailed setup instructions, rule and hook behavior specifications, update procedures, and troubleshooting tips for Cursor, Codex, and Claude Code.

[日本語版](installation.md) | [Back to README](../README.en.md)

---

## Table of Contents

- [Cursor](#cursor)
- [Codex](#codex)
- [Claude Code](#claude-code)

---

## Cursor

### Local Plugin Setup

Copy (or symlink) each plugin directory under `~/.cursor/plugins/local/`, then restart Cursor (or run **Developer: Reload Window**).

```bash
# Copying plugins (recommended)
mkdir -p ~/.cursor/plugins/local
cp -R /path/to/my-agent-plugins/plugins/development-rules ~/.cursor/plugins/local/
cp -R /path/to/my-agent-plugins/plugins/frontend-ui-development ~/.cursor/plugins/local/
cp -R /path/to/my-agent-plugins/plugins/japanese-writing ~/.cursor/plugins/local/
cp -R /path/to/my-agent-plugins/plugins/shared-mcp ~/.cursor/plugins/local/

# Or using symlinks
ln -s /path/to/my-agent-plugins/plugins/development-rules ~/.cursor/plugins/local/development-rules
ln -s /path/to/my-agent-plugins/plugins/frontend-ui-development ~/.cursor/plugins/local/frontend-ui-development
ln -s /path/to/my-agent-plugins/plugins/japanese-writing ~/.cursor/plugins/local/japanese-writing
ln -s /path/to/my-agent-plugins/plugins/shared-mcp ~/.cursor/plugins/local/shared-mcp
```

### Verification

Open **Customize** in the Cursor sidebar to verify that rules, skills, and MCP servers appear properly.

### Rule Behavior

- **`japanese-writing`**:
  - `rules/common-rules.mdc` is configured with `alwaysApply: true` and is automatically injected into every session.
- **`frontend-ui-development`**:
  - In addition to the portable `SKILL.md`, this plugin provides `rules/frontend-ui-guardrails.mdc` for Cursor.
  - To adapt project-specific UI rules, copy the bundled template `assets/AGENTS.frontend.md` into the target repository's `AGENTS.md`.

### Team Distribution (Team Marketplace)

For Teams / Enterprise plans, distribution via Team Marketplace is supported:
1. Open **Dashboard → Plugins** in Cursor.
2. Select **Import from Repo** and specify this repository's URL.
3. The root `.cursor-plugin/marketplace.json` provides the plugin list.

---

## Codex

### Register Marketplace and Add Plugins

Register the repository root as a local marketplace and install plugins via the CLI:

```bash
cd /path/to/my-agent-plugins
codex plugin marketplace add .

# Check available plugins in the catalog
codex plugin list --marketplace my-agent-plugins --json --available

# Install plugins
codex plugin add development-rules@my-agent-plugins
codex plugin add frontend-ui-development@my-agent-plugins
codex plugin add japanese-writing@my-agent-plugins
codex plugin add shared-mcp@my-agent-plugins
```

### GUI Installation and Activation

You can also install plugins from the `/plugins` menu in `codex` or through the ChatGPT desktop application.
Installed skills and MCP servers take effect **after starting a new session**.

### Declarative Always-On Rule Limitations and Setup

Codex plugins do not have a **declarative always-on rules feature** like Cursor's `alwaysApply: true` (while Codex can inject context via `SessionStart` hooks, running hooks requires trust confirmation).
To apply the `japanese-writing` common rules globally in Codex without hook prompts, copy the body of `plugins/japanese-writing/rules/common-rules.mdc` (excluding the YAML frontmatter) into `~/.codex/AGENTS.md`.

### Updating Plugins

Installed plugins are cached in `~/.codex/plugins/cache/`.
When plugins are updated in this repository, reinstall them to apply changes:

```bash
codex plugin remove <plugin-name>@my-agent-plugins
codex plugin add <plugin-name>@my-agent-plugins
```

*Note: `codex plugin marketplace upgrade` only works for Git-sourced marketplaces, so local installations require re-adding.*

---

## Claude Code

### Register Marketplace and Install Plugins

Register the repository root as a local marketplace and install plugins:

```bash
# Register marketplace
claude plugin marketplace add /path/to/my-agent-plugins

# Install plugins (default user scope applies across all projects)
claude plugin install development-rules@my-agent-plugins
claude plugin install frontend-ui-development@my-agent-plugins
claude plugin install japanese-writing@my-agent-plugins
claude plugin install shared-mcp@my-agent-plugins
```

You can also install plugins interactively using the `/plugin` command inside `claude`.

### Hook Specifications and Behavior

In addition to portable skills, Claude Code uses hooks defined in `claude/hooks.json`:

1. **`development-rules` SessionStart Hook**:
   - Injects the body of `skills/git-development-rules/SKILL.md` (excluding frontmatter) into the session context at startup.
   - *Note: On Windows, Git Bash is recommended because the hook uses `awk`. Without Git Bash, the hook fails gracefully in PowerShell, and the skill remains available.*
2. **`japanese-writing` SessionStart Hook**:
   - Injects `rules/common-rules.mdc` into every session context so that common rules apply even when no skill is explicitly triggered.
3. **`japanese-writing` PreToolUse Hook (Banned Terms Detector)**:
   - Before executing file creation/modification tools (Write, Edit, NotebookEdit), `claude/check_banned_words.py` runs automatically.
   - If unrecommended/banned terms are newly added, the hook interrupts tool execution and instructs the agent to rephrase using proper alternatives (e.g., "信頼できる唯一の情報源", "定義元", "管理元").
   - Detection behavior varies by tool:
     - `Edit`: Compares occurrences between `old_string` and `new_string`, so edits that preserve existing occurrences while editing other text are not blocked.
     - `Write` / `NotebookEdit`: Scans the entire file content or new cell source (`content` / `new_source`), so saving files with pre-existing banned terms will be blocked.
4. **`shared-mcp` Configuration**:
   - Claude Code uses the MCP servers declared inline in `.claude-plugin/plugin.json`.

### Updating Plugins

Installed plugins are cached under `~/.claude/plugins/cache/`.
After bumping the plugin `version` in `plugin.json`, run:

```bash
claude plugin marketplace update my-agent-plugins
claude plugin update <plugin-name>@my-agent-plugins
```
