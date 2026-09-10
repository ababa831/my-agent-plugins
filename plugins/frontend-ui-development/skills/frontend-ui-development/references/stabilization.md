# Stabilization checklist

Use this reference when a prototype is becoming a long-lived implementation or when the user explicitly asks to clean up UI architecture. Do not run this audit mechanically for ordinary small changes.

Look for patterns that have actually become stable enough to justify cleanup:

- repeated UI with the same semantic role
- repeated colors, spacing, typography, radius, or shadow decisions
- duplicate generic primitives
- magic numbers that encode a shared rule rather than a truly local adjustment
- local layout hacks that compensate for a parent or shared-component problem
- components that have accumulated unrelated responsibilities
- accessibility issues in important interactions
- responsive behavior that depends on brittle offsets or one-off breakpoints
- styling APIs or variants that have become inconsistent

Refactor only where the evidence is strong enough to improve future changes. Avoid speculative abstraction.

Prefer the following order when several layers need work:

```text
shared visual decisions
    ↓
UI primitives
    ↓
feature/domain components
    ↓
page composition
```

After stabilization, use targeted validation for the affected surfaces. Do not broaden the cleanup beyond the requested scope without a concrete reason.
