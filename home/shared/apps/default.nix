{
  lib,
  osConfig,
  pkgs,
  ...
}:
{
  imports = [
    ./browser.nix
    ./proton.nix
    ./yubikey.nix
  ];
  home.packages =
    with pkgs;
    [ qmk ]
    ++ lib.optionals osConfig.system.gui.enable [
      blender
      signal-desktop
      (if pkgs.stdenv.hostPlatform.isDarwin then kicad-bin else kicad)
    ];
}
