---
description: Write a portable handover document to /tmp/opencode/handovers and return the ID that /continue takes
agent: build
subtask: false
---

# Handover

Write one handover document for a fresh agent. `$ARGUMENTS` is plain text naming
the next session's focus; with no arguments, use the next useful step of the
current work.

The document outlives this session, so every line in it must be a claim a
stranger can act on.

## Before You Start

Check for existing context:

- `CONTEXT.md` at root — domain terms for the scope
- `docs/` — architecture decisions behind the work
- Component `README.md` or codedocs — patterns, decisions

Use their language in the document. Don't re-litigate ADRs.

## Workflow

1. Capture state from command output, not recollection. In a `jj` repo:

   ```console
   jj status
   jj log -r @ --no-graph -T 'change_id.short() ++ " " ++ description.first_line()'
   jj diff --stat
   ```

   Read each path `jj diff --stat` lists. `jj status` names the conflicts and
   the snapshot state; record both, and resolve neither.
2. Create the directory and generate the ID:

   ```sh
   mkdir -p /tmp/opencode/handovers
   id="handover-$(date -u +%Y%m%dT%H%M%SZ)-$$"
   printf '%s\n' "$id"
   ```

   If `/tmp/opencode/handovers/$id.md` already exists, run the `id=` line
   again. Keep the ID inside letters, digits, dots, underscores, and hyphens:
   `/continue` rejects anything else.
3. Write the document to `/tmp/opencode/handovers/<id>.md`.
4. Read it back and check it against the template: headings present and in
   order, no heading left blank, no secret-shaped value, and every path named
   under `Next steps` and `References` present in the tree.
5. Do not edit tracked files. Do not run `jj new`, `jj describe`, `jj edit`,
   `jj squash`, `jj abandon`, or `jj git push`.

## Rules

- Never include secrets: API keys, passwords, tokens, cookies, private keys, or
  PII. The read-denied set in `default.nix` — `.env`, `*.key`, `*.pem`, `*.p12`,
  `*.pfx`, `*.p8`, `*.kdbx`, `*.agekey`, `.netrc`, `~/.ssh`, `~/.gnupg`,
  `.config/sops` — is the shape list to leave out.
- Paths are relative to the repo root. Absolute paths that exist on this
  machine will not exist next session.
- No line numbers. They drift by the next edit.
- No references to this session's tool calls, subagents, or scratch files. The
  handover file itself is the only `/tmp` path worth naming.
- Summarize; never paste. No transcript, diff, plan, or source file.
- Give the Jujutsu change ID as the handle, not the commit ID: the change ID
  survives rewrites, the commit ID does not.
- Name only skills that exist in `default.nix`, and only ones the next step
  needs.

## Document format

Use this shape exactly, headings in this order:

```md
# Handover <id>

## Goal
<one sentence: what the next session has to achieve>

## Done
- <what landed, and the path it landed in>

## In progress
- <what is half-built, and where it stops>

## Next steps
- <imperative action> — <path or symbol>

## Decisions and constraints
- <decision> — <why it was made>

## Checks
- `<command>` — <result>

## Blockers
- <details, or none>

## References
- `jj log -r <change-id>` — working copy at handover: <change-id-short()>,
  description: <description>
- <path, relative to repo root> — <what the next session should read there>

## Suggested skills
- <skill-name> — <the task it applies to>
```

Write `- none` as the only bullet of any section with nothing to report; `Goal`
takes its sentence instead. Never leave a heading blank — blank is a truncated
write, `- none` is a record that you looked. `/continue` reads `- none` as a
prompt to go look and fills the gap from the tree. It is not a blocker.

## Output format

Use this output shape:

```md
Handover ID: <id>
File: /tmp/opencode/handovers/<id>.md
Continue: /continue <id>
```

If writing or verification fails, report the error and do not return an ID.
