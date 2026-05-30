---
description: Create a commit with description
agent: build
subtask: false
template: Commit the current changes.
---

# Create commit with description

Commit current changes. $ARGUMENTS

## Check context

!`jj status`
!`jj log --limit 20`
!`jj diff`

Use existing project style when clear. Else use scoped commits.

If no working-copy changes, stop and report: nothing to commit.

## Commit message format

```text
<scope>: <description>

[optional body]

[optional footer(s)]
```

- Subject: imperative, lowercase, no period, <=100 chars, English
- Body: only when needed, explain why, <=100 chars/line
- Footer: only when relevant (`BREAKING CHANGE:`, `Fixes #`, `Closes #`, `Resolves #`, `Related to #`)
- Keep message minimal
