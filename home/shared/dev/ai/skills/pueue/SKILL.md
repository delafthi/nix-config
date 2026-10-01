---
name: pueue
description: Queue and inspect long-running commands with pueue so the shell stays free. Use when a command is expected to run more than about 10 seconds - a flake build, a test suite, a bundle install, a dev server start - when the user says "this is taking forever", "run it in the background", "don't block on that", or "kill that task", or when a task is already queued and its result still needs collecting. Applies even when the user never says "pueue". Triggers on "pueue", "pueue add", "pueue log", "background the build", "long build", "hanging test".
---

# pueue

The surface moves between releases. Read `pueue <cmd> --help` before relying
on a flag.

`pueue status`, `pueue log`, and `pueue follow` are allowlisted in
`home/shared/dev/ai/opencode/default.nix`, bare and with arguments, so reading
and collecting never prompts. Every other subcommand prompts, `pueue add`
included — `id=$(pueue add ...)` is a prompt like any other, so expect to ask
once per enqueue.

## Use When

- A command is expected to take more than about 10 seconds: `nix build`,
  `nix flake check`, a test suite, `pnpm run build`, a dev server start.
- A task is already queued and its result has not been collected.

## Enqueue, Then Collect

Default workflow. `follow` blocks until the task ends, so it is the last step.

```sh
id=$(pueue add --print-task-id -- 'nix build .#something')
pueue follow "$id"
pueue log --full "$id"
```

For work that outlives one tool call, drop `follow`: enqueue, report the id,
and read `pueue log "$id"` on a later turn.

Chain dependent tasks instead of blocking between them:

```sh
a=$(pueue add --print-task-id -- 'nix build .#app')
pueue add --after "$a" -- 'nix build .#app.check'
```

## Commands

- `pueue add --print-task-id -- 'cmd'` — enqueue, print the bare id
- `pueue add --after <id> -- 'cmd'` — start once every listed id succeeded; a
  failed dependency fails this task too
- `pueue add --working-directory <path>` — otherwise the task inherits the
  directory `pueue add` ran in
- `pueue follow [--lines N] <id>` — stream output, blocks until done
- `pueue log [--full | --lines N] <id>` — output of a finished task
- `pueue status` — queue overview; takes a filter such as `status=running`
- `pueue parallel <n>` — concurrency limit for the `default` group
- `pueue wait [ids]` — block until tasks finish; `--all` spans groups
- `pueue restart <id>` — re-run a finished task
- `pueue kill <id>`, `pueue remove <id>` — stop a running task, then drop it
- `pueue clean` — drop finished tasks; ids restart at 0

## Gotchas

- `pueue log --lines N` prints the *last* N lines. It truncates. Only `--full`
  retains the whole log.
- `pueue log <id>` on a still-running task prints the banner and no output. Use
  `follow` to read live output.
- `pueue log` always exits 0, including for a failed task. The banner carries
  the result: `failed with exit code 3`. Read that, or `pueue status`.
- An unknown id is not an error: `pueue log 999` prints `There are no finished
  tasks for your specified ids` and exits 0.
- Group parallelism is a machine fact, not a pueue default, so never assume one
  task at a time and never assume a number. The `default` group runs its limit
  concurrently and queues the rest, so N queued tasks need not run in series.
  Read the effective limit off the `Group "default" (N parallel)` line in
  `pueue status`. A value written in a config file is not proof the running
  daemon loaded it.
- `pueue parallel <n>` changes the limit for the rest of the daemon's life but
  is not allowlisted, so it prompts. Change the daemon config instead.
  `pueue group` splits work into separately limited groups, and prompts too.
- Quote the whole command passed to `pueue add`. Tasks run through a shell, so
  `'echo "a b" && echo $HOME'` keeps both its quoting and its expansions.
  `-e` escapes those characters instead and disables shell syntax; do not reach
  for it by habit.
