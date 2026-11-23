# Plugin Specifications

This document explains the objectives, included skills, rules, hooks, and operational specifications for each plugin in this repository.

[日本語版](plugins.md) | [Back to README](../README.en.md)

---

## Table of Contents

1. [development-rules](#1-development-rules)
2. [formal-verification](#2-formal-verification)
3. [frontend-ui-development](#3-frontend-ui-development)
4. [japanese-writing](#4-japanese-writing)
5. [shared-mcp](#5-shared-mcp)

---

## 1. development-rules

### Overview

Provides essential Git development standards and evidence-driven engineering practices to eliminate speculative assumptions.

### Included Components

- **`git-development-rules` (Skill)**:
  - Adherence to [Conventional Commits](https://www.conventionalcommits.org/).
  - Test-Driven Development (TDD) principles.
  - Prohibits direct pushes to main; enforces feature branch and Pull Request workflows.
  - Prevention of committing credentials or personal data.
- **`evidence-driven-engineering` (Skill)**:
  - Backing up diagnoses with source code and observed runtime behavior (logs/outputs).
  - Verifying runtime behavior with repeatable tests.
  - Preventing recurring issues structurally via type systems, linters, and CI pipelines.
  - Guidance on task delegation and evaluating skills.
- **Claude Code SessionStart Hook (`claude/hooks.json`)**:
  - Automatically injects the body of `git-development-rules` into session context upon startup.

---

## 2. formal-verification

### Overview

Provides guardrails and skills to guarantee invariants of critical kernels (core business logic, state transitions, and access/PII policies) using formal verification. It currently supports Lean 4 and is structured so future methods such as TLA+ can sit alongside it cleanly across skills, rules, and hooks.

### Included Components

- **`lean4-formal-verification` (Skill)**:
  - Criteria for choosing among Level 1 (specification/invariant verification), Level 2 (executable oracle differential testing), and Level 3 (direct implementation verification).
  - Responsibility boundary where humans review specifications (theorem statements and assumptions) while agents handle proof search, differential testing, and CI wiring.
  - Soundness rules prohibiting `sorry`, `admit`, unapproved custom `axiom`s, and vacuous truth.
  - `references/ci-and-soundness.md`, `references/differential-testing.md`, `references/data-domain-patterns.md`, and `references/examples.md`.
  - `assets/lean4-verification.yml` (GitHub Actions template) and `assets/AGENTS.formal-verification.md` (project context template).
- **`rules/lean4-verification-guardrails.mdc` (Cursor Rule)**:
  - Applies specification-protection and soundness guardrails when editing `*.lean`, `lakefile.lean`, `lakefile.toml`, or `lean-toolchain` (`alwaysApply: false`).
- **Claude Code Hook (`claude/hooks.json`, `claude/inject_formal_verification_rule.py`)**:
  - Non-blocking `PreToolUse` (`Write` / `Edit`) hook that injects the matching guardrail rule body into context via a method-extensible pattern mapping table (ready for future TLA+ rules).

---

## 3. frontend-ui-development

### Overview

Maintains UI consistency in Web/GUI frontend engineering by preventing ad-hoc, patchwork styling.
It treats the [Astryx](https://github.com/meta/astryx) design system as the default design convention and checks templates, components, and tokens through the Astryx MCP and CLI before composing UI.
In projects that standardize on another design system, it does not mix Astryx in and follows the existing conventions instead.

### Included Components

- **`frontend-ui-development` (Skill)**:
  - Conventions to start pages from Astryx templates and compose them from Astryx components and tokens instead of raw `<div>`s or hardcoded hex/px.
  - `references/astryx.md` covering adoption, the CLI workflow, and the self-check.
  - `references/web-platform.md` covering how to use web platform features Astryx does not express (View Transitions, `content-visibility`, and so on) without conflicting with the Astryx conventions.
  - Guides prototyping, stabilization, and visual bug fixes.
- **`astryx` (MCP server)**:
  - Connects to `https://astryx.atmeta.com/mcp` and provides `search` (components, docs, templates) and `get` (props, examples, install command). No authentication is required.
  - It is an external server run by Meta, so search queries are sent to it. The skill tells agents not to put project code or secrets in queries. If you do not want it, disable the server in your client's MCP settings.

### Changes in 2.2.0

- Added a principle across the rule, skill, and references (`visual-design.md` / `stabilization.md`) to avoid adding subtitles, secondary labels, parenthetical notes, and explanatory copy, letting layout, proximity, spacing, and visual hierarchy communicate meaning instead. Existing or user-specified copy, actual data, input/action labels, input constraints, errors, and destructive confirmations are kept.

### Changes in 2.1.0

- Web platform features that Astryx components and props do not express are now used after checking the [Modern Web Guidance](https://github.com/GoogleChrome/modern-web-guidance) guide. Parts Astryx provides, such as Dialog, are not rebuilt to match a guide's example.
- Only features that exist solely as CSS (View Transitions, `content-visibility`, scroll-driven animations) are an exception to "no imported ad-hoc CSS"; they go in one stylesheet that uses Astryx motion tokens.
- The Astryx adoption steps now include wrapping each page in `AppShell`. Without it, switching light/dark mode leaves the page background behind.
- Modern Web Guidance is not bundled with this plugin; install it separately to use it. When it is not installed, the skill does not fetch and run the CLI itself; it says the guide is missing and how to install it.
- The Modern Web Guidance CLI sends search queries to Google as usage telemetry. The skill tells agents to keep confidential terms out of queries. Set the `DISABLE_TELEMETRY=1` environment variable to opt out.

  ```bash
  claude plugin install modern-web-guidance@claude-plugins-official
  ```

  For Cursor and Codex, see the [client installation guide](installation.en.md).

### Changes from 1.x (2.0.0)

- Projects that use Astryx, and new screens or apps in React 19+ projects with no design system or component library, now follow the Astryx conventions. Small changes to existing UI do not adopt Astryx.
- Projects that standardize on another design system or component library, React 18 and earlier, and non-React projects do not adopt Astryx; as in 1.x, existing components and tokens come first, and no dependencies are added.
- **`rules/frontend-ui-guardrails.mdc` (Cursor Rule)**:
  - Applies Astryx-based UI guardrails when Cursor edits frontend files.
- **`assets/AGENTS.frontend.md` (Template)**:
  - Reusable template for configuring repository-specific frontend guidelines in `AGENTS.md`.

---

## 4. japanese-writing

### Overview

Elevates the quality of Japanese text generated by agents, balancing clarity for technical writing with reduced cognitive load for readers.

### Included Skills

- **`semantic-generation`**: Referent-table-first generation method for unambiguous text.

For rewriting AI-sounding Japanese, use the external [yomiyasu](https://github.com/nanaism/yomiyasu) plugin instead of a skill in this plugin.

### Common Rules & Hooks

- **`rules/common-rules.mdc`**:
  - Requires Japanese responses by default.
  - Prohibits unfamiliar or unnatural literal translations in Japanese output, encouraging intuitive alternatives such as "single source of truth", "canonical definition", or "master data".
  - Injected into Cursor via `alwaysApply: true` and Claude Code via `SessionStart` hook.
- **`rules/readme-writing.mdc`**:
  - Conventions for writing READMEs along Diátaxis so that first-time readers can reproduce the steps (prerequisites, copy-pasteable commands, how to confirm success) without over-writing.
  - Loaded in Cursor when working on `README.md` and `README.*.md`, and in Claude Code by a `PreToolUse` hook (`claude/inject_readme_rule.py`) on `Write` / `Edit` to those files.
- **Banned Words Detector Hook (`claude/check_banned_words.py`)**:
  - PreToolUse hook in Claude Code that interrupts Write/Edit actions introducing unrecommended terms.

---

## 5. shared-mcp

### Overview

Bundles common Model Context Protocol (MCP) servers for convenient client integration.

### Included MCP Servers

- **`chrome-devtools`**: Browser automation and debugging with Chrome DevTools (stdio / npx).
- **`bigquery`**: Query execution and integration with Google Cloud BigQuery (streamable-http).
- **`huggingface`**: Hugging Face API integration (streamable-http).

Differences in client schemas (Cursor, Codex, Claude Code) are handled via the portable `mcp.json` (also read by Codex) and the inline definitions in each client manifest.
