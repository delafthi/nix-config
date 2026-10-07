---
description: Evidence-based review of files, the current change, or a PR; read-only
agent: plan
subtask: false
---

# Review code

Structured review of the target from `$ARGUMENTS`. Every finding must trace to
code you read. This command never moves the working copy and never writes to a
change.

Read the `code-review` skill at `skills/code-review/SKILL.md` for the lane
threshold, the evidence rule, the severity rubric, the merge rules, and the
output shape. It owns that machinery; do not restate it here.

## Before You Start

Check for existing context:

- `CONTRIBUTING.md` — conventions the review must not report as a defect
- `CONTEXT.md` at root — domain terms and boundaries
- `docs/` — architecture decisions in the area you're touching
- Component `README.md` or codedocs — patterns, decisions

Use established language. Don't re-litigate ADRs.

## Target selection

Pick one target in this order. Do not widen it.

1. The first token of `$ARGUMENTS` is a bare number (`123`) or `#` + number
   (`#123`) — PR mode. Strip the `#`. Confirm with `gh pr view <number>` before
   anything else; if it fails, report the blocker and stop. Never guess a number
   into PR mode.
2. `$ARGUMENTS` is not empty — every token is a path. A directory expands to
   the files under it, recursive. A missing or unreadable path is a blocker:
   list it and keep reviewing the rest.
3. `$ARGUMENTS` is empty — current Jujutsu change (`@`). If `jj diff` reports
   nothing, say `working copy is empty` under `## Blockers` and stop.

Embedded C/C++ anti-pattern review belongs to `/review-embedded`, which owns
the MISRA, CERT, and RTOS knowledge bases. Severity bands, merge discipline,
and report shape are shared between the two commands, and a command file cannot
read a sibling command, so they live in the `code-review` skill that both load.
Do not re-derive any of it here.

## PR mode

Read the PR from the remote. Never move the working copy to reach it:

```console
gh pr view <number>
gh pr diff <number> --name-only
gh pr diff <number>
```

For every hunk you mean to flag, read the whole enclosing function or type.
Take surrounding context from the base-revision files already in the tree.

Never run `gh pr checkout`, `jj new`, `jj edit`, `jj abandon`, or `jj squash`
here. The repo is colocated, so a PR checkout moves git HEAD out from under
jj, and `main..@` then spans the user's own unpushed work — abandoning that
set destroys it. `/pr` owns working-copy moves.

Only on an explicit go-ahead, and only when a finding needs code the diff does
not carry:

- `jj git fetch`, then read the head bookmark
- `jj workspace add`, to run the project's checks in a second working copy
- `jj undo`, to recover anything the user changed while this review ran

Read the jj skill for remote bookmark names, revsets, and undo.

## Current change mode

Scope is the working-copy diff and nothing else:

```console
jj status
jj diff
```

Unchanged files are out of scope. `jj status` names conflicts; report them,
resolve none.

## Parallelization (conditional)

Dispatch rule: the `code-review` skill's `## Parallelization`. When it calls for
subagents, one per lane, four lanes:

- Lane A — security, auth, secrets, data handling
- Lane B — correctness and core logic
- Lane C — architecture, performance, maintainability
- Lane D — tests, docs, meaningful style deviations

## Priority

When the list is long enough that order carries information, keep the highest
band first.

1. Security
2. Correctness
3. Performance
4. Maintainability
5. Testing
6. Documentation
7. Style (only meaningful deviations)

## Gotchas

- `gh pr diff <number>` and `gh pr view <number>` are allowlisted;
  `gh pr checkout` and every mutating `jj` subcommand prompt. Prefer the
  read-only form.
- `jj diff` already reports the working-copy diff in git format; `--git -r @`
  adds nothing.
- Keep change IDs, not commit IDs, in notes. Read the jj skill for revision
  syntax, revsets, and undo.
- `gh` unauthenticated: stop and report `gh auth login` as the ready command.

## Output format

The `code-review` skill owns the report shape, the numbering, and the
file grouping. This command's deltas:

- `## Summary` Target is `<paths | @ | PR #n>`.
- Zero issues: `No actionable issues found`.
