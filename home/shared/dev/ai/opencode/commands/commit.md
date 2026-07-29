---
description: Set current change description from diff
agent: build
subtask: false
---

# Create commit with description

Generate message for current working-copy change and set description on current Jujutsu change (`@`).

## Conventions

- Check `CONTRIBUTING.md` and commit message conventions in the repo.
- Mirror existing commit message style (scope, format, capitalization).

## Workflow

1. Inspect state:

`jj status`
`jj log --limit 20`
`jj diff`

2. If no changes in working copy, stop and report `nothing to commit`.
3. Identify scope from touched area (module/package/domain).
4. Build message from repo conventions; if unclear, use `<scope>: <description>`.
5. Set message on current change with `jj commit`.
6. Do not create new change, squash, or push.

## Commands

```bash
jj commit -m "<commit message>"
```

## Message format

```text
<scope>: <description>

[optional body]

[optional footer(s)]
```

- Subject imperative, lowercase, no period, <=100 chars
- Body only when needed; explain why, <=100 chars/line
- Footer only when relevant (`BREAKING CHANGE:`, `Fixes #`, `Closes #`, `Resolves #`, `Related to #`)
- Keep message minimal and specific
- Add an AI disclosure when requested in `CONTIRUBUTING.md` or `AI_POLICY.md`
- Avoid generic subjects like `update`, `fix stuff`, `changes`

## Output format

- Return one final result with commit message only.

Use this output shape:

```md
<full message>

## Blockers
- <none|details>
```
