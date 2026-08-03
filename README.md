# delafthi's Nix configuration

Nix flake for personal Linux and macOS configuration. It wires NixOS, nix-darwin, home-manager, sops-nix, and a small set of custom packages and apps.

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

## Usage

Apply the current host config:

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
```

Other apps in the flake:

```bash
nix run .#setup-yubico-pam
nix run .#test-yubico-pam
```

## Configuration

The `apply` app uses the current short hostname when no host name is passed. On Darwin it calls `sudo darwin-rebuild switch --flake ".#$HOSTNAME"`; on NixOS it calls
`sudo nixos-rebuild switch --flake ".#$HOSTNAME"`.

Secrets are managed with `sops-nix` and age.

## License

MIT
