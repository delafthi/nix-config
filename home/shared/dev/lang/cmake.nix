{ pkgs, ... }:
let
  tomlFormat = pkgs.formats.toml { };
in
{
  xdg.configFile."neocmakelsp/config.toml".source = tomlFormat.generate "config.toml" {
    command_case = "lower_case";
  };
}
