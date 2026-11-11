# Frontend Project Context

> Adapt this file to the target repository. Keep only facts and constraints grounded in the actual codebase.
> In an Astryx project, run `astryx init --features agents` first; it writes the version-matched Astryx rules between `<!-- ASTRYX:START -->` and `<!-- ASTRYX:END -->`. Do not edit or copy that block here.

## Project facts

- UI phase: `<EXPLORE | STABILIZE | PRODUCTION>`
- Frontend root: `<path>`
- Design system: `<Astryx @astryxdesign/core x.y.z | other: name>`
- Astryx CLI invocation: `<npx astryx | npm run astryx -- | pnpm astryx>`
- Theme: `<@astryxdesign/theme-neutral | custom theme module path>`
- Styling system: `<StyleX (xstyle) | Tailwind | CSS variables only>`
- App-owned wrappers and swizzled components: `<path>`
- Web platform stylesheet (CSS-only platform features, if any): `<path, e.g. src/platform.css>`
- Browser support policy: `<Baseline Widely available (default) | Baseline <year> | specific browsers and versions>`
- Typecheck command: `<command>`
- Lint command: `<command>`
- Test command: `<command>`
- Visual verification: `<astryx doctor --built <dir> / Storybook / browser check / screenshot test>`

## Repository-specific constraints

- `<constraint that is specific to this repository>`
- `<constraint that is specific to this repository>`

General frontend and Astryx guidance comes from the `frontend-ui-development` skill and the generated Astryx block. Do not duplicate it here.
