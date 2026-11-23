# Formal Verification Project Context

> Adapt this file to the target repository. Keep only facts and constraints grounded in the actual codebase.

## Project facts

- Formal methods used: `<Lean 4>`
- Verification level: `<Level 1 (spec & invariants) | Level 2 (executable oracle + differential testing) | Level 3 (direct impl)>`
- Specs directory: `<path, e.g. specs/>`
- Lean toolchain file: `<path, e.g. specs/lean-toolchain>`
- Build & soundness check command: `<e.g. cd specs && lake build --wfail>`
- Axiom audit command: `<e.g. lean-action axiom-audit / cd specs && lake env lean Specs/Audit.lean (allowlist check)>`
- Differential test command (if Level 2): `<e.g. pytest tests/differential/>`
- Allowed axioms: `<propext, Classical.choice, Quot.sound>`

## Critical invariants & scope

- `<invariant 1: module, theorem name, and plain-language contract>`
- `<invariant 2: module, theorem name, and plain-language contract>`

## Modeling boundaries & assumptions

- `<e.g. monetary amounts modeled in integer minor units (JPY/cents); floating-point rounding is outside the model>`
- `<e.g. SQL NULL mapped explicitly via Option>`

General Lean 4 verification principles come from the `lean4-formal-verification` skill. Do not duplicate them here.
