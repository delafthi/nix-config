---
description: Write tests
agent: build
subtask: true
---

# Write tests

Create tests for files in `$ARGUMENTS`; if empty, cover current working-copy changes (`@`).

## Before You Start

Check for existing context:

- `CONTRIBUTING.md` — contribution guidelines and style guide
- `.editorconfig`, lint configs — formatting conventions
- `CONTEXT.md` at root — domain terms and boundaries
- `docs/` — architecture decisions in the area you're touching
- Component `README.md` or codedocs — patterns, decisions

Use established language. Don't re-litigate ADRs. Mirror existing test style.

## Workflow

1. Detect test stack, folder layout, naming conventions, fixtures/helpers.
2. Map changed behavior and risk areas before writing tests.
3. Add or extend tests in existing structure; create new test files only when needed.
4. Prefer fast unit tests; use integration tests for critical boundaries.
5. Run narrowest relevant test command first, then broader suite if needed.

## Coverage targets

- Happy path and expected outputs
- Edge cases and boundaries
- Invalid input and error handling
- Integration boundaries (mock/stub external systems as needed)

## Rules

- Deterministic, isolated, readable
- One behavior per test case
- Assert observable behavior, not internals
- Specific assertions over snapshot-only checks
- Comments only for non-obvious setup/logic
- Skip trivial getters/setters, generated code, third-party internals
- Avoid network, clock, randomness unless controlled

## Output

- Runnable test files in project layout
- Required imports/setup only
- Keep suite concise while covering meaningful risk

## Output consistency

- Return one final summary with: test files changed, behaviors covered, and command used to run tests.

Use this output shape:

```md
## Summary
- Scope: ...
- Actions: ...

## Blockers
- <none|details>

## Result
- Test files changed: ...
- Behaviors covered: ...
- Test command: ...
```
