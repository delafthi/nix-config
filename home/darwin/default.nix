{
  pkgs,
  strace-macos,
  ...
}:
{
  imports = [
    ./apps
    ./desktop
    ./settings
    ./symlink-icloud.nix
  ];
  home.packages = with pkgs; [
    mole-cleaner
    strace-macos.default
  ];
}
