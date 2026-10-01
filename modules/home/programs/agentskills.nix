{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.programs.agentskills;

  normalizeDirectory =
    name: source:
    if lib.isPath source then
      source
    else
      pkgs.runCommandLocal name { } ''
        if [[ ! -d ${lib.escapeShellArg (toString source)} ]]; then
          echo ${lib.escapeShellArg "programs.agentskill.skills must be a directory"} >&2
          exit 1
        fi
        ln -s ${lib.escapeShellArg (toString source)} "$out"
      '';

  normalizeSkill =
    source:
    pkgs.runCommandLocal "agentskill" { } ''
      source=${lib.escapeShellArg (toString source)}
      if [[ -d "$source" ]]; then
        ln -s "$source" "$out"
      elif [[ -f "$source" ]]; then
        mkdir "$out"
        ln -s "$source" "$out/SKILL.md"
      else
        echo "Agent skill source must be a file or directory: $source" >&2
        exit 1
      fi
    '';
in
{
  meta.maintainers = with lib.maintainers; [ delafthi ];

  options.programs.agentskills = {
    enable = mkEnableOption "agentskills";

    skills = lib.mkOption {
      type = lib.types.either (lib.types.attrsOf (
        lib.types.oneOf [
          lib.types.lines
          lib.types.path
          lib.types.str
        ]
      )) lib.types.path;
      default = { };
      description = ''
        Custom skills for AI agents.

        This option can be either:
        - An attribute set defining skills
        - A path to a directory containing skill folders

        If an attribute set is used, the attribute name becomes the
        skill directory name, and the value is either:
        - Inline content as a string (creates `~/.agents/skills/<name>/SKILL.md`)
        - A path to a file (creates `~/.agents/skills/<name>/SKILL.md`)
        - A path to a directory (creates `~/.agents/skills/<name>/` with all files)

        This also accepts Nix store paths, for example a skill directory
        from a package.

        If a path is used, it is expected to contain one folder per
        skill name, each containing a {file}`SKILL.md`. The directory is
        symlinked to {file}`~/.agents/skills/`.

        See <https://agentskills.io/home> for the documentation.
      '';
      example = lib.literalExpression ''
        {
          git-release = '''
            ---
            name: git-release
            description: Create consistent releases and changelogs
            ---

            ## What I do

            - Draft release notes from merged PRs
            - Propose a version bump
            - Provide a copy-pasteable `gh release create` command
          ''';

          # A skill can also be a directory containing SKILL.md and other files.
          data-analysis = ./skills/data-analysis;

          # A skill can also be a subdirectory within a package source (store path)
          beads = "''${pkgs.beads.src}/claude-plugin/skills/beads";
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !lib.isPath cfg.skills || lib.pathIsDirectory cfg.skills;
        message = "`programs.agentskills.skills` must be a directory when set to a path";
      }
    ];

    home.file = {
      ".agents/skills" = mkIf (lib.hm.strings.isPathLike cfg.skills) {
        source = normalizeDirectory "agentskills" cfg.skills;
        recursive = true;
      };
    }
    // lib.mapAttrs' (
      name: content:
      if lib.isPath content && lib.pathIsDirectory content then
        lib.nameValuePair ".agents/skills/${name}" {
          source = content;
          recursive = true;
        }
      else if lib.hm.strings.isPathLike content && !lib.isPath content then
        lib.nameValuePair ".agents/skills/${name}" {
          source = normalizeSkill content;
          recursive = true;
        }
      else
        lib.nameValuePair ".agents/skills/${name}/SKILL.md" (
          if lib.hm.strings.isPathLike content then { source = content; } else { text = content; }
        )
    ) (if builtins.isAttrs cfg.skills then cfg.skills else { });
  };
}
