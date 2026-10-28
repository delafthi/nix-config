{
  lib,
  config,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    types
    ;

  cfg = config.programs.rex;
in
{
  meta.maintainers = with lib.maintainers; [ delafthi ];

  options.programs.rex = {
    enable = mkEnableOption "rex";

    initLua = lib.mkOption {
      type = types.lines;
      default = "";
      description = ''
        Content to be added to {file}`init.lua`.

        Rex configuration is written in Lua and lives in a single file:
        {file}`$XDG_CONFIG_HOME/rex/init.lua`.
      '';
      example = lib.literalExpression ''
        rex.bind("cmd+d", "pane.split", { direction = "right" })
      '';
    };

    shellSupport = mkEnableOption "shell support for rex";
  };

  config = mkIf cfg.enable {
    xdg.configFile."rex/init.lua" = mkIf (cfg.initLua != "") {
      text = cfg.initLua;
    };

    programs.bash.initExtra = mkIf (cfg.shellSupport && config.programs.bash.enable) ''
      if [ -n "$REX_BIN_DIR" ]; then
        export PATH="$REX_BIN_DIR:$PATH"
      fi
    '';

    programs.zsh.initContent = mkIf (cfg.shellSupport && config.programs.zsh.enable) ''
      if [ -n "$REX_BIN_DIR" ]; then
        export PATH="$REX_BIN_DIR:$PATH"
      fi
    '';

    programs.fish.interactiveShellInit = mkIf (cfg.shellSupport && config.programs.fish.enable) ''
      if set -q REX_BIN_DIR
        fish_add_path --path --prepend --move $REX_BIN_DIR
      end
    '';
  };
}
