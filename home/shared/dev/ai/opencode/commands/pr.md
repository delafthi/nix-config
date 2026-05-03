---
description: Create pull request
agent: build
subtask: false
template: Create a pull request from the current branch.
---

# Create pull request

Create a pull request from the current branch. $ARGUMENTS

## Check

!`jj bookmark list`
!`jj log -l 10`
!`jj status`

Ensure current change has bookmark. Create/set if needed:

```bash
jj bookmark create <bookmark-name>
jj bookmark set <bookmark-name>
```

Push when bookmark not on remote:

```bash
jj git push
```

## Existing PR

- If PR exists, update title/body to match current commit range
- If no PR, create new one

## Create PR

Use PR template if repo has one.

```bash
gh pr create --title "title" --body "description"
```

- Title: imperative, concise, <100 chars
- Body: minimal by default; explain why; add sections only for large/complex changes
- Reference related issues when relevant
