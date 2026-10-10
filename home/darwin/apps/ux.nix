{
  lib,
  osConfig,
  pkgs,
  ...
}:
{
  home.packages =
    with pkgs;
    lib.optionals osConfig.system.gui.enable [
      ice-bar
      # Currently, there is no way to disable auto-update
      # raycast
    ];
}
