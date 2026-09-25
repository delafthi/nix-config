---
description: Resume work from a handover document
agent: build
subtask: false
---

# Continue

Resume work from the handover ID in `$1`.

## Workflow

1. Accept one ID containing only letters, digits, dots, underscores, and
   hyphens. Resolve only `/tmp/opencode/handovers/<id>.md`.
2. Read the handover and its references. If it is missing or malformed, report
   the blocker and stop. Never guess another ID.
3. Inspect the current directory and repository read-only. Treat current files
   and repository state as primary sources. If state differs, preserve changes,
   report the difference, and adapt the plan.
4. Load relevant entries from `Suggested skills`.
5. Continue with the first concrete item under `Next steps`. Ask only when a
   missing decision blocks safe progress.
6. Run relevant checks and report failures accurately. Do not commit, push,
   publish, or perform destructive cleanup unless explicitly requested.

## Rules

- Follow project guidance and existing interfaces.
- Do not edit the handover unless asked.
- Do not expose or seek secrets.
- Report inaccessible external paths instead of guessing.

## Output

State the ID, verified state, and next action before editing. After work,
return:

```md
## Resumed
- Handover: <id>
- State: <verified state>
- Work: <changes or remaining work>

## Checks
- <command and result, or not run>

## Blockers
- <none or details>
```

Do not paste the full handover back.
