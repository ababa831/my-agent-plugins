---
name: frontend-ui-development
description: Apply when implementing or refining web GUI/UI, building visual prototypes, recreating screenshots, refactoring frontend UI, or fixing visual bugs. Inspect existing components, design tokens, and layout structure before editing, prevent accumulations of local CSS patches, and adjust architectural strictness across EXPLORE, STABILIZE, and PRODUCTION phases.
---

# Frontend UI Development

## Goal

Keep UI code understandable and changeable as the product evolves instead of optimizing only for the current screenshot.
For exploratory mocks, however, prioritize iteration speed and avoid premature abstraction.

## 1. Determine the current phase

Use an explicit phase if the requester provides one. Otherwise infer it from the task and state the assumption briefly in the implementation plan.

- **EXPLORE**: Disposable or highly changeable mock/prototype used to test visual direction, information architecture, and interaction.
- **STABILIZE**: The direction is chosen and the prototype should be cleaned up before substantial feature growth.
- **PRODUCTION**: Long-lived implementation where reuse, accessibility, responsive behavior, and testing matter.

The phase changes the optimization target; it does not mean EXPLORE may be arbitrarily messy or PRODUCTION should abstract everything.

## 2. Inspect the codebase before implementing

Check the relevant project context before writing UI code:

1. Applicable `AGENTS.md` or repository-specific instructions
2. Framework and styling approach
3. Existing UI library, primitives, and shared components
4. Sources of color, spacing, typography, radius, and other design tokens
5. Parent flex/grid/gap/padding/sizing structure
6. Existing Storybook, visual regression, E2E, or other verification methods

Search for an existing component with the same semantic role before creating a new one.

## 3. Put changes in the correct layer

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

Decision guide:

- Shared visual decision → design token
- Generic UI with no domain knowledge → primitive/shared UI component
- Reusable UI with domain meaning → feature component
- Route/screen-specific composition → page/screen/layout

Do not abstract components merely because they look similar. Share components when their semantics and evolution should be shared.

## 4. Prevent patchwork fixes

For requests such as "move this down 3px", "nudge it right", or "match this screenshot", do not immediately add local CSS.

First inspect:

- parent gap
- padding
- flex/grid alignment
- width/min-width/max-width constraints
- overflow
- shared component behavior
- breakpoint/responsive rules

A local margin, positional offset, transform, or override is acceptable when the intent is truly local. Explain why it belongs there.

Avoid by default:

- duplicate primitives that represent an existing semantic role
- raw color/spacing/radius values when an existing token already represents the decision
- `!important`
- deep selector chains
- unexplained z-index escalation
- absolute positioning or offsets used only to match a screenshot

## 5. Phase-specific behavior

### EXPLORE

Prioritize information hierarchy, layout, visual rhythm, interaction feel, and fast comparison.

- Reuse existing Button/Input/Card-style primitives when convenient.
- Do not create tokens for every single experimental value.
- Do not prematurely abstract unstable UI.
- Keep experimental code easy to delete or rewrite.
- Avoid giant files and chains of overrides even in a prototype.

### STABILIZE

Do not simply continue patching the prototype. Audit it first for:

1. repeated semantic UI patterns
2. repeated colors/spacing/radii/type sizes
3. magic numbers
4. local layout hacks
5. duplicate primitives
6. oversized components
7. accessibility issues
8. responsive issues

Then refactor in the order: tokens → primitives → features → pages.

### PRODUCTION

- Prefer tokens for shared visual decisions.
- Prefer shared primitives for generic UI.
- Check keyboard behavior, focus, labels, semantic HTML, and other accessibility concerns.
- Verify responsive behavior at important viewport sizes.
- Add tests for important interactions according to repository conventions.
- Use Storybook or screenshot tests for meaningful visual changes when available.

## 6. When setting up AGENTS.md

When the requester wants frontend project instructions, use `assets/AGENTS.frontend.md` as a starting point rather than copying it blindly.

1. Inspect the target repository.
2. Identify the real frontend root, UI component path, token source, and verification commands.
3. Merge with an existing `AGENTS.md` without contradicting broader instructions.
4. In a monorepo, consider a nested `AGENTS.md` under the frontend subtree.
5. Remove unknown or irrelevant placeholders instead of guessing.

Template: `assets/AGENTS.frontend.md`

## 7. Completion checks

Run the repository's available typecheck, lint, tests, and visual verification as appropriate.

Finish with a short summary of:

- what changed
- which architectural layer changed
- whether a token or primitive was added
- why any local override was necessary

A task is complete only when both the requested outcome and the UI structure are acceptable.
