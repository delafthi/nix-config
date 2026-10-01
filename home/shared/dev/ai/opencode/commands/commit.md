---
description: Set the description on the current Jujutsu change from its diff
agent: build
subtask: false
---

# Describe current change

Set the description on the working-copy change (`@`) from its own diff.

## Before You Start

Check for existing context:

- `CONTRIBUTING.md` — message conventions, AI disclosure rules
- `CONTEXT.md` at root — domain terms for the scope
- `docs/` — architecture decisions behind the change
- Recent subjects from `jj log` — scope names, format, capitalization

Use established language. Mirror the style already in the log.

## Workflow

1. Inspect state:

   ```console
   jj status
   jj log --limit 20
   jj diff
   ```

2. If the working copy is empty, stop and report `nothing to commit`.
3. Derive the scope from the touched path, using the scopes already in `jj log`.
4. Write the message. Add an AI disclosure if `CONTRIBUTING.md` or
   `AI_POLICY.md` requires one.
5. Set the description with `jj describe -m "<message>"`. Not `jj commit`:
   that creates a new change on top, which this command does not do.

## Rules

- `jj describe` sets the message and keeps `@` current. Do not run `jj new`,
  `jj squash`, `jj edit`, or `jj git push`.
- Push only when the user asks for it.
- One change per logical unit. If the diff covers unrelated areas, say so and
  let the user decide before describing.
- When the subject or body reads like filler or generic praise, apply the
  `unslop` skill to the message before setting it.
- Read the jj skill for flag syntax and revsets.

## Message format

```text
<scope>: <description>

[body: why, when the diff cannot explain it]

[footer: BREAKING CHANGE / issue refs]
```

- Subject: imperative, lowercase, no trailing period
- Omit body and footer unless they carry information the subject cannot
- No filler subjects (`update`, `fix stuff`, `changes`)

## Output format

Return the message that was set, nothing else.

Use this output shape:

```md
<full message>

## Blockers
- <none|details>
```
