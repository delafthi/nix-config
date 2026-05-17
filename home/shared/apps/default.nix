{
  lib,
  osConfig,
  pkgs,
  ...
}:
{
  imports = [
    ./browser.nix
    ./obsidian.nix
    ./proton.nix
    ./yubikey.nix
  ];
  home.packages =
    with pkgs;
    [ qmk ]
    ++ lib.optionals osConfig.system.gui.enable [
      (if pkgs.stdenv.hostPlatform.isDarwin then blender-bin else blender)
      discord
      signal-desktop
      (if pkgs.stdenv.hostPlatform.isDarwin then kicad-bin else kicad)
    ];
}
