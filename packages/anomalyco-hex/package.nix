{
  lib,
  stdenv,
  callPackage,
  writeShellScript,
  nix-update-script,
  _experimental-update-script-combinators,
  curl,
  jaq,
  gnugrep,
  gnused,
  coreutils,
  common-updater-scripts,
  nix,
}:
let
  pname = "anomalyco-hex";
  version = "3.3.0";

  meta = {
    description = "Local voice dictation that transcribes on-device";
    homepage = "https://anoma.ly/hex/";
    changelog = "https://github.com/anomalyco/hex/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.delafthi ];
    platforms = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-linux"
    ];
    mainProgram = "hex";
  };

  # Refresh builds must run where the Linux toolchain does: the CI runner is
  # a native x86_64-linux; on darwin the local remote builder is aarch64-linux.
  # The fetched hashes do not depend on the system.
  # nix-update edits version and src hash in a single file, so the shared and
  # the platform files each get their own call:
  # 1. bump the version literal here; with --no-src the hash is left alone,
  #    since each platform's hash lives in its own file,
  # 2. refresh the Linux source hash afterwards; --system evaluates the Linux
  #    package on any host, and --version=skip forces the hash refresh after
  #    step 1 moved src.rev forward,
  # 3. the Darwin dmg is only touched by its own file; the hash is prefetched
  #    directly (no derivation build, no darwin host needed).
  updateScript = _experimental-update-script-combinators.sequence [
    (nix-update-script {
      extraArgs = [
        "--flake"
        "--no-src"
        "--override-filename"
        "packages/anomalyco-hex/package.nix"
      ];
    })
    (nix-update-script {
      extraArgs = [
        "--flake"
        "--system"
        (if builtins.currentSystem == "x86_64-linux" then "x86_64-linux" else "aarch64-linux")
        "--version=skip"
        "--override-filename"
        "packages/anomalyco-hex/linux.nix"
      ];
    })
    (writeShellScript "anomalyco-hex-darwin-update-script" ''
      set -euo pipefail
      export PATH=${
        lib.makeBinPath [
          curl
          jaq
          gnugrep
          gnused
          coreutils
          common-updater-scripts
          nix
        ]
      }

      new_version=$(curl -fsSL https://api.github.com/repos/anomalyco/hex/releases \
        | jaq -r '.[] | select(.prerelease != true) | .tag_name' \
        | grep -E '^v[0-9]' | sed 's/^v//' | sort -V | tail -n1)

      if [[ "''${UPDATE_NIX_OLD_VERSION:-}" = "$new_version" ]]; then
        echo "${pname} is already at the latest version $new_version."
        exit 0
      fi

      # the dmg hash is prefetched directly (no derivation build), so the
      # script runs on any platform
      asset="macos-arm64.dmg"
      store_hash=$(nix-prefetch-url --type sha256 \
        "https://github.com/anomalyco/hex/releases/download/v$new_version/hex-$new_version-$asset")
      hash=$(nix --extra-experimental-features nix-command hash to-sri --type sha256 "$store_hash")
      update-source-version ${pname} "$new_version" "$hash" \
        --source-key="sources.aarch64-darwin" \
        --file="packages/anomalyco-hex/darwin.nix" \
        --ignore-same-version --ignore-same-hash
    '')
  ];
in
if stdenv.hostPlatform.isDarwin then
  callPackage ./darwin.nix {
    inherit
      pname
      version
      meta
      updateScript
      ;
  }
else
  callPackage ./linux.nix {
    inherit
      pname
      version
      meta
      updateScript
      ;
  }
