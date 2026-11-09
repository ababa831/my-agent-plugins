# Stabilization checklist

Use this reference when a prototype is becoming a long-lived implementation or when the user explicitly asks to clean up UI architecture. Do not run this audit mechanically for ordinary small changes.

Look for patterns that have actually become stable enough to justify cleanup:

- raw elements, `style={{…}}`, ad-hoc CSS, or hardcoded hex/px that an Astryx component or token already covers
- hand-built generic components that duplicate an Astryx component (check with `astryx search` or MCP `search`)
- pages that drifted from their template's frame, gap, or padding
- colors or palettes set outside the theme, such as `:root` overrides
- dense data wrapped in Cards instead of Table or List/Item rows
- props used without reading the docs, or imports from paths other than the one `astryx component <Name>` prints
- domain components that have accumulated unrelated responsibilities
- accessibility issues in important interactions
- responsive behavior that depends on brittle offsets or one-off breakpoints

Refactor only where the evidence is strong enough to improve future changes. Avoid speculative abstraction.

Prefer the following order when several layers need work:

```text
theme / tokens
    ↓
Astryx components (swizzled copies included)
    ↓
feature/domain components
    ↓
page composition on templates
```

For a structured review, follow `astryx docs is-my-code-good`. After stabilization, use targeted validation for the affected surfaces, including `astryx doctor --built <dir>` when the project's CLI supports it. Do not broaden the cleanup beyond the requested scope without a concrete reason.
