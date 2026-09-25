{ pkgs, ... }:
let
  tomlFormat = pkgs.formats.toml { };
in
{
  xdg.configFile."rumdl/rumdl.toml".source = tomlFormat.generate "rumdl.toml" {
    MD013.reflow = true;
  };
}
