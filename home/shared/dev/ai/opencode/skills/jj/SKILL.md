---
name: jj
description: Exact jj (Jujutsu) command syntax, revsets, and undo. Use when the user asks to commit, describe, squash, rebase, split, abandon, bookmark, push, fetch, undo, or inspect history with jj, or names "jj", "jujutsu", "change ID", "commit ID", "revset", "bookmark", "@", "@-", or "trunk()". Prefer jj over git in jj repos.
---

# jj

Use jj commands by exact syntax. When unsure, read `jj <cmd> --help`. Do not
assume any local jj config or plugins exist.

## Use When

- Working in a `jj`-managed repo.
- Turning a git intention into `jj` commands.
- Recovering from a git-habit mistake.

## Read-Only Commands Need No Prompt

Every other invocation asks the user first. Use these spellings:

```console
jj status
jj log
jj diff
jj show <rev>
jj root
jj bookmark list
jj git remote list
```

Write `jj status`, not the `jj st` alias: `jj st` is not allowlisted and will
prompt. `jj new`, `jj describe`, `jj commit`, `jj squash`, and `jj git push`
always prompt.

## Model

- The working copy is a commit. There is no staging area: edits are
  snapshotted into the current change by the next `jj` command. `git add` has
  no equivalent.
- Every change has two identities. The change ID survives rewrites, so it is
  the right handle for revsets and for returning to a change later. The commit
  ID is a content hash and changes on every rewrite.
- Bookmarks replace branches: `jj bookmark create <name> -r <rev>` creates,
  `jj bookmark set <name> -r <rev>` repoints, `jj bookmark move --to <rev>`
  repoints by current location. There is no checkout.
- Conflicts are recorded states, not blockers. Commits and rebases proceed with
  conflicts still present.

## Daily Workflow

Start a change, edit, describe it. Never "edit then commit".

```console
jj new
# edit files
jj describe -m "message"    # keep working on this change
jj commit -m "message"      # describe, then start the next change
```

`jj new` creates the change and makes it the working copy. `jj next` and
`jj prev` (repo aliases `nxt` and `prv`) move the working copy without a new
change.

To land edits on an older change:

1. Default: `jj new`, make the edit, then `jj squash --into <rev>`.
2. Use `jj edit <rev>` instead when a change in between touches nearby lines of
   the same file, so squashing down would diff across it.
3. Use `jj absorb` when hunks belong to different ancestors: it splits the
   working copy and moves each hunk to the closest mutable ancestor where those
   lines were last modified. Hunk placement is ambiguous when the lines were
   never modified in an ancestor; those hunks stay put.
4. Use `jj diffedit -r <rev>` to hand-edit a change's diff. Positional arguments
   to `jj diffedit` are filesets (paths), not revisions. When in doubt, run
   `jj diffedit --help`.

Return to the original change with `jj edit <change-id>` afterwards; the change
ID is stable across all of these rewrites.

## Conflicts

`jj status` lists conflicted files.

1. Run `jj resolve` first: mergiraf is configured as the merge tool.
2. For whatever mergiraf leaves, edit the files by hand. Recover the original
   intent from the change descriptions and the linked PR or ticket, then keep
   both intents where they are compatible. Where they conflict, match the
   goal of the merge and record the trade-off in the change description.
3. `jj diff` to verify, then run the project's checks (typecheck, tests,
   format) and fix what the merge broke.

Never abandon or rebase around a conflict to make it disappear.

## Command Reference

### Inspect

- `jj status` — current change, conflicts, snapshot state
- `jj log [-r <revset>]` — graph; `-r` selects the revset
- `jj diff [<paths>]` — working-copy diff; `--tool <name>`, or `--tool=:<name>`
  for a builtin format
- `jj show <rev>` — one change with its diff
- `jj root` — workspace root
- `jj obslog <rev>` — how a change evolved across rewrites
- `jj op log` — operation history
- `jj op show <op>` / `jj op diff <op>` — what one operation changed
- `jj interdiff --from <rev> --to <rev>` — how two changes' diffs differ
- `jj file list|show|annotate|chmod|search` — per-file inspection

### Create And Edit Changes

- `jj new [<parents>]` — new empty change as the working copy; several parents
  make a merge
- `jj edit <rev>` — make an existing change the working copy
- `jj describe -m "..."` — set the message, stay on this change
- `jj commit -m "..."` — describe, then start the next change
- `jj new --insert-after <rev>` / `jj new --insert-before <rev>` — insert an
  empty change into a stack; repo aliases `jj a` and `jj i`
- `jj restore [<paths>]` — discard working-copy edits. With no arguments this
  empties the working copy but keeps its description, unlike `jj abandon`.
- `jj restore --from <rev> [<paths>]` — pull content in;
  `--changes-in <rev>` undoes one change's content
- `jj split` — split the current change in two via the diff editor
- `jj diffedit -r <rev> [<paths>...]` — hand-edit a change's diff (use
  `--from/--to` for a comparison edit; paths use fileset syntax)
- `jj file track|untrack <paths>` — start or stop tracking paths

### Restructure History

- `jj squash` — move the working copy into its parent. The source is abandoned
  when it empties out, unless `--keep-emptied`.
