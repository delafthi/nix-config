---
name: jj
description: Prevent common Git-vs-Jujutsu mistakes. Use when operating in Jujutsu-managed repos.
---

# jj

Use Jujutsu-native workflow. Prevent git-habit errors.

## Use When

- Operating in repositories managed with `jj`.
- Translating git intent into `jj` commands.
- Fixing mistakes caused by commit-first git habits.

## Bird's Eye View

- Working copy IS a commit. No staging area — edits are auto-amended into the
  current change on the next `jj` command.
- Two identities per change: stable change ID (survives rewrites; use in
  revsets) and commit ID (content hash, same as git hash).
- No branches. Changes stack into a DAG; bookmarks point at commits and replace
  git branch refs. Use `bookmark`, not `branch`.
- Rewriting is normal. Moving, folding, and splitting content between changes is
  routine; rebasing a change auto-rebases its descendants.
- Conflicts are recorded states, not blockers — never prevent a commit or
  rebase.
- Operation log records every operation, so nothing is destructive. Any mistake
  can be rolled back.
- Files always tracked — no `git add`.

## General Workflow

Start a fresh change, work, then close it out — never "edit then commit".

- `jj new` → make edits (auto-snapshotted) → close the change:
  - `jj describe -m "..."` — done, keep working on this change
  - `jj commit -m "..."` — describe + start the next change
- Need work split into several changes? `jj split` breaks one change in two.
- To fold changes back down (or push edits into an earlier change):
  - `jj squash` — merge current change into its parent
  - `jj squash [<paths>]` — fold only specific files; `--from <rev> --into
    <rev>` moves edits into any earlier editable (mutable) change
  - `jj absorb [<paths>]` — auto-splits the current change and absorbs each hunk
    into the closest mutable ancestor where that line was last touched (like
    `git absorb`)
  - `jj diffedit` — edit an earlier change's diff directly

Rule of thumb: prefer `jj new` + `jj squash` over `jj edit` for getting edits
into a specific older change — UNLESS another change sits in between that edits
nearby sections of the same files, so squashing down would diff across it (and
risk conflicts). Then use `jj edit <rev>` to move the working copy onto that
change and edit it directly. To resume where you were, `jj edit` back to your
original change ID.

## Conflicts

Conflicts are recorded states, not blockers — commits and rebases proceed even
with unresolved conflicts. `jj st` lists them.

- Try `jj resolve` first — auto-merges with `mergiraf`.
- If `mergiraf` leaves conflicts (or you disagree with its merge), edit the
  conflicted files manually.
- Verify the result with `jj diff`, then run checks (typecheck, tests, format)
  and fix anything the merge broke.
- Manual resolution: check history and the conflicting files; read commit
  messages, PRs, tickets to recover original intent; preserve both intents
  where possible — if incompatible, pick the one matching the merge's goal and
  note the trade-off.

## Command Reference

### Inspect

- `jj st` — status: current change, conflicts, uncommitted edits
- `jj log [<revset>]` — graph of current change + ancestors (or any revset)
- `jj diff [<paths>]` — changes in current change (add `--tool` for external)
- `jj show <rev>` — commit + its diff
- `jj obslog <rev>` — how a change evolved across rewrites
- `jj op log` — operation history (why history looks the way it does)
- `jj interdiff --from A --to B` — how two changes' diffs differ
- `jj file list/show/annotate/chmod/search` — per-file inspection

### Create & Edit Changes

- `jj new [<parents>]` — new empty change (multiple parents = merge)
- `jj edit <rev>` — make an existing change the working copy
- `jj describe -m "..."` — set message; `jj commit -m "..."` = describe +
  `jj new`
- `jj restore [<paths>] [--from <rev>]` — discard working-copy edits (or pull
  content from another rev)
- `jj split` — split current change in two via diff editor
- `jj diffedit [<rev>]` — touch up a change's diff with an editor
- `jj new --insert-after A --insert-before D` — insert empty change into a stack
- `jj file track/untrack` — start/stop tracking paths

### Restructure History

- `jj squash` — fold current change into its parent (limit to `[<paths>]` to
  fold only some files)
- `jj squash --from <rev> --into <rev>` — move changes between arbitrary changes
- `jj absorb` — auto-absorb current change's hunks into the closest mutable
  ancestor that last touched each line
- `jj rebase -r <rev> -A <new-parent> [-B <new-child>]` — move a change; use
  `-s`/`-b` for a change + descendants/ancestors
- `jj abandon [<rev>]` — drop a change, rebasing descendants onto its parents
- `jj parallelize` — turn a linear chain into sibling changes (merge workflow)

### Bookmarks & Tags

- `jj bookmark list / create <name> / set <name> / move --to <rev>`
- `jj bookmark delete / forget / rename / track / untrack / advance`
- `jj tag list / set / delete`

### Remotes (Git integration)

- `jj git remote add <name> <url> / list / remove / rename / set-url`
- `jj git fetch [--remote <name>]` — bring in remote changes
- `jj git push --bookmark <name>` — push one bookmark (force-with-lease style
  safety checks)
- `jj git push --all` — push every bookmark/tag
- `jj git push --change <rev>` — push a change under a generated `push-*`
  bookmark; `--named name=@` for an explicit name; `--dry-run` to preview
- `jj git import / export` — sync with the underlying git repo
- `jj git colocation` — manage repo colocation with git

### Workspaces

- `jj workspace add <name>` — extra working copy (e.g. long build/test while
  editing)
- `jj workspace list / forget / rename / update-stale`

### Undo & Recovery

- `jj undo` — revert the last operation
- `jj op undo <op>` / `jj op restore <op>` — surgically revert/restore a
  specific operation from `jj op log`
- `jj restore` — discard working-copy edits
- `jj --at-op <op-id> <cmd>` — inspect repo as it was at an older operation
- `jj --ignore-working-copy <cmd>` — skip snapshot for fast/scripted calls

## Revsets

Most commands accept a revset: a functional expression selecting commits.
`jj log` accepts multi-commit revsets; commands like `jj edit` require exactly
one commit.

Symbols:

- `@` = current working copy; `@-` / `@+` = its parent / child; `@--` =
  grandparent.
- Commit ID prefix, change ID prefix, and bookmark/tag names resolve directly.
- `trunk()` = main-line head (default bookmark of `upstream`/`origin`).
- `bookmarks()`, `tags()`, `remote_bookmarks()` = named commit sets.

Operators (strongest to weakest):

- `::x` ancestors of `x` (incl. `x`); `x::` descendants; `x::y` between.
- `x..y` ancestors of `y` not in `::x` (≈ git's `x..y`); `x..` = "not on x".
- `~x` negation, `x & y` intersection, `x ~ y` difference, `x | y` union.
- `x-` parents, `x+` children.

Functions:

- `description(*glob*)`, `subject(...)`, `author(...)`, `mine()` — find by
  message/author.
- `mutable()` = commits jj rewrites; `immutable()` = the rest.
- `latest(x, n)`, `heads(x)`, `roots(x)`, `merge_point(x)`, `fork_point(x)`.
- String patterns: `exact:`, `glob:` (default), `regex:`, `substring:`, with
  `-i` for case-insensitive.

Examples:

- Parent of working copy: `jj log -r @-`
- All local work not pushed: `jj log -r 'remote_bookmarks()..'`
- Your stack: `jj log -r 'reachable(@, mutable())'`
- By author and message: `jj log -r 'author(mine) & description(*fix*)'`

Full reference: <https://docs.jj-vcs.dev/latest/revsets/> — verify unfamiliar
symbols with `jj help revsets`.
