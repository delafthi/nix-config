{
  imports = [
    ./core-packages.nix
    ./fonts.nix
    ./shells.nix
  ];
  environment.extraOutputsToInstall = [ "man" ];
}
