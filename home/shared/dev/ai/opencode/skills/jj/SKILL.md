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

## Common Commands

- Status/log/diff: `jj st`, `jj log`, `jj diff`
- New change/edit current: `jj new`, `jj edit <rev>`
- Set change message: `jj describe -m "<message>"`
- Fold/split work: `jj squash`, `jj new`
- Undo operation: `jj undo`
- Manage bookmarks: `jj bookmark list`, `jj bookmark create <name>`, `jj bookmark set <name>`
- Push bookmark: `jj git push --bookmark <name>`

## Canonical Flow

Create change first, then edit, then describe.

- `jj new` → make changes → `jj describe -m "..."` (or `jj commit -m "..."` to also create next change)
- Avoid git flow "edit then commit"; pattern causes avoidable `jj squash`/`jj split` cleanup.
- `jj commit` = `jj describe` + `jj new` in one step; use it to close current change and start fresh.

## Guardrails

- Use `bookmark`, not `branch`.
- `@` means current working-copy revision.
- Map `git checkout` intent to `jj new` (usually) or `jj edit`.
- Verify unfamiliar flags with `jj help <command>`.

## Merge Conflicts

- Try `jj resolve` first (invokes `mergiraf`). Verify with `jj diff`.
- If `mergiraf` leaves conflicts, resolve manually:
  - Check history and conflicting files.
  - Read commit messages, PRs, tickets to understand original intent.
  - Preserve both intents where possible. If incompatible, pick the one matching the merge's goal and note the trade-off.
  - Run automated checks (typecheck, tests, format). Fix anything the merge broke.
  - If rebasing, continue the rebase until all commits are rebased.

## Recovery

- Use `jj undo` after mistaken operation.
- Use `jj restore` to discard working copy changes.
- Use `jj log` to inspect graph before destructive history edits.
