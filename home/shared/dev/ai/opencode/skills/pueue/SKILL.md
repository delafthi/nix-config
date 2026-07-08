---
name: pueue
description: Manage long-running commands with pueue. Use when commands exceed 10s or block the shell.
---

# pueue

Mandatory for commands >10s: nix build, tests, merge-when-green, build systems.

## Common Commands

- `pueue add --print-task-id -- 'command with args'` — enqueue task
- `pueue follow <id>` — stream output, blocks until done
- `pueue log --lines 50 <id>` — get exit status and full log
- `pueue parallel <N>` — set concurrent task limit
- `pueue status` — overview of queue

## Usage Pattern

```sh
id=$(pueue add --print-task-id -- 'nix build .#something')
pueue follow "$id"
pueue log --lines 50 "$id"
```

## Guardrails

- Always quote entire command passed to `pueue add` to preserve argument quoting.
- Use `--lines` flag in `pueue log` (not `tail`) to retain full log.
- Check `pueue status` before adding tasks to avoid overwhelming queue.
