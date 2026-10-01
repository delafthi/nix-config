---
name: nix
description: Nix command surface for this machine - Lix, not upstream Nix - covering tool lookup, build-failure triage, cross-arch targets, and remote-builder limits. Use when a tool is missing, a flake build or `nix flake check` fails, a store path is corrupted, or work targets another architecture, even if the user never says "nix". Triggers on "nix build failed", "command not found", "nix-locate", "nix run nixpkgs#", "nix develop", "flake.nix", "flake.lock", "devShell", "eval cache", "show-trace", "remote builder", "aarch64-linux", "x86_64-linux".
---

# nix

`nix` here is Lix, not upstream Nix. Confirm any flag against `nix <cmd> --help`
before relying on it: the surface differs from upstream, and a working flag can
still be missing from help text.

## Missing Tool Resolution

Read-only commands are allowlisted: `nix-locate`, `nix config show`,
`nix doctor`, `nix registry list`, `nix store ls`, `nix store ping`, and
`nix eval`/`nix flake metadata`/`nix flake show` only with
`--no-write-lock-file` pinned first. Everything else prompts, so batch what is
left into one command.

1. Check for a dev shell first: `flake.nix`, `shell.nix`, `.envrc`, or a `nix/`
   directory in the project root. If `.envrc` calls `use flake`, the tools are
   already on PATH via direnv and no `nix develop` is needed.
2. Otherwise `nix-locate 'bin/<name>'` to find the providing package.
3. `nix run nixpkgs#<package> -- --help` to run it once without installing.

Do not `nix-env --install`. Packages installed that way are overwritten by the
next rebuild.

## Lock File Writes

A command that takes an installable writes `flake.lock`. `nix flake metadata .`,
`nix eval`, `nix flake show`, `nix path-info`, `nix why-depends`, and
`nix flake check` mutate `flake.lock`.

- Pass `--no-write-lock-file` to read without touching the file.
- `--no-update-lock-file` is not a substitute.
- The allowlist pins `--no-write-lock-file`, so an unpinned call prompts. That
  prompt is the review point for anything that would rewrite a lock.
- To write a lock on purpose: `nix flake lock`.

## Debugging Nix Builds

First step for any failure: `nix build --print-build-logs .#<target>`.

- `--show-trace` may be absent from `nix build --help` yet still be accepted.
  Without it, eval errors elide part of the stack trace (`… caused by …`); with
  it the full chain is shown. Use it whenever part of the chain is elided.
- `nix build --debugger` drops into an interactive session when evaluation
  fails.
- `nix build --repair` rewrites missing or corrupted store files during
  evaluation, and rebuilds corrupted store paths during building.
- `nix log <store-path>` prints the log of a specific build.
- Stale eval cache after a flake edit: `rm -rf ~/.cache/nix/eval-cache-*`. The
  directories are versioned, so the glob is
  the way to clear them all.

## nix repl

```console
nix repl
:lf .         # load current flake (:l only reads default.nix)
:p <expr>     # print attribute
:t <expr>     # show type
:log <expr>   # build log for a derivation
```

## Cross-Arch Targets

Flakes: select the system attribute directly, e.g.
`.#packages.x86_64-linux.hello`. Non-flake: `nix-build --system x86_64-linux`,
or `--eval-system` to override the `system` argument only.

## Code Quality

- `nix fmt` runs treefmt through the flake's `treefmt` output.
- Prefer building one target over `nix flake check`, which evaluates every
  configuration including all NixOS hosts.

Reference: `nix repl` `:?` lists commands; <https://lix.systems> and
<https://github.com/nix-community/nix-index> cover this tooling. Upstream Nix
docs at <https://nix.dev> describe a different command surface.
