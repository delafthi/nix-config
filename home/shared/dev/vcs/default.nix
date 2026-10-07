{ pkgs, ... }:
{
  imports = [
    ./delta.nix
    ./gh.nix
    ./git-cliff.nix
    ./git.nix
    ./jujutsu.nix
    ./mergiraf.nix
  ];
  home.packages = [ pkgs.flirt ];
}
