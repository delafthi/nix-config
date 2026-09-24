{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.llama-cpp;

  args = lib.cli.toCommandLine (optionName: {
    option =
      if lib.hasPrefix "-" optionName then
        optionName
      else if builtins.stringLength optionName > 1 then
        "--${optionName}"
      else
        "-${optionName}";
    sep = null;
    explicitBool = false;
    formatArg = lib.generators.mkValueStringDefault { };
  }) cfg.settings;

  cacheDir =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "${config.home.homeDirectory}/Library/Caches/llama.cpp"
    else
      "${config.xdg.cacheHome}/llama.cpp";

  commandLine = lib.concatStringsSep " " (
    [ (lib.getExe' cfg.package "llama-server") ] ++ map lib.escapeShellArg args
  );
in
{
  options = {
    services.llama-cpp = {
      enable = lib.mkEnableOption "llama.cpp HTTP server";

      package = lib.mkPackageOption pkgs "llama-cpp" { };

      settings = lib.mkOption {
        type = lib.types.submodule {
          freeformType = lib.types.attrs;
          options = {
            host = lib.mkOption {
              type = lib.types.str;
              default = "127.0.0.1";
              example = "0.0.0.0";
              description = ''
                IP address on which the server should listen on.
              '';
            };

            port = lib.mkOption {
              type = lib.types.port;
              default = 8080;
              example = 1337;
              description = ''
                Port on which the server should listen on.
              '';
            };
          };
        };
        default = { };
        example = {
          host = "0.0.0.0";
          port = 1337;
          model = "/mnt/llms/Foo3.6-27B-UD-Q4_K_XL.gguf";
          ctx-size = 252144;
          temp = 0.6;
          top-k = 20;
          top-p = 0.95;
          batch-size = 512;
          ubatch-size = 256;
          spec-type = "draft-mtp";
          spec-draft-n-max = 2;
          flash-attn = "on";
        };
        description = ''
          Command-line arguments for `llama-server`.

          See <https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md>
          for the full list of options.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    systemd.user.services.llama-cpp = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      Unit = {
        Description = "llama.cpp HTTP server";
        After = [ "network.target" ];
      };

      Service = {
        ExecStart = commandLine;
        ExecReload = "${lib.getExe' pkgs.coreutils "kill"} -HUP $MAINPID";
        Restart = "on-failure";
        RestartSec = 300;
        Environment = [ "LLAMA_CACHE=${cacheDir}" ];
      };

      Install.WantedBy = [ "default.target" ];
    };

    launchd.agents.llama-cpp = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      enable = true;
      config = {
        ProgramArguments = [ (lib.getExe' cfg.package "llama-server") ] ++ args;
        KeepAlive = true;
        RunAtLoad = true;
        EnvironmentVariables = {
          LLAMA_CACHE = cacheDir;
        };
        StandardOutPath = "${config.xdg.stateHome}/llama-cpp/stdout.log";
        StandardErrorPath = "${config.xdg.stateHome}/llama-cpp/stderr.log";
      };
    };
  };
}
