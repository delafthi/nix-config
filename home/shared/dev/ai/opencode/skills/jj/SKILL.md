---
name: jj
description: Prevent common Git-vs-Jujutsu mistakes.
---

# jj

Common actions:

- Status/log/diff: `jj st`, `jj log`, `jj diff`
- New change/edit current: `jj new`, `jj edit <rev>`
- Set change message: `jj describe -m "<message>"`
- Fold/split work: `jj squash`, `jj new`
- Undo operation: `jj undo`
- Manage bookmarks: `jj bookmark list`, `jj bookmark create <name>`, `jj bookmark set <name>`
- Push bookmark: `jj git push --bookmark <name>`

Workflow (jj vs git):

jj workflow: create change first, then make edits, then describe/commit.

- `jj new` → make changes → `jj describe -m "..."` (or `jj commit -m "..."` to also create next change)
- Do NOT make changes then commit like git — that leads to overusing `jj squash` and `jj split`.
- `jj commit` = `jj describe` + `jj new` in one step; use it to close current change and start fresh.

Gotchas:

- Use `bookmark`, not `branch`.
- `@` means current working-copy revision.
- `git checkout` maps to `jj new` (usually) or `jj edit`.
- Do not guess git-only flags; check `jj help <command>`.
