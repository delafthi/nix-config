{ pkgs, ... }:
{
  home.packages = with pkgs; [ podman-compose ];
  services.podman = {
    enable = true;
    autoUpdate.enable = true;
  };
}
