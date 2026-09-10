# Visual design guidance

Use this reference for new GUI work, screenshot-based recreation, or substantial visual redesign. Do not load it for unrelated frontend changes.

## Preserve context before inventing a style

- If the repository already has a design system, component library, theme, or visual language, extend it rather than introducing a parallel one.
- Let the product domain, target user, information density, and task flow drive visual choices.
- Avoid adding decorative UI patterns merely because they are common in generated interfaces.

## Build around the actual interaction

- Use controls that match the interaction semantics instead of styling generic containers to imitate controls.
- Keep primary and secondary actions visually distinguishable without inventing unnecessary variants.
- Preserve readable hierarchy among navigation, headings, body content, metadata, and actions.
- Treat empty, loading, error, disabled, focus, hover, and selected states as part of the interface when they matter to the flow.

## Responsive behavior

- Prefer layout systems that adapt naturally before adding breakpoint-specific patches.
- Check representative narrow and wide viewports when the requested UI is expected to be responsive.
- Avoid screenshot-perfect positioning that only works at one viewport unless the user explicitly wants a fixed mock.

## Visual assets

- Reuse repository assets and established iconography when available.
- Do not introduce a second icon family or visual vocabulary without a clear reason.
- Use imagery only when it supports the information or product experience rather than filling space.

## Verification

For material visual changes, inspect the rendered result when an appropriate browser, Storybook, screenshot, or preview workflow is available. Focus on the surfaces changed rather than exhaustively reviewing the entire product.
