{ pkgs, ... }:
{
  home.packages = [ pkgs.manix ];
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
