---
name: frontend-ui-development
description: Use for web GUI/UI implementation, visual mocks, screenshot recreation, visual adjustments, UI refactoring, and visual bug fixes. Preserve existing components, design tokens, and layout conventions while balancing exploration speed with long-term maintainability. Do not use for backend-only changes.
---

# Frontend UI Development

## Goal

Avoid turning UI work into a collection of local patches. Make changes that fit the requested speed and quality while preserving useful structure already present in the codebase.
This skill provides defaults for judgment; it is not a fixed procedure.

## Instruction handling

- Respect explicit task instructions, applicable `AGENTS.md` files, and repository hard constraints.
- Do not let this skill create unnecessary approval gates, excessive investigation, or scope expansion.
- Do not mechanically execute every possible check below; inspect only what is relevant to the requested change.

## Development phase

Determine a phase only when it helps. If none is specified, infer it from the request and codebase and usually keep that inference implicit.

- **EXPLORE**: quickly test visual direction, information architecture, flows, and layout.
- **STABILIZE**: clean up proven UI patterns and temporary implementation before continued feature growth.
- **PRODUCTION**: optimize for long-term maintenance, accessibility, responsive behavior, and testability.

The phase changes optimization priorities, not a mandatory sequence of steps.

## Core principles

### Prefer the existing system

When modifying existing UI, inspect enough surrounding code to preserve relevant conventions such as:

- existing UI primitives and component APIs
- design tokens and theming
- styling approach
- layout conventions
- established validation methods

Reuse or naturally extend an existing component when it has the same semantic role and responsibility. Do not abstract components merely because they look similar.

### Put changes at the right layer

Preferred dependency direction:

```text
Design Tokens
    ↓
Generic UI Primitives
    ↓
Domain / Feature Components
    ↓
Pages / Screens
```

Shared visual decisions usually belong in tokens, generic UI in primitives, reusable UI with domain semantics in feature components, and route-specific composition in pages/layouts.

### Check structure before adding local patches

For alignment and visual bugs, do not immediately add `margin-*`, `top/left`, transforms, or selector overrides. Inspect the relevant parent layout, gap, padding, alignment, sizing, overflow, responsive rules, or shared component when those are plausible causes.

A local override is acceptable when the intent is genuinely local. Avoid `!important`, deep selector chains, arbitrary z-index escalation, and duplicate primitives by default.

## Phase weighting

### EXPLORE

Prioritize speed, information hierarchy, visual direction, and interaction feel. One-off experimental values and small temporary duplication are acceptable. Do not prematurely abstract unstable UI; keep experiments easy to delete and rewrite.

For new GUI work or substantial visual redesign, consult `references/visual-design.md` when useful.

### STABILIZE

Before continuing to patch a prototype, consolidate patterns that have actually proven stable and remove temporary structure that would make further work harder. See `references/stabilization.md` for a focused audit checklist.

### PRODUCTION

Use established tokens and shared primitives for shared decisions, and verify the accessibility, responsive behavior, and automated coverage that matter for the requested change.

## Validation

Use the smallest meaningful validation proportional to the change and current phase.

- Run checks that the repository requires.
- Do not add or run broad test suites for small, reversible visual changes without a concrete reason.
- For visual changes, prefer targeted browser, Storybook, or screenshot verification when available.
- Once relevant checks pass, do not broaden or repeat validation without a reason.

## When preparing AGENTS.md

Use `assets/AGENTS.frontend.md` as a template for project facts.
Do not repeat generic frontend engineering guidance there. Record only grounded repository details such as actual paths, libraries, styling approach, validation commands, and repository-specific constraints.

## Completion

When useful, briefly report decisions that future maintainers need to understand, such as the layer changed, any new token/component introduced, or why an exceptional local override was appropriate.
