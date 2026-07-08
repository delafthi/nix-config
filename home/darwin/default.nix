{ strace-macos, ... }:
{
  imports = [
    ./apps
    ./desktop
    ./settings
    ./symlink-icloud.nix
  ];
  home.packages = [ strace-macos.default ];
}
