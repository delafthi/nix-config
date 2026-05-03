---
description: Review code
agent: reviewer
subtask: false
template: Provide a structured code review for the provided files or current changes.
---

# Review code

Provide a structured code review for the files $ARGUMENTS or the current changes.

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
