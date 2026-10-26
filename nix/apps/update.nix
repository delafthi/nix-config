{ pkgs }:
let
  name = "update";
  description = "Update packages with nix-update";
  usage = ''
    Usage: ${name} [OPTIONS] [PACKAGE] [NIX-UPDATE-FLAGS...]

    ${description}

    Runs nix-update for one package, or every package in the flake when
    PACKAGE is omitted, then builds and commits every updated package:

      $ nix build .#<package>          # always, after the update
      $ git commit -m "packages/<package>: <from> -> <to>"

    If a package fails to build, the update is logged and restored (no
    commit). Any extra flags are forwarded to nix-update.

    `--commit` and `--build` are accepted but no longer needed: committing
    and building are now always done by this script, never by nix-update's
    own --commit.

    Collections (nested attrsets like `cursorPlugins`, flattened to
    `cursorPlugins-*` in packages) are updated once per run on their
    first `cursorPlugins-*` attribute and committed as
    `packages/cursorPlugins: <from> -> <to>`.

    Options:
      -h, --help     Show this help message and exit

    Arguments:
      PACKAGE        Flattened package attribute to update (e.g.
                     `kicad-bin`, `cursorPlugins.pstack`); a dotted legacy
                     name is mapped to its flattened form. Omit for all.
      NIX-UPDATE-FLAGS...
                     Extra flags forwarded to nix-update.

    Examples:
      nix run .#${name}                                  # Update all packages
      nix run .#${name} -- mattpocock-skills             # Update one package
      nix run .#${name} -- cursorPlugins.pstack --format  # Forward extra flags
  '';
in
{
  type = "app";
  program = "${
    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = with pkgs; [
        bash
        coreutils
        git
        gnused
        jaq
        nix
        nix-update
      ];
      text = ''
        show_help() {
          cat <<'EOF'
        ${usage}
        EOF
        }

        PACKAGE=""
        EXTRA_ARGS=()
        ALL_MODE=1

        while [[ $# -gt 0 ]]; do
          case "$1" in
            -h|--help)
              show_help
              exit 0
              ;;
            --)
              shift
              break
              ;;
            --commit|--build)
              # Now built-in: every update is built and committed here.
              shift
              ;;
            -*)
              EXTRA_ARGS+=("$1")
              shift
              ;;
            *)
              if [[ -z "$PACKAGE" ]]; then
                PACKAGE="''${1//./-}"
                ALL_MODE=0
              fi
              shift
              ;;
          esac
        done

        while [[ $# -gt 0 ]]; do
          EXTRA_ARGS+=("$1")
          shift
        done

        run_update() {
          local pkg="$1" msg_name="$2"
          local msg_file before after
          msg_file="$(mktemp)"
          before="$(git status --porcelain -uno | cut -c4- | sort -u)"
          # Files newly changed vs. the pre-update snapshot (tracked only).
          changed() {
            after="$(git status --porcelain -uno | cut -c4- | sort -u)"
            comm -13 <(printf '%s\n' "$before") <(printf '%s\n' "$after")
          }

          if ! nix-update --flake --use-update-script \
            "''${EXTRA_ARGS[@]}" \
            --write-commit-message "$msg_file" \
            "$pkg"; then
            echo "Failed to update $pkg" >&2
            partial="$(changed)"
            if [[ -n "$partial" ]]; then
              # shellcheck disable=SC2086
              git restore -- $partial
            fi
            rm -f "$msg_file"
            return 1
          fi

          mapfile -t CHANGED < <(changed)
          if [[ ''${#CHANGED[@]} -eq 0 ]]; then
            echo "No changes for $pkg"
            rm -f "$msg_file"
            return 0
          fi

          echo "==> Building $pkg"
          if ! nix build -L --no-link ".#''${pkg}"; then
            echo "Build failed for $pkg — restoring" >&2
            git restore -- "''${CHANGED[@]}"
            rm -f "$msg_file"
            return 1
          fi

          sed -i -E "1s|^[^:]+:|packages/''${msg_name}:|" "$msg_file"
          git commit -q -F "$msg_file" -- "''${CHANGED[@]}"
          rm -f "$msg_file"
        }

        # Message name: collection prefixes are committed as packages/<collection>.
        SYSTEM="$(nix eval --impure --raw --expr 'builtins.currentSystem')"
        mapfile -t NESTED < <(nix eval --json ".#legacyPackages.''${SYSTEM}" \
          --apply 'xs: builtins.filter (n: (builtins.getAttr n xs).type or "" != "derivation") (builtins.attrNames xs)' \
          | jaq -r '.[]')
        if [[ $ALL_MODE -eq 1 ]]; then
          mapfile -t PACKAGES < <(nix eval --json ".#packages.''${SYSTEM}" --apply 'builtins.attrNames' | jaq -r '.[]')
          if [[ ''${#PACKAGES[@]} -eq 0 ]]; then
            echo "No packages found to update." >&2
            exit 1
          fi
        else
          PACKAGES=("$PACKAGE")
        fi

        declare -A SEEN=()
        FAILED=0
        for pkg in "''${PACKAGES[@]}"; do
          msg_name="$pkg"
          if [[ "$pkg" == *-* ]] && printf '%s\n' "''${NESTED[@]}" | grep -qxF "''${pkg%%-*}"; then
            prefix="''${pkg%%-*}"
            msg_name="$prefix"
            if [[ -n ''${SEEN[$prefix]:-} ]]; then
              continue
            fi
            SEEN[$prefix]=1
          fi
          echo "==> Updating $pkg"
          run_update "$pkg" "$msg_name" || FAILED=1
        done

        exit $FAILED
      '';
    }
  }/bin/${name}";
  meta = {
    inherit description;
    mainProgram = name;
  };
}
