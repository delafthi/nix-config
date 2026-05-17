{ pkgs, ... }:
{
  # Needs to be installed in /Applications
  environment.systemPackages = [ pkgs.proton-drive ];
}
