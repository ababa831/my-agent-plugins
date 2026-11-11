# Web platform features with Astryx

Use this reference when an Astryx UI needs a web platform feature that Astryx components and props do not express: view transitions, scroll-driven animations, entry/exit animations on app-owned elements, `content-visibility`, loading priority, or newer browser APIs. It explains how to combine Astryx with [Modern Web Guidance](https://github.com/GoogleChrome/modern-web-guidance) (the `modern-web-guidance` skill) without the two rule sets fighting.

## Who decides what

| Concern | Decided by |
| :-- | :-- |
| Components, page frame, spacing, color, radius, typography, theme, light/dark mode | Astryx (components, props, tokens, theme) |
| Interaction and motion that Astryx components already provide (Dialog, Popover, Tooltip, Menu, SegmentedControl, Tabs, form controls) | Astryx |
| Platform features around or between components: view transitions, scroll-driven effects, deferred rendering, LCP/INP work, browser APIs | Modern Web Guidance |
| Browser support and fallbacks for those features | The project's browser support policy in `AGENTS.md`; Modern Web Guidance's defaults when there is none |

## Looking up guidance

- Use the `modern-web-guidance` skill when it is installed. It searches and retrieves guides through its own CLI (`modern-web-guidance` on npm).
- If the skill is not installed, do not fetch and run the CLI yourself. Tell the user it is missing and how to install it (see `docs/plugins.md` in this plugin's repository), then continue, and name the platform-feature choices you could not check against a guide.
- The CLI sends search queries to Google as usage telemetry. Write queries as the generic need (for example "animate dialog backdrop"), never project code, customer names, unreleased plans, or other confidential terms. Users can opt out with `DISABLE_TELEMETRY=1` in their environment.

## Resolving conflicts

1. **Astryx has a component for it**: use the Astryx component. Do not rebuild it from native `<dialog>`, `[popover]`, or a custom element because a guide shows that pattern. Guides still apply when you own the markup: a swizzled component or a new domain component built from Astryx parts.
2. **The feature exists only as CSS**: `view-transition-name`, `::view-transition-*`, `content-visibility` with `contain-intrinsic-size`, `animation-timeline`, `@starting-style` on app-owned elements, and similar. These are the one exception to "no imported ad-hoc CSS":
   - Keep them in a single app-owned stylesheet, imported after the Astryx stylesheets. The Astryx self-check leaves this file alone; it still replaces any other ad-hoc CSS.
   - It may hold what the feature and its guide's fallback need: the feature's properties, the `@keyframes` and `@supports` blocks it uses, and the `opacity` / `transform` values those animations run on. It must not change layout, spacing, color, radius, typography, or `:root` values; those still go through components, tokens, and the theme.
   - For time-based animations, take durations and easing from Astryx motion tokens (`--duration-*`, `--ease-*`) so the theme's tempo still applies. Scroll-driven animations follow scroll position instead: use `linear` easing and the duration the guide gives for browser compatibility.
   - Attach classes through a component's `className` or `ref`. Read the component's props first. When a component does not accept one, wrap it in a Stack that holds only that component, with no gap or padding, and check that the layout did not change. Do not wrap it in a raw `<div>`.
   - `astryx doctor` reports this import as a styling warning. Expect it, and name the file as an exception in the completion note. A doctor failure still blocks delivery.
3. **The feature is a JavaScript API** (`startViewTransition()`, `scheduler.yield()`, and so on): call it from the component that owns the state change, with the guide's feature detection and fallback. In React, the new state must be in the DOM when the transition callback returns:
   - For a local state change with data already loaded, apply the update synchronously inside the callback (for example with `flushSync`).
   - When the update fetches data, suspends, or navigates, finish loading before starting the transition; `flushSync` can capture a Suspense fallback as the new state. First check whether the project's React version or router has its own view transition support, and prefer it.
4. **Motion**: Astryx components already handle reduced motion. Any motion you add follows the guide's `prefers-reduced-motion` rules. Inside a view-transition scope, turn off a library's own enter animation (for example a chart's) so two animations do not overlap.

## Browser support policy

When the project's `AGENTS.md` records a browser support policy (see `assets/AGENTS.frontend.md`), follow it. Without one, use the guides' default: features that are Baseline Widely available need no fallback, and newer features need the guide's fallback. Baseline does not cover every browser or WebView a product may ship to, so when the project names specific targets, check the feature in those versions and add fallbacks they need.
