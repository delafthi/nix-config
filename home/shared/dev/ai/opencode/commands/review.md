---
description: Review files, current change, or PR
agent: plan
subtask: false
template: Provide structured code review for files, current change, or PR number.
---

# Review code

Provide structured code review for one target from `$ARGUMENTS`.

## Target selection

Use this order:

1. If `$ARGUMENTS` matches PR number format (`123` or `#123`), review that PR.
2. Else if `$ARGUMENTS` provided, treat as file path(s) and review only those files.
3. Else review current Jujutsu change (`@`).

For PR input, strip leading `#` before CLI usage.

## PR mode

For PR review mode:

- Scope: review PR diff and metadata (title/description), focus on code impact.
- Use GitHub CLI to fetch PR title/body and full diff for the PR number.
- Base review on fetched PR description plus diff content.

## Priority

Review in this order:

1. Security
2. Correctness
3. Performance
4. Maintainability
5. Testing
6. Documentation
7. Style (only meaningful deviations)

## Per issue

- Severity: `CRITICAL | HIGH | MEDIUM | LOW | SUGGESTION`
- Category
- Location: `file:line`
- Problem
- Impact
- Fix

## Output

```text
## Summary
- Total issues: X
- Main risks: ...

## Issues
- [SEVERITY][Category] `path/to/file:line` - problem, impact, fix
```

Keep feedback actionable, objective, and concise.

## Scope rules

- File review: only review listed file paths.
- Current change review: review diff in working copy change (`jj diff`).
- PR review: use `PR mode` flow above.
