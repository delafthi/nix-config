---
name: nix
description: Nix environment toolkit. Use when tools are missing, builds fail, or you need to find/install packages.
---

# nix

## Check First

Before assuming a tool is missing, always look for a project dev shell:

1. Check for `flake.nix` in project root
2. Check for `shell.nix`
3. Check for `.envrc` (may use `use flake`)
4. Check for `nix/` directory

If any found → `nix develop` or read what the shell provides (check `packages` attr). The tool may already be available inside the shell.

If none found → tool is not in the project environment. Use `nix-locate` or `nix run nixpkgs#` below.

## Missing Tool Resolution

```bash
nix-locate 'bin/<name>'                  # find which package provides it
nix run nixpkgs#<package> -- --help      # run without installing
```

## Debugging Nix Builds

Only relevant when building Nix derivations (flake builds, nix-build, etc.):

```bash
nix build --show-trace --print-build-logs    # first step for any failure
nix log /nix/store/xxxx | rg <keyword>       # inspect build logs
nix build --debugger                         # interactive debugger on eval failure
nix build --repair                           # fix corrupted store paths
```

If `nix build` output is truncated or cached failure, delete eval cache:

```bash
rm -rf ~/.cache/nix/eval-cache-*
```

## nix repl

Inspect Nix expressions interactively:

```bash
nix repl
:l .          # load current flake
:p <attr>     # print attribute
:t <expr>     # show type
```

## Remote Builders

- nix.conf has remote builders for aarch64-linux, aarch64-darwin, x86_64-linux.
- NixOS tests on macOS: target x86_64-linux (offloaded to remote builder).

## Cross-Arch Builds

- `nix-build --eval-system x86_64-linux`
- Flakes: use system attr directly (e.g. `.#packages.x86_64-linux.hello`)

## Code Quality

- Format flakes with `nix fmt`.
- Build individual tests instead of `nix flake check` (too slow).

## References

- <https://nix.dev> — Official Nix documentation
- <https://nixos.org/wiki> — NixOS wiki
- <https://github.com/nix-community/nix-index> — nix-locate docs
