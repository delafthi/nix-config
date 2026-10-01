---
description: Create or update a PR for the current change; asks before push
agent: build
subtask: false
---

# Create pull request

Open or update the PR for the working-copy change (`@`). `$ARGUMENTS` carries
optional hints: base bookmark, bookmark name, title.

Invoking `/pr` is not the request to push. Inspect and plan first; every repo
or remote write waits for an explicit go-ahead.

## Before You Start

Check for existing context:

- `CONTRIBUTING.md` — PR conventions, AI disclosure rules
- `CONTEXT.md` at root — domain terms for the scope
- `docs/` — architecture decisions behind the change
- `.github/pull_request_template.md` — body skeleton to fill

Use established language. With no template, mirror the titles of open PRs from
`gh pr list`.

## Inspect

Read-only; run without asking. In this order, since the first output names the
base and the fourth names the head bookmark.

```console
gh repo view --json defaultBranchRef
jj status
jj log -n 10
jj bookmark list
jj diff --from <base> --to @
gh pr list --head <bookmark> --state all --json number,url,state,title
```

Derive:

- change ID and description of `@`
- base bookmark from `defaultBranchRef`, never a guess
- head bookmark tracking `@`, from `jj bookmark list`
- candidate title and body from the diff, the description, `$ARGUMENTS`

## Plan

Decide in this order:

1. `/review` in PR mode can leave `@` on a checked-out PR. Confirm `jj status`
   shows the intended change before anything else.
2. No PR for the head bookmark: draft a title and body.
3. One open PR for it: draft the new title and body for `gh pr edit <number>`.
4. Only closed or merged PRs for it: draft a new PR, not an edit.
5. `@` shows `(no description set)`: draft the message from the diff and put it
   in the confirmation. Never run `jj describe` on your own text.
6. No bookmark on `@`: name one, or take the name from `$ARGUMENTS`. Derive it
   from the scope and the short change ID, e.g. `<scope>-<short change id>`.
   Leave an existing bookmark that tracks `@` alone.

## Confirm before writing

Every command below writes to the repo or the remote. Show the plan with these
exact commands, then stop and wait for an explicit go-ahead:

- `jj describe -m "<message>"` when `@` has no description
- `jj bookmark set <name>` when `@` has no bookmark
- `jj git push --bookmark <name>`
- `gh pr create --head <name> --base <base> --template <file> --title "<title>"`
  with the body from `--body-file <file>`; `--body-file -` reads stdin
- `gh pr edit <number> --title "<title>" --body-file <file>`

On approval, run only the steps the plan calls for, in that order. If the user
asked to prepare rather than push, stop after the plan. Never add
`--allow-private` yourself.

## Gotchas

- `jj log` takes `-n` / `--limit`, not `-l`. When unsure of a flag, read
  `--help` before running.
- The repo is colocated, so git HEAD is detached and `gh` has no current
  branch. Always pass `--head <bookmark>` to `gh pr create` and
  `gh pr list`. On `gh pr list` it takes a bare bookmark name, no
  `<owner>:<branch>`.
- `git.private-commits` refuses a change described `wip: ...` or
  `private: ...`. Renaming that description is the user's call.
- `git.sign-on-push` signs on push with a `gpg` backend, so `jj git push` can
  stop for a passphrase. Expect the prompt; do not retry it unattended.
- `gh` unauthenticated: stop, and report `gh auth login` as the ready command.
- Read the jj skill for bookmark, push, and revset syntax.

## Output format

Use this output shape:

```md
<title> (#<number|draft>)

<body>

<url>

## Blockers
- <none|details>
```
