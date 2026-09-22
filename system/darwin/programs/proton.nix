{ pkgs, ... }:
{
  # Needs to be installed in /Applications
  environment.systemPackages = with pkgs; [
    proton-drive
    proton-vpn
  ];
}
