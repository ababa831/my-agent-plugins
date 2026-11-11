# Astryx reference

Use this reference when building or changing UI in a project that uses, or is about to adopt, [Astryx](https://github.com/meta/astryx) (`@astryxdesign/*`). It summarizes the rules Astryx itself ships to agents (`astryx init --features agents` and `astryx docs principles`). When the project has a generated `<!-- ASTRYX:START -->` block, that block matches the installed version and wins over this file.

## Where answers come from

| Source | Use it for | Notes |
| :-- | :-- | :-- |
| Astryx MCP (`astryx` server, `https://astryx.atmeta.com/mcp`) | `search(query)` to find components, doc topics, and templates; `get(name)` for props, examples, and the install command. `get` takes an optional section for large topics such as `theme`. | Describes the latest published release. Works without a project. |
| Project CLI (`astryx …`, or `npm run astryx -- …`) | `build`, `template`, `component`, `docs`, `theme`, `doctor`, `upgrade`. | Answers for the version the project installed. Prefer it when it disagrees with the MCP. |

Read docs through these tools, not by opening files under `node_modules`. If the CLI path fails, add the npm script alias the Astryx README recommends:

```json
"scripts": { "astryx": "node node_modules/@astryxdesign/cli/clients/cli/bin/astryx.mjs" }
```

## Adoption

Astryx requires React 19+, and the CLI requires the Node.js version in its `engines.node` (22.13.0+ for 0.7.x). Check both before installing.

In a new project, or one without `@astryxdesign/core`:

```bash
npm install @astryxdesign/core @astryxdesign/theme-neutral @stylexjs/stylex
npm install -D @astryxdesign/cli
npx astryx init --features agents
```

In a project that already has `@astryxdesign/core`, install only the CLI, at the installed Core version:

```bash
npm install -D @astryxdesign/cli@<installed core version>
npx astryx init --features agents
```

Run `npx astryx` only after `@astryxdesign/cli` is installed; otherwise npx may fetch an unrelated package named `astryx`. Use `npx @astryxdesign/cli <cmd>` when unsure.

Either way, the app needs these once, or components render unstyled or unthemed (the Core README's Quick Start shows each framework):

1. Import the stylesheets in this order: `@astryxdesign/core/reset.css`, `@astryxdesign/core/astryx.css`, then the theme's `theme.css` (for example `@astryxdesign/theme-neutral/theme.css`).
2. Wrap the app in `<Theme theme={…}>` from `@astryxdesign/core/theme` (for example `neutralTheme` from `@astryxdesign/theme-neutral/built`), and in `<LinkProvider component={…}>` from `@astryxdesign/core/Link` with the framework's link component.
3. Put each page inside `AppShell` from `@astryxdesign/core/AppShell`, which Astryx documents as the root wrapper for every page. Some page templates scaffold only the page content without it. Without a shell nothing paints the page background, so switching `Theme`'s `mode` changes the components but leaves the page behind them in the other mode.

Pick another theme with `astryx theme add <slug>`; see `astryx docs theme`. After a dependency bump, run `astryx upgrade --from <old version> --apply` so codemods and the agent-docs block stay current.

Do not adopt Astryx for a few components inside a project that already standardizes on another design system. Migrate whole surfaces when the user asks for a migration.

## Page workflow

1. `astryx build "<idea>"` names the template to scaffold from, two alternatives, and the blocks and components for the parts it lacks.
2. `astryx template <name> <path>` scaffolds it. Keep its frame, gap, and padding; replace the content.
3. `astryx template <Block>` for parts it lacks; `astryx component <Name>` (or MCP `get`) to read props before using a component.

When changing an existing page, keep it: skip step 2 and add blocks or components inside its sections. Read `astryx docs layout` before changing a template's frame.

## Rules

- Use components for everything they cover. No raw `<div>` for layout or spacing; components handle it.
- Page layout is frame-first: choose the shell and budget regions before writing content.
- Dense data renders as rows (Table, List/Item), edge to edge with dividers. Card is for widgets, galleries, and settings groups. Badge is for counts and enumerated states; use StatusDot or Token for status.
- Style with component props first, then the project's configured styling system:
  - StyleX compiler wired: the `xstyle` prop with StyleX tokens.
  - Tailwind: utilities backed by tokens (`text-primary`, `bg-surface`), no arbitrary values such as `bg-[#fff]` or `p-[13px]`.
  - Neither: tokens through CSS variables (`var(--color-*)`, `var(--spacing-*)`, `var(--radius-*)`). Do not use `xstyle` or utility classes without their compiler; some templates need a StyleX compiler plugin (`astryx docs styling-overview`).
- No hardcoded hex or px values, no `style={{…}}` on raw elements, no imported ad-hoc `.css` or `@apply`. The one exception is a single stylesheet for web platform features that exist only as CSS; see `web-platform.md`.
- Palettes and custom colors go through the theme, never `:root` overrides. `astryx theme add <slug>` imports a theme; `astryx theme eject <slug>` only forks its source.
- Form inputs are controlled (`value` + `onChange`).
- Navigation uses `useLinkComponent()` so the app's router plugs in through `LinkProvider`; no hardcoded `<a>` for in-app links.
- Do not invent props. Read the component docs first.
- Import each export from the path `astryx component <Name>` prints (for example `@astryxdesign/core/VStack`).

## When Astryx does not cover a need

1. `astryx search "<need>"` (or MCP `search`) and `astryx discover <words>` for integrations.
2. Compose existing components and tokens.
3. If a component must behave differently, `swizzle` ejects its source into the project to own; keep using tokens inside it.
4. A new domain component is built from Astryx components and tokens, not from raw elements with copied values.

## Self-check and review

Before delivering, re-read each changed file and replace any raw `<div>`/`<span>`, `style={{…}}`, imported `.css`/`@apply`, or hardcoded `#hex`/`px` with the component or a token. Astryx measured that this re-read cuts leftover raw CSS several-fold on complex UIs.

If the project's CLI supports it (0.7.4+), run `astryx doctor --built <dir>` before delivering a build and do not deliver it while it fails.

For a review of whether a surface uses Astryx well, follow `astryx docs is-my-code-good`: learn the app context and sibling surfaces first, pick the smallest review that answers the question, and back every finding with evidence.
