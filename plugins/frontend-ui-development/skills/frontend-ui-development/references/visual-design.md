# Visual design guidance

Use this reference for new GUI work, screenshot-based recreation, or substantial visual redesign. Do not load it for unrelated frontend changes.

## Preserve context before inventing a style

- In an Astryx project, the visual language is the active theme plus Astryx templates. Change the look through the theme (`astryx theme add`, `astryx docs theme`), not through per-screen colors or spacing.
- If the repository standardizes on another design system, extend that one instead of introducing a parallel one.
- Let the product domain, target user, information density, and task flow drive the choice of template and components.
- Avoid adding decorative UI patterns merely because they are common in generated interfaces.

## Recreating a screenshot or mock

- Map each region to the closest Astryx template, block, and component (`astryx build "<idea>"`, MCP `search`) before writing markup.
- Match structure, hierarchy, and density, not exact pixels. Snap colors, spacing, and radii to the nearest tokens instead of copying measured values.
- If the reference needs a look the theme cannot express, say so and propose a theme change rather than hardcoding values.

## Build around the actual interaction

- Use the component that matches the interaction semantics instead of styling generic containers to imitate controls.
- Keep primary and secondary actions distinguishable through the component's own variants.
- Preserve readable hierarchy among navigation, headings, body content, metadata, and actions.
- Treat empty, loading, error, disabled, focus, hover, and selected states as part of the interface when they matter to the flow.

## Responsive behavior

- Prefer the template's frame and layout components, which adapt naturally, before adding breakpoint-specific patches.
- Check representative narrow and wide viewports when the requested UI is expected to be responsive.
- Avoid screenshot-perfect positioning that only works at one viewport unless the user explicitly wants a fixed mock.

## Visual assets

- Use the icon set the project's Astryx setup provides (`astryx docs icons`); do not introduce a second icon family.
- Use imagery only when it supports the information or product experience rather than filling space.

## Verification

For material visual changes, inspect the rendered result when an appropriate browser, Storybook, screenshot, or preview workflow is available. Focus on the surfaces changed rather than exhaustively reviewing the entire product.
