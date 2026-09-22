# Evidence-Driven Engineering

## Goal

Make agent work trustworthy through evidence rather than confidence.
Close the loop between a claim and the running system, and leave the next agent a way to repeat the same verification.
This skill provides defaults for judgment; it is not a fixed procedure.

## Scope

- Respect explicit task instructions, applicable `AGENTS.md` files, and repository constraints first.
- Match the weight of checks to the task. An explanation needs code evidence; a behavior change needs a running check; a typo needs a check of the affected document and the diff.
- Building verification tooling, maintaining a feature map, and evaluating skills are conditional work, not prerequisites for every task.
- Fixing root causes, basing decisions on existing code and official documentation, and not relaxing constraints unilaterally follow `git-development-rules`; they are not repeated here.

## Back claims with evidence

- Before diagnosing a cause, read the affected implementation and trace the relevant calls or data flow. Cite the code and observations you relied on, and mark an untested explanation as a hypothesis.
- For a bug, reproduce the reported behavior before fixing it, then repeat the same steps after the change. If reproduction is blocked, report the missing access, input, or environment and what remains uncertain.
- Exercise the interface users depend on: the UI, API, CLI, or device flow. A passing build or type check does not prove runtime behavior.
- Match evidence to the claim. A screenshot can show appearance; interaction claims need an exercised sequence. Performance claims need comparable measurements, traces, or profiles.
- Check correctness and engineering quality (maintainability, efficiency) separately.

## Make verification repeatable

- Discover and use the repository's actual setup, run, test, and diagnostic tools. Never invent a verification command.
- If a feature map exists (a mapping from a user-visible feature to its entry point, prerequisites, navigation steps, relevant code, and expected result), consult it and confirm the relevant entry against the running app.
- If agents repeatedly get lost reaching a feature, add the verified route to existing project documentation. Do not map the whole application for one small fix.
- When it fits the task, turn a recurring manual check into a reusable procedure. Record setup, inputs, expected outcomes, evidence locations, and cleanup, and keep it current when the product changes.
- When building new verification tooling, run it first in an observable environment such as a local machine, and inspect its actions and failures before using it unattended.

## Treat the codebase and history as memory

Agents learn from the examples they find. Today's shortcut becomes tomorrow's convention.

- Before implementing, read nearby code and documented conventions. When the reason for a pattern is unclear, check the history.
- Validate a pattern before copying it. Frequency does not make it correct.
- If a workaround is unavoidable, document its limitation and removal condition.
- Remove temporary scaffolding introduced by your work. Keep explanations of non-obvious constraints, but do not turn a one-off review remark into a permanent comment or universal rule.

## Turn corrections into durable constraints

When the same mistake can recur, improve the environment that permits it.
Choose the smallest effective mechanism: design it out, detect it with types, lint, or CI, write a rule, or capture a skill.
Keep the supported implementation path (canonical helpers and modules) healthy instead of adding competing implementations.
See [references/durable-constraints.md](references/durable-constraints.md) for criteria and details (Japanese).
Propose architectural changes beyond the task as a scoped follow-up.

## Hand off reviewable work

- For a non-trivial task, state the problem, material assumptions, and what observation would demonstrate success. Proceed with routine choices already covered by the request.
- Explain consequential decisions using the relevant code and observed behavior. Give reviewers enough context to judge the result without reconstructing your session.
- Keep independent changes separable. In commits and pull requests, explain why behavior changed so the history supports investigation and reversal.
- Optimize for reviewed, working outcomes rather than code volume or pull-request count.

## Conditional work

- When delegating to other agents or working in parallel, see [references/delegation.md](references/delegation.md).
- When creating or changing agent instructions, skills, or verification procedures, see [references/evaluating-instructions.md](references/evaluating-instructions.md).
- Typical failures and expected behavior are in [references/examples.md](references/examples.md); they also serve as evaluation cases.

## Completion report

Report the result, the checks actually performed, accessible evidence, and any remaining limits, in proportion to the task.
Distinguish observed results from hypotheses, and results reported by a delegate from checks you performed yourself.
