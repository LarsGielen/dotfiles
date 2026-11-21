# Code conventions

- Follow the existing project’s language, formatting, architecture, and testing conventions. Prefer consistency over personal preference.
- Write clean, simple, readable code. Make the smallest change that fully solves the requested problem.
- Keep functions focused and names descriptive.
- Use clear, complete variable names; avoid unnecessary abbreviations and cryptic shorthand.
- Prefer straightforward control flow over clever or overly abstract solutions.
- Reuse existing utilities and patterns when appropriate; do not duplicate logic without a clear reason.

# Comments and documentation

- Write comments to explain *why*, not to restate *what* the code does.
- Keep comments concise, accurate, and current. Remove misleading, redundant, or obsolete comments.
- Document non-obvious public APIs, important assumptions, edge cases, and meaningful trade-offs.
- Do not add boilerplate comments to every function or obvious code.

# Dependencies and generated files

- Do not add, upgrade, or remove dependencies without asking first.
- Do not modify generated, vendored, lockfile-only, or build-output files unless explicitly requested or required by an approved dependency change.

# Safety and scope

- Preserve existing user changes. Do not overwrite, revert, reformat, or alter unrelated work.
- Do not use destructive commands unless explicitly requested.
- Ask before changes with significant product, security, data, privacy, database, or public-API implications.
- Do not expand the task scope without explaining why and getting approval when the expansion is material.

# Quality checks

- Validate changes with the most relevant available checks, such as targeted tests, type checks, linting, or a build.
- Do not claim a check passed unless it was actually run.
- If validation cannot be run, state what was not run and why.
- Handle errors and edge cases at appropriate boundaries; do not silently swallow failures.
