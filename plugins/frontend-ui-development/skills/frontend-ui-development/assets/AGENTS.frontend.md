# Frontend Project Instructions

> Adapt this template to the repository. Remove placeholders that cannot be grounded in the actual codebase.

## Project facts

- UI phase: `<EXPLORE | STABILIZE | PRODUCTION>`
- Frontend root: `<path>`
- Shared UI primitives: `<path or package>`
- Design token source: `<path or package>`
- Styling approach: `<CSS Modules | Tailwind | CSS-in-JS | ...>`
- Typecheck command: `<command>`
- Lint command: `<command>`
- Test command: `<command>`
- Visual verification: `<Storybook / screenshot test / manual browser check / ...>`

## Required workflow for UI changes

Before implementing:

1. Search for an existing component with the same semantic role.
2. Search for an existing design token that represents the visual decision.
3. Inspect the parent layout before applying local spacing or positioning fixes.
4. Decide whether the change belongs to a token, generic UI primitive, feature component, or page/layout.
5. Prefer a structural fix over a local override.

After implementing, run the applicable typecheck, lint, tests, and visual verification listed above.

## Architecture

Prefer this dependency direction:

```text
Design Tokens
    ↓
Generic UI Primitives
    ↓
Domain / Feature Components
    ↓
Pages / Screens
```

- Shared visual decisions belong in design tokens.
- Generic reusable UI belongs in the shared UI layer.
- Reusable UI with domain semantics belongs in the feature/domain layer.
- Pages/screens should mainly compose lower-level pieces.
- Do not create duplicate generic primitives when an existing primitive can be extended cleanly.
- Do not abstract components solely because they look similar; share them when they have the same role and should evolve together.

## Styling guardrails

Before adding a local `margin`, positional offset, transform, or selector override to fix visual alignment, inspect:

- parent `gap`
- parent padding
- flex/grid alignment
- width/min-width/max-width
- overflow
- shared component styles
- responsive/breakpoint rules

Avoid by default:

- `!important`
- deep selector chains
- arbitrary z-index escalation
- duplicate visual values when an existing token matches
- one-off absolute positioning used only to match a screenshot

A local override is acceptable when the requirement is genuinely local. Document the reason in the implementation summary.

## Phase behavior

### EXPLORE

Prioritize speed, layout, information hierarchy, visual direction, and interaction feel.
One-off experimental values and small temporary duplication are acceptable.
Do not over-abstract unstable UI; keep it easy to delete or rewrite.

### STABILIZE

Before adding substantial new features, audit repeated UI patterns, visual values, magic numbers, layout hacks, duplicate primitives, large components, accessibility, and responsive behavior.
Refactor stable patterns into tokens/components instead of continuing to patch the mock.

### PRODUCTION

Use established tokens and shared primitives for shared decisions, verify accessibility and responsive behavior, and add appropriate automated coverage for important interactions and visual regressions.

## Visual bug fixes

For requests such as "move this down a little" or "match the screenshot", identify the structural cause before changing CSS.
Do not optimize only for the current screenshot if the change would degrade the underlying component or layout system.
