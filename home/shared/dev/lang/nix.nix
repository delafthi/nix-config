{ pkgs, ... }:
{
  home.packages = with pkgs; [
    manix
    nix-output-monitor
  ];
  nix.registry.templates = {
    from = {
      type = "indirect";
      id = "templates";
    };
    to = {
      type = "tarball";
      url = "https://codeberg.org/delafthi/nix-templates/archive/main.tar.gz";
    };
  };
}
