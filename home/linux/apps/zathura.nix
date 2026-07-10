{ config, osConfig, ... }:
{
  programs.zathura = {
    inherit (osConfig.system.gui) enable;
    options = {
      font = "${builtins.head config.fonts.fontconfig.defaultFonts.monospace} normal 14";
      selection-clipboard = "clipboard";
    };
  };
}
