---
name: jj
description: Prevent common Git-vs-Jujutsu mistakes.
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

## Recovery

- Use `jj undo` after mistaken operation.
- Use `jj log` to inspect graph before destructive history edits.
