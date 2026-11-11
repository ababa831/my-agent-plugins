# Web platform features with Astryx

Use this reference when an Astryx UI needs a web platform feature that Astryx components and props do not express: view transitions, scroll-driven animations, entry/exit animations on app-owned elements, `content-visibility`, loading priority, or newer browser APIs. It explains how to combine Astryx with [Modern Web Guidance](https://github.com/GoogleChrome/modern-web-guidance) (the `modern-web-guidance` skill) without the two rule sets fighting.

## Who decides what

| Concern | Decided by |
| :-- | :-- |
| Components, page frame, spacing, color, radius, typography, theme, light/dark mode | Astryx (components, props, tokens, theme) |
| Interaction and motion that Astryx components already provide (Dialog, Popover, Tooltip, Menu, SegmentedControl, Tabs, form controls) | Astryx |
| Platform features around or between components: view transitions, scroll-driven effects, deferred rendering, LCP/INP work, browser APIs | Modern Web Guidance |
| Browser support and fallbacks for those features | Modern Web Guidance, unless the project's `AGENTS.md` sets a browser support policy |

## Looking up guidance

- If the `modern-web-guidance` skill is installed, use it: search for the need, retrieve the matching guide, and apply its fallbacks.
- Otherwise use its CLI: `npx -y modern-web-guidance@latest search "<need>"`, then `npx -y modern-web-guidance@latest retrieve "<id>"`. The package is fetched from npm.
- Search with what you want to achieve, not project code.
- If neither is available, say so; do not present remembered API details as current guidance.

## Resolving conflicts

1. **Astryx has a component for it**: use the Astryx component. Do not rebuild it from native `<dialog>`, `[popover]`, or a custom element because a guide shows that pattern. Guides still apply when you own the markup: a swizzled component or a new domain component built from Astryx parts.
2. **The feature exists only as CSS**: `view-transition-name`, `::view-transition-*`, `content-visibility` with `contain-intrinsic-size`, `animation-timeline`, `@starting-style` on app-owned elements, and similar. These are the one exception to "no imported ad-hoc CSS":
   - Keep them in a single app-owned stylesheet, imported after the Astryx stylesheets.
   - Put only these platform properties in it. Color, spacing, radius, typography, and `:root` overrides still go through components, tokens, and the theme.
   - Take durations and easing from Astryx motion tokens (`--duration-*`, `--ease-*`) so the theme's tempo still applies.
   - Attach classes through a component's `className` or `ref`. Read the component's props first; when a component does not accept one, wrap it in a component that does (Stack components do), not in a raw `<div>`.
   - `astryx doctor` reports this import as a styling warning. Expect it, and name the file as an exception in the completion note. A doctor failure still blocks delivery.
3. **The feature is a JavaScript API** (`startViewTransition()`, `scheduler.yield()`, and so on): call it from the component that owns the state change, with the guide's feature detection and fallback. In React, apply the state update synchronously inside the transition callback (for example with `flushSync`) so the new state is captured.
4. **Motion**: Astryx components already handle reduced motion. Any motion you add follows the guide's `prefers-reduced-motion` rules. Inside a view-transition scope, turn off a library's own enter animation (for example a chart's) so two animations do not overlap.

## Browser support policy

Guides assume Baseline Widely available features need no fallback and require the documented fallback for anything newer. When a project targets a narrower or wider set of browsers, record the policy in its `AGENTS.md` (see `assets/AGENTS.frontend.md`) instead of deciding per change.
