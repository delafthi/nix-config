{ pkgs, ... }:
{
  imports = [
    ./bootloader
    ./desktop
    ./hardware
    ./networking
    ./programs
    ./security
    ./services
    ./settings
    ./nix.nix
  ];
  environment.systemPackages = with pkgs; [
    procps
  ];

}
