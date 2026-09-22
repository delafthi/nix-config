{
  lib,
  osConfig,
  pkgs,
  ...
}:
{
  home.packages =
    with pkgs;
    lib.optionals osConfig.system.gui.enable (
      lib.optionals stdenv.hostPlatform.isLinux [ proton-vpn ]
      ++ lib.optionals (stdenv.hostPlatform.system == "x86_64-linux" || stdenv.hostPlatform.isDarwin) [
        protonmail-desktop
        proton-pass
      ]
    );
}
