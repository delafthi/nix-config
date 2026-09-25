---
description: Create a portable handover document
agent: build
subtask: false
---

# Handover

Create a handoff document for a fresh agent at:

```text
/tmp/opencode/handovers/<id>.md
```

Treat `$ARGUMENTS` as plain text describing the next session's focus. If empty,
use the current work's next useful step.

## Workflow

1. Capture objective, decisions, constraints, completed work, unfinished work,
   next steps, verification, and blockers from the conversation.
2. Create the directory and generate an ID with:

   ```sh
   id="handover-$(date -u +%Y%m%dT%H%M%SZ)-$$"
   printf '%s\n' "$id"
   ```

   If that file exists, run the command again.
3. Write, read back, and verify the document. Do not modify the repository.

## Document contents

Include headings for:

- Goal
- Done
- In progress
- Next steps
- Decisions and constraints
- Checks
- Blockers
- References
- Suggested skills

Separate verified facts from assumptions. Do not copy full transcripts, diffs,
plans, or source files. Never include API keys, passwords, tokens, private
keys, cookies, or PII. Name only skills relevant to the next step.

## Output

```text
Handover ID: <id>
File: /tmp/opencode/handovers/<id>.md
Continue: /continue <id>
```

If writing or verification fails, report the error and do not return an ID.
