---
description: Add or extend tests in the project's existing style, then run them - "write tests for X", "add coverage for Y". Reads the nearest existing tests and finds the runner from the manifest before writing; never invents a second test style, never reports an unrun test as passing.
agent: build
subtask: true
---

# Write tests

Add or extend tests for the files in `$ARGUMENTS`; if empty, cover the
current working-copy change (`@`).

A test that never runs is worse than no test. Discovery is a gate, not a
suggestion.

## Before You Start

Check for existing context:

- `CONTRIBUTING.md` — test placement and naming conventions
- `.editorconfig`, lint configs — formatting the test file must pass
- `CONTEXT.md` at root — domain terms and boundaries
- `docs/` — architecture decisions in the area you're touching
- Component `README.md` or codedocs — patterns, decisions

Use established language. Don't re-litigate ADRs.

## Read gate

Two gates. Both pass before the first line of a test is written.

- Runner gate: name the test command, read from `flake.nix`, `justfile`,
  `Makefile`, `package.json` scripts, `Cargo.toml`, `pyproject.toml`,
  `go.mod`, or CI config. A command from memory is not a runner.
- Style gate: open the two nearest test files. Copy their layout, fixture
  use, naming, and assertion style. Never introduce a framework, layout, or
  helper the project does not already use.

No runner found, or no test file near the target? Report it under
`## Blockers` and stop. Do not scaffold a test framework.

## Truthfulness

- Run the new tests before reporting. Report the actual result — counts and
  failures, not "tests added".
- A test you did not execute is reported unrun, with the command needed to
  run it. Never present an intended result as an observed one.
- Confirm the new test appears in the runner output. A file the runner
  skips or filters out is not a passing test.
- A test that fails against the code it covers is a finding. Report the
  failure. Do not weaken the assertion, loosen the fixture, or skip the case
  to reach green.
- A failure already present in the baseline is reported as pre-existing, not
  as caused by this change.

## Workflow

1. Pass `## Read gate`. Resolve the narrowest runner invocation that selects
   one test file or one test name.
2. Run it before adding anything. The baseline decides whether a later
   failure is yours.
3. Map the changed code to risk: branches, boundaries, and error paths the
   diff introduced. Read the code, not the diff alone.
4. Add or extend tests inside the existing structure. Create a new test file
   only when the target has no home in the current layout.
5. Run the narrow command. Iterate until green, or until the failure is
   understood and reported under `## Blockers`.

## What not to test

Test behavior a caller can observe. These are the mistakes worth naming:

- Asserting on the mock — that the stub was called proves the wiring, not
  the behavior. Assert the returned value or the emitted output instead.
- Asserting an implementation detail — private state, call order, or a
  helper's return that only the implementation consumes. A rename breaks it
  and no bug is caught.
- Tautology — a test that re-asserts its own fixture, or that passes before
  the change under test. Break it on purpose and watch it fail.
- Over-mocking — mocking the unit under test, or every collaborator, tests
  the mock setup. Keep one real object wherever the seam allows it.
- A snapshot diff nobody reads. A snapshot that changes on every run is a
  deleted assertion.

## Rules

- Deterministic. Control clock, randomness, and network through the
  project's existing fixture or seam, not through a bespoke one.
- One behavior per test. Name it after the behavior, not the function.
- Skip trivial getters, generated code, third-party internals, and code the
  diff did not touch.
- Comments only where the setup or the assertion would surprise a reader.

## Not this command

- A failing test of unknown cause, or a bug to find first — that is the
  `debugging-and-error-investigation` skill. It owns reproduction and the
  red-to-green loop; this command owns green tests for known behavior.
- New behavior still being designed — that is feature work. Test what exists.
- Test-quality defects in a change — that is `/review`.

## Gotchas

- Narrow commands are the inner loop; the full suite is the final check.
- A helper or fixture shared across the suite belongs with the existing
  shared helpers, not inside the new test file.
- `jj diff` and `rg` with arguments are allowlisted; most test runners are not
  and will prompt. That is expected, not a reason to skip the run.

## Output format

Markdown, inline in the conversation. Do not paste the test bodies.

Use this output shape:

```md
## Summary
- Scope: ...
- Actions: ...
- Runner: <command, and the file that declares it>

## Blockers
- <none | no runner found | baseline already red>

## Result
- Test files changed: ...
- Behaviors covered: ...
- Baseline: <command> -> <result>
- Run: <command> -> <counts, or failures>
- Unverified: <what was not run, and why>
```