- `jj squash [<paths>]` — same, limited to some paths
- `jj squash --from <rev> --into <rev>` — move edits between any two changes;
  `--into` is also spelled `--to`
- `jj absorb` — split the working copy, then move each hunk into the closest
  mutable ancestor where those lines were last modified
- `jj rebase -r <rev> -o <parent>` — move a change onto a new parent.
  Destination: `-o`/`--onto` reparent only, `-A`/`--insert-after` also rebase
  the target's descendants, `-B`/`--insert-before` insert ahead of the target.
  Source: `-r` the listed revisions only, `-s` those plus descendants, `-b` the
  whole branch relative to the destination. With no source flag it is `-b @`.
- `jj abandon [<rev>]` — drop a change, rebase descendants onto its parents
- `jj parallelize [<revsets>]` — turn a chain into sibling changes

### Bookmarks And Tags

- `jj bookmark list|create <name> -r <rev>|set <name> -r <rev>`
- `jj bookmark move --to <rev>` — repoint; `--from <rev>` selects by current
  location
- `jj bookmark rename` / `jj bookmark advance` — `advance` uses
  `revsets.bookmark-advance-to`, which this repo sets to `closest_pushable(@)`
- `jj bookmark track|untrack <pattern>`
- `jj bookmark delete` — push the deletion; `jj bookmark forget` — drop it
  locally
- `jj tag list|set|delete|track|untrack`

## Remotes

- `jj git fetch [--remote <name>] [--all-remotes]` — repo aliases `jj f` and
  `jj F`
- `jj git push --bookmark <name>` — push one bookmark; safety checks behave
  like force-with-lease
- `jj git push --all` — push every bookmark and tag
- `jj git push --change <rev>` — push a change under a generated bookmark name;
  `--named name=<rev>` picks the name, `--dry-run` previews
- `jj git remote add|list|remove|rename|set-url`
- `jj git import` / `jj git export` — sync with a colocated git repo
- `jj git colocation status|enable|disable`

## Workspaces

- `jj workspace add <name>` — extra working copy, e.g. for a long build while
  editing
- `jj workspace list|forget|rename|update-stale`

## Undo And Recovery

- `jj undo` — revert the last operation; `jj redo` — reapply it
- `jj op log` — find the operation ID
- `jj op revert <op>` — revert one earlier operation
- `jj op restore <op>` — make the repo state at `<op>` current again
- `jj --at-op <op-id> <cmd>` — inspect an older state; `--at-op` is an alias of
  `--at-operation`, and any unambiguous operation ID prefix works
- `jj --ignore-working-copy <cmd>` — skip the snapshot for fast or scripted
  calls

## Revsets

Most commands take `-r <revset>`; `jj log` accepts multi-revision revsets,
`jj edit` requires exactly one.

Symbols:

- `@` working copy, `@-` parent, `@--` grandparent, `@+` child
- commit ID prefix, change ID prefix, bookmark name, tag name
- `trunk()` main-line head; `bookmarks()`, `tags()`, `remote_bookmarks()`

Bare names resolve as tag, then bookmark, then commit ID. Force an ID with
`commit_id(<name>)` in scripts, where the same name may later become a bookmark.

Operators, strongest binding first:

- `x::` descendants of `x`; `::x` ancestors of `x`; both include `x` itself,
  and `::x` also includes `root()`
- `x..y` ancestors of `y` that are not ancestors of `x`, the same as git's
  `x..y`; `x..` means "not an ancestor of `x`"
- `x::y` descendants of `x` that are also ancestors of `y`, which is git's
  `--ancestry-path x..y`, not the path between `x` and `y`
- `~x` not in `x`; `x & y` in both; `x ~ y` in `x` but not `y`; `x | y` in
  either
- `x-` parents; `x+` children

`..` does not distribute over `|` on its left: `(a | b)..` equals `a.. & b..`,
not `a.. | b..`.

Functions:

- `description(<pattern>)`, `subject()`, `author()`, `mine()`
- `mutable()` — revisions jj rewrites; `immutable()` — the rest
- `roots(x)`, `heads(x)`, `latest(x, n)`, `fork_point(x)`, `merge_point(x)`.
  `fork_point` and `merge_point` take one argument.
- `reachable(x, y)`, `empty()`, `all()`, `none()`
- pattern kinds: `glob:` (the default), `exact:`, `substring:`, `regex:`, `p:`
  for a pattern alias. Append `-i` for case-insensitive, as in `glob-i:"FIX*"`.

Examples:

```console
jj log -r @-
jj log -r 'remote_bookmarks()..'
jj log -r 'reachable(@, mutable())'
jj log -r 'author(mine) & description(*fix*)'
jj log -r 'fork_point(@)'
```

Keyword help is `jj help -k revsets`; `jj help revsets` is not a valid
invocation. Full reference: <https://docs.jj-vcs.dev/latest/revsets/>

## Gotchas

- `jj op undo` does not exist; the subcommands are `jj op revert` and
  `jj op restore`.
- `jj diffedit -r <rev>`: select rev with `-r`. Positional args are
  paths/filesets.
- Changing a bookmark backwards needs `--allow-backwards` on `jj bookmark set`
  and `jj bookmark move`.
- Keep change IDs, not commit IDs, in notes, revsets, and handover messages.
  A commit ID from a rewritten change no longer resolves.
