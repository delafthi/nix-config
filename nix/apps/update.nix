{ pkgs }:
let
  name = "update";
  description = "Update packages with nix-update";
  usage = ''
    Usage: ${name} [OPTIONS] [PACKAGE] [NIX-UPDATE-FLAGS...]

    ${description}

    Runs `nix-update --flake --use-update-script` for one package, or for
    every package in the flake when PACKAGE is omitted. Any extra flags are
    forwarded to nix-update (e.g. --build, --format).

    `--commit` is handled specially: nix-update is asked to write its commit
    message to a file, and the commit is created as `packages/<attr>: <from> -> <to>`.

    Options:
      -h, --help     Show this help message and exit

    Arguments:
      PACKAGE        Flake package attribute to update. Omit to update all.
      NIX-UPDATE-FLAGS...
                     Extra flags forwarded to nix-update.

    Examples:
      nix run .#${name}                                  # Update all packages
      nix run .#${name} -- mattpocock-skills             # Update one package
      nix run .#${name} -- mattpocock-skills --build     # Pass --build
      nix run .#${name} -- --commit                      # Commit each update
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
        jaq
        nix
        nix-update
        gnused
      ];
      text = ''
        show_help() {
          cat <<'EOF'
        ${usage}
        EOF
        }

        PACKAGE=""
        EXTRA_ARGS=""
        COMMIT=0
        ALL_MODE=1

        while [[ $# -gt 0 ]]; do
          case "$1" in
            -h|--help)
              show_help
              exit 0
              ;;
            --)
              shift
              # flags after separator
              for a in "$@"; do
                if [[ "$a" == "--commit" ]]; then
                  COMMIT=1
                else
                  EXTRA_ARGS="''${EXTRA_ARGS:+$EXTRA_ARGS }$a"
                fi
              done
              break
              ;;
            --commit)
              COMMIT=1
              shift
              ;;
            -*)
              EXTRA_ARGS="''${EXTRA_ARGS:+$EXTRA_ARGS }$1"
              shift
              ;;
            *)
              if [[ -z "$PACKAGE" ]]; then
                PACKAGE="$1"
                ALL_MODE=0
              else
                EXTRA_ARGS="''${EXTRA_ARGS:+$EXTRA_ARGS }$1"
              fi
              shift
              ;;
          esac
        done

        run_update() {
          local pkg="$1"
          local msg_file=""
          local args="$EXTRA_ARGS"
          if [[ $COMMIT -eq 1 ]]; then
            msg_file="$(mktemp)"
            args="$args --write-commit-message $msg_file"
          fi

          # shellcheck disable=SC2086
          if ! nix-update --flake --use-update-script $args "$pkg"; then
            echo "Failed to update $pkg" >&2
            if [[ $ALL_MODE -eq 1 ]]; then
              git reset --hard HEAD >/dev/null 2>&1 || true
            fi
            [[ -n "$msg_file" ]] && rm -f "$msg_file"
            return 1
          fi

          if [[ $COMMIT -eq 1 && -n "$msg_file" ]]; then
            if ! git diff --quiet; then
              gnused -i -E '1s/^([^:]+):/packages\/\1:/' "$msg_file"
              git add -A
              git commit -F "$msg_file" >/dev/null
            fi
            rm -f "$msg_file"
          fi
          return 0
        }

        if [[ -n "$PACKAGE" ]]; then
          run_update "$PACKAGE"
          exit $?
        fi

        SYSTEM="$(nix eval --impure --raw --expr 'builtins.currentSystem')"
        mapfile -t PACKAGES < <(nix eval --json ".#packages.''${SYSTEM}" --apply 'builtins.attrNames' | jaq -r '.[]')

        if [[ ''${#PACKAGES[@]} -eq 0 ]]; then
          echo "No packages found to update." >&2
          exit 1
        fi

        FAILED=0
        for pkg in "''${PACKAGES[@]}"; do
          echo "==> Updating $pkg"
          run_update "$pkg" || FAILED=1
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
