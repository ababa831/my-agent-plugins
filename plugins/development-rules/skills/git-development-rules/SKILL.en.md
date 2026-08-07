# Shared Git Development Rules

- Follow [Conventional Commits](https://www.conventionalcommits.org/) for commit messages.
- Keep each commit focused on one purpose and exclude unrelated changes.
- Do not commit or push directly to `main`; merge changes through a pull request from a working branch.
- Use TDD by default, adding or updating the relevant tests before implementation.
- Before completion, run the tests, linter, and formatter defined by the repository.
- Maintain the Japanese README as `README.md` and the English version as `README.en.md`.
- Do not commit secrets, credentials, or personal information.
- Base ambiguous implementation decisions on the existing code and official documentation.
- Fix the root cause instead of applying a workaround, and avoid unnecessary complexity.
- Prioritize the outcome the requester actually needs instead of over-optimizing implementation details.
- If constraints make the requested outcome difficult, do not relax them unilaterally. Present feasible options and their trade-offs, then ask the requester to decide.
- Record repository-specific rules in that repository's `AGENTS.md`.
