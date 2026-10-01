---
description: Resume work from a handover ID; verify repo state before acting
agent: build
subtask: false
---

# Continue

Resume work from a handover document. `$ARGUMENTS` carries the handover ID as
its first token; any remaining tokens are extra instructions for this session.

The document is a claim from a past session, not state. Verify it before
building on it.

## Before You Start

Check for existing context:

- `CONTEXT.md` at root — domain terms for the scope
- `docs/` — architecture decisions behind the work
- Component `README.md` or codedocs — patterns, decisions

Those files may be newer than the handover. Use established language. Don't
re-litigate ADRs.

## Workflow

1. Resolve the ID to `/tmp/opencode/handovers/<id>.md` and nothing else. Accept
   only letters, digits, dots, underscores, and hyphens. No ID: list
   `/tmp/opencode/handovers/` newest first and ask which one. Never invent an
   ID.
2. Read the document and follow its `References`. A missing file or a truncated
   document: report the blocker and stop.

   A section holding only `- none` is normal producer output, not a blocker.
   It records that `/handover` looked and had nothing to record. Read it as a
   prompt to go look, and fill it from the working copy, `jj` state, and the
   actual files. Never fill it from an earlier session, and never assert what
   you only half-remember. A blank heading is a truncated write, not a `- none`
   section — treat it as the blocker above.
3. Screen the change ID before the first `jj` command. A placeholder identifier
   is not a change: a run of `z` (`zzzzzzzz` or longer) or a run of `0`
   (`00000000` or longer) names the null commit. Jujutsu resolves either to
   `root()` and exits 0, so the lookup succeeds and the root commit is what you
   inspect. Reject it and ask for the real ID. Do not resolve a placeholder and
   act on what comes back.

   Then verify read-only, before touching anything:

   ```console
   jj status
   jj log -n 20
   jj diff
   ```

   Then check the document's claims against that output:

   - Change ID, when it names one: `jj log -r <change-id>`. The error
     `Revision \`<id>\` doesn't exist` means the change was abandoned, not
     moved.
   - `@` from `jj status` against the change the document names. Different
     means the working copy moved on. Report it; never switch changes yourself.
   - Every path and symbol under `Next steps`, and the state asserted in `Done`
     and `In progress`. A path that is gone: report and ask.

   Where the document and the tree disagree, the tree is right. Report each
   mismatch and adapt the plan.
4. Load only the skills named in `Suggested skills`, and only where they apply
   to the item in hand.
5. Do the first concrete item under `Next steps`. Ask only when a missing
   decision blocks safe progress or a mismatch from step 3 is unresolvable.
6. Run the commands under `Checks`, then the project's own typecheck, test, and
   lint commands. Report failures as they came.

## Rules

- Do not edit the handover. It is the record of a past session. A follow-up
  session gets a new document from `/handover`, never an edit to this one.
- Do not commit, push, publish, or perform destructive cleanup unless
  explicitly requested.
- Report inaccessible external paths instead of guessing.
- Read the jj skill for revision syntax, change IDs, and revsets.

## Output

State the ID, what you verified, and the next action before editing. After
work, return:

```md
## Resumed
- Handover: <id>
- State: <verified state, gaps filled from the tree, any mismatch>
- Work: <changes or remaining work>

## Checks
- <command and result, or not run>

## Blockers
- <problem still unresolved after checking the tree, or none>
```

A handover section that was `- none` and that you resolved from the tree is not
a blocker. Report it under `State`, not here.

Do not paste the full handover back.
