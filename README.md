# delafthi's Nix configuration

Nix flake for personal Linux and macOS configuration. It wires NixOS, nix-darwin, home-manager, sops-nix, and a small set of custom packages and apps.

System configuration lives in `system/`, split into `system/darwin` and `system/nixos`. Home-manager configuration lives in `home/`, split into `home/darwin` and `home/linux`. Hosts, modules, and
overlays live in `hosts/`, `modules/`, and `overlays/`.

## Installation

Prerequisites:

- Nix with flakes enabled
- `direnv` and `nix-direnv` for automatic shell loading, if desired
- `age` or `age-plugin-yubikey` for sops-managed secrets

Clone the repo:

```bash
git clone https://github.com/delafthi/nix-config.git
cd nix-config
```

Enter the dev shell:

```bash
nix develop
```

Or, with direnv installed, `direnv allow` to load the shell automatically.

The flake's `nixConfig` adds the [nix-community cachix](https://app.cachix.org/cache/nix-community) cache, so no manual setup is needed.

## Usage

Apply the current host config (requires `sudo`):

```bash
nix run .#apply
```

Apply a specific host:

```bash
nix run .#apply -- my-hostname
```

Pass extra rebuild args through to `darwin-rebuild` or `nixos-rebuild`:

```bash
EXTRA_ARGS="--show-trace" nix run .#apply
# or
nix run .#apply -- -- --show-trace
```

Other apps in the flake:

```bash
nix run .#setup-yubico-pam
nix run .#test-yubico-pam
```

## Development

Format the tree with `treefmt-nix`:

```bash
nix fmt
```

Validate the flake (the same check CI runs on `aarch64-darwin`):

```bash
nix flake check
```

## Configuration

The `apply` app uses the current short hostname when no host name is passed. On Darwin it calls `sudo darwin-rebuild switch --flake ".#$HOSTNAME"`; on NixOS it calls
`sudo nixos-rebuild switch --flake ".#$HOSTNAME"`.

Secrets are managed with `sops-nix` and age. Files matching `secrets.{yaml,yml,json,env,ini}` are encrypted per the rules in `.sops.yaml`, and the dev shell provides `sops` and `age`.
