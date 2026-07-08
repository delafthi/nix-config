---
description: Create or update PR for current change
agent: build
subtask: false
---

# Create pull request

Create or update PR for current change (`@`). Use `$ARGUMENTS` as optional hints (title/body/base/bookmark).

## Conventions

- Check `CONTRIBUTING.md` and PR templates before writing title/body.
- Mirror existing PR style in the repo.

## Workflow

1. Inspect local state:

!`jj bookmark list`
!`jj log -l 10`
!`jj status`

2. Infer:

- current change id + description
- base bookmark (prefer `main` unless repo uses another default)
- head bookmark for current change
- intended PR title/body from change summary and `$ARGUMENTS`

3. Ensure current change has bookmark; create/set if missing:

```bash
jj bookmark create <bookmark-name>
jj bookmark set <bookmark-name>
```

4. If remote missing latest bookmark state, push:

```bash
jj git push
```

5. Check for existing open PR from current head bookmark.
6. If PR exists, update it. If not, create it.
7. If external action is blocked by policy, prepare final PR title/body and exact command(s) only.

## Parallelization (conditional)

- For larger changes, use at most 2 subagents in parallel:
  - Lane A: diff summary, risk/test signal extraction
  - Lane B: PR metadata/template/related-issue checks
- Primary agent writes final title/body and performs create-or-update action.

## PR content

- Use repo PR template when available
- Title concise, imperative, <100 chars
- Body minimal by default: what changed, why, risks/testing
- Reference related issues when relevant
- Avoid duplicate PRs for same head bookmark
- Preserve manually provided hints from `$ARGUMENTS` when valid

## Output format

Use this output shape:

```md
<title> (#<number>)

<description>

<url>

## Blockers
- <none|details>
```
