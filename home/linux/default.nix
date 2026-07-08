{ pkgs, ... }:
{
  imports = [
    ./apps
    ./desktop
    ./settings
    ./create-para-dirs.nix
    ./reload-systemd.nix
  ];
  home.packages = with pkgs; [ strace ];
}
