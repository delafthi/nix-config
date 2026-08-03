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
      type = "github";
      owner = "delafthi";
      repo = "nix-templates";
    };
  };
}
